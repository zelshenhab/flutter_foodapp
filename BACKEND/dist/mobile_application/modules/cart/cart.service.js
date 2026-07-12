"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCart = getCart;
exports.addItem = addItem;
exports.updateItemQuantity = updateItemQuantity;
exports.removeByMenuItem = removeByMenuItem;
exports.removeItem = removeItem;
exports.applyPromo = applyPromo;
exports.clearCart = clearCart;
exports.getCartRecord = getCartRecord;
exports.applyLoyaltyPoints = applyLoyaltyPoints;
exports.removeLoyaltyPoints = removeLoyaltyPoints;
const supabase_1 = require("../../../core/config/supabase");
const promo_service_1 = require("../promos/promo.service");
const loyalty_service_1 = require("../loyalty/loyalty.service"); // 👈 ADD THIS LINE
function round2(n) {
    return Math.round(n * 100) / 100;
}
function sameNumberSets(a, b) {
    if (a.length !== b.length)
        return false;
    const as = [...a].sort((x, y) => x - y);
    const bs = [...b].sort((x, y) => x - y);
    for (let i = 0; i < as.length; i++)
        if (as[i] !== bs[i])
            return false;
    return true;
}
async function getOrCreateCart(userId) {
    const { data: existing, error: fetchError } = await supabase_1.supabase
        .from("Cart")
        .select("*")
        .eq("userId", userId)
        .single();
    if (existing && !fetchError) {
        return existing;
    }
    const { data: newCart, error: createError } = await supabase_1.supabase
        .from("Cart")
        .insert({ userId })
        .select()
        .single();
    if (createError) {
        throw { status: 500, message: "Failed to create cart" };
    }
    return newCart;
}
// ✅ UPDATE getCart function to include loyalty points
async function getCart(userId) {
    const cart = await getOrCreateCart(userId);
    const { data: items, error } = await supabase_1.supabase
        .from("CartItem")
        .select(`
      *,
      MenuItem!inner(id, title, imageUrl, categoryId)
    `)
        .eq("cartId", cart.id)
        .order("id", { ascending: true });
    if (error) {
        throw { status: 500, message: "Failed to fetch cart items" };
    }
    const mapped = items?.map((ci) => {
        const unitPrice = Number(ci.unitPriceSnapshot ?? ci.unitPrice ?? 0);
        const lineTotal = Number(ci.lineTotal ?? unitPrice * Number(ci.quantity || 1));
        return {
            id: ci.menuItemId,
            menuItemId: ci.menuItemId,
            title: ci.MenuItem?.title ?? "Товар",
            quantity: Number(ci.quantity || 1),
            unitPrice: round2(unitPrice),
            lineTotal: round2(lineTotal),
            optionIds: ci.optionsJson?.optionIds || [],
            image: ci.MenuItem?.imageUrl ?? null,
            categoryId: ci.MenuItem?.categoryId ?? null,
        };
    }) || [];
    const subtotal = mapped.reduce((s, it) => s + it.lineTotal, 0);
    // ✅ Service fee (still called deliveryFee in API for compatibility)
    const deliveryFee = mapped.length > 0 ? 2 : 0;
    // Promo discount
    let promoDiscount = 0;
    let promoError = null;
    if (cart.promoCode) {
        try {
            const validation = await (0, promo_service_1.validatePromo)(cart.promoCode, subtotal, userId);
            promoDiscount = validation.discountAmount;
        }
        catch (err) {
            promoError = err.message;
            promoDiscount = 0;
            await supabase_1.supabase
                .from("Cart")
                .update({ promoCode: null })
                .eq("id", cart.id);
        }
    }
    // Loyalty points
    const storedAppliedPoints = Math.max(0, Math.floor(Number(cart.appliedPoints ?? 0)));
    const remainingTotal = Math.max(0, subtotal - promoDiscount);
    const redemption = await (0, loyalty_service_1.calculatePointsRedemption)(remainingTotal, storedAppliedPoints, userId);
    const availablePoints = Number(redemption.availablePoints ?? 0);
    const finalAppliedPoints = Number(redemption.appliedPoints ?? 0);
    const pointsDiscount = Number(redemption.discountAmount ?? 0);
    // Revalidate saved points when:
    // - cart quantity changes
    // - promo changes
    // - user balance changes
    if (finalAppliedPoints !== storedAppliedPoints) {
        const { error: normalizationError } = await supabase_1.supabase
            .from("Cart")
            .update({
            appliedPoints: finalAppliedPoints,
            updatedAt: new Date().toISOString(),
        })
            .eq("id", cart.id);
        if (normalizationError) {
            console.error("Failed to normalize applied points:", normalizationError);
        }
    }
    const total = Math.max(0, subtotal - promoDiscount - pointsDiscount + deliveryFee);
    return {
        items: mapped,
        subtotal: round2(subtotal),
        discount: round2(promoDiscount),
        pointsDiscount: round2(pointsDiscount),
        deliveryFee: round2(deliveryFee),
        total: round2(total),
        promoCode: cart.promoCode,
        promoError,
        appliedPoints: finalAppliedPoints,
        availablePoints,
    };
}
async function computeUnitPrice(menuItemId, optionIds) {
    const { data: item, error } = await supabase_1.supabase
        .from("MenuItem")
        .select("*")
        .eq("id", menuItemId)
        .single();
    if (error || !item) {
        throw { status: 404, message: "Menu item not found" };
    }
    let price = Number(item.basePrice);
    if (optionIds.length) {
        const { data: opts, error: optsError } = await supabase_1.supabase
            .from("MenuOption")
            .select("priceDelta")
            .in("id", optionIds);
        if (!optsError && opts) {
            price += opts.reduce((s, o) => s + Number(o.priceDelta), 0);
        }
    }
    return { price, title: item.title };
}
async function addItem(userId, input) {
    const { itemId } = input;
    const quantity = Math.max(1, input.quantity || 1);
    const optionIds = input.optionIds || [];
    const cart = await getOrCreateCart(userId);
    const { price } = await computeUnitPrice(itemId, optionIds);
    const unitPrice = round2(price);
    const lineTotal = round2(price * quantity);
    const { data: rows, error: exErr } = await supabase_1.supabase
        .from("CartItem")
        .select("*")
        .eq("cartId", cart.id)
        .eq("menuItemId", itemId);
    if (!exErr && rows && rows.length > 0) {
        const matched = rows.find((r) => {
            const rOpts = r.optionsJson?.optionIds || [];
            return sameNumberSets(rOpts, optionIds);
        });
        if (matched) {
            const newQty = Number(matched.quantity || 0) + quantity;
            const newTotal = round2(newQty * Number(matched.unitPriceSnapshot ?? unitPrice));
            const { error: upErr } = await supabase_1.supabase
                .from("CartItem")
                .update({ quantity: newQty, lineTotal: newTotal })
                .eq("id", matched.id);
            if (upErr)
                throw { status: 500, message: "Failed to update existing cart item" };
            await supabase_1.supabase
                .from("Cart")
                .update({ updatedAt: new Date().toISOString() })
                .eq("id", cart.id);
            return matched.id;
        }
    }
    const { data: created, error } = await supabase_1.supabase
        .from("CartItem")
        .insert({
        cartId: cart.id,
        menuItemId: itemId,
        quantity,
        unitPriceSnapshot: unitPrice,
        optionsJson: { optionIds },
        lineTotal,
    })
        .select()
        .single();
    if (error) {
        throw { status: 500, message: "Failed to add item to cart" };
    }
    await supabase_1.supabase
        .from("Cart")
        .update({ updatedAt: new Date().toISOString() })
        .eq("id", cart.id);
    return created.id;
}
async function updateItemQuantity(userId, menuItemId, quantity) {
    const cart = await getOrCreateCart(userId);
    const { data: rows, error: rowErr } = await supabase_1.supabase
        .from("CartItem")
        .select("*")
        .eq("cartId", cart.id)
        .eq("menuItemId", menuItemId);
    if (rowErr || !rows || rows.length === 0) {
        throw { status: 404, message: "Item not in cart" };
    }
    const first = rows[0];
    const totalQty = Math.max(0, quantity);
    const unitPrice = Number(first.unitPriceSnapshot ?? first.unitPrice ?? 0);
    if (totalQty <= 0) {
        const { error: delErr } = await supabase_1.supabase
            .from("CartItem")
            .delete()
            .eq("cartId", cart.id)
            .eq("menuItemId", menuItemId);
        if (delErr)
            throw { status: 500, message: "Failed to remove item" };
        return;
    }
    if (rows.length > 1) {
        const extraIds = rows.slice(1).map((r) => r.id);
        await supabase_1.supabase.from("CartItem").delete().in("id", extraIds);
    }
    const lineTotal = round2(unitPrice * totalQty);
    const { error: upErr } = await supabase_1.supabase
        .from("CartItem")
        .update({ quantity: totalQty, lineTotal })
        .eq("id", first.id);
    if (upErr)
        throw { status: 500, message: "Failed to update quantity" };
    await supabase_1.supabase
        .from("Cart")
        .update({ updatedAt: new Date().toISOString() })
        .eq("id", cart.id);
}
async function removeByMenuItem(userId, menuItemId) {
    const cart = await getOrCreateCart(userId);
    const { error } = await supabase_1.supabase
        .from("CartItem")
        .delete()
        .eq("cartId", cart.id)
        .eq("menuItemId", menuItemId);
    if (error)
        throw { status: 500, message: "Failed to remove item from cart" };
    await supabase_1.supabase
        .from("Cart")
        .update({ updatedAt: new Date().toISOString() })
        .eq("id", cart.id);
}
async function removeItem(userId, cartItemId) {
    const cart = await getOrCreateCart(userId);
    const { data: item, error: fetchError } = await supabase_1.supabase
        .from("CartItem")
        .select("*")
        .eq("id", cartItemId)
        .single();
    if (fetchError || !item || item.cartId !== cart.id) {
        throw { status: 404, message: "Cart item not found" };
    }
    const { error } = await supabase_1.supabase.from("CartItem").delete().eq("id", cartItemId);
    if (error) {
        throw { status: 500, message: "Failed to remove item from cart" };
    }
}
async function applyPromo(userId, code) {
    const cart = await getOrCreateCart(userId);
    // First get current cart to get subtotal
    const currentCart = await getCart(userId);
    if (!code || code.trim() === "") {
        // Clear promo
        const { error: clearErr } = await supabase_1.supabase
            .from("Cart")
            .update({ promoCode: null })
            .eq("id", cart.id);
        if (clearErr)
            throw { status: 500, message: "Failed to clear promo" };
        return getCart(userId);
    }
    // Validate promo with current subtotal
    await (0, promo_service_1.validatePromo)(code.toUpperCase(), currentCart.subtotal, userId);
    // Save promo on cart
    const { error: updateError } = await supabase_1.supabase
        .from("Cart")
        .update({ promoCode: code.toUpperCase() })
        .eq("id", cart.id);
    if (updateError) {
        throw { status: 500, message: "Failed to apply promo" };
    }
    return getCart(userId);
}
async function clearCart(cartId) {
    const { error: itemsError } = await supabase_1.supabase
        .from("CartItem")
        .delete()
        .eq("cartId", cartId);
    if (itemsError) {
        throw {
            status: 500,
            message: "Failed to clear cart items",
        };
    }
    const { error: cartError } = await supabase_1.supabase
        .from("Cart")
        .update({
        promoCode: null,
        appliedPoints: 0,
        updatedAt: new Date().toISOString(),
    })
        .eq("id", cartId);
    if (cartError) {
        throw {
            status: 500,
            message: "Failed to reset cart",
        };
    }
}
async function getCartRecord(userId) {
    return getOrCreateCart(userId);
}
async function applyLoyaltyPoints(userId, pointsToApply) {
    const requestedPoints = Math.floor(Number(pointsToApply));
    if (!Number.isFinite(requestedPoints) ||
        requestedPoints < 100) {
        throw {
            status: 400,
            message: "Minimum 100 points required",
        };
    }
    const cartRecord = await getOrCreateCart(userId);
    const currentCart = await getCart(userId);
    const remainingTotal = Math.max(0, currentCart.subtotal - currentCart.discount);
    const redemption = await (0, loyalty_service_1.calculatePointsRedemption)(remainingTotal, requestedPoints, userId);
    const finalPoints = Number(redemption.appliedPoints ?? 0);
    if (finalPoints < 100) {
        throw {
            status: 400,
            message: "The requested loyalty points cannot be applied",
        };
    }
    const { error } = await supabase_1.supabase
        .from("Cart")
        .update({
        appliedPoints: finalPoints,
        updatedAt: new Date().toISOString(),
    })
        .eq("id", cartRecord.id);
    if (error) {
        console.error("Failed to persist applied points:", error);
        throw {
            status: 500,
            message: "Failed to apply loyalty points",
        };
    }
    return getCart(userId);
}
// ✅ ADD NEW FUNCTION to remove loyalty points
async function removeLoyaltyPoints(userId) {
    const cart = await getOrCreateCart(userId);
    const { error } = await supabase_1.supabase
        .from("Cart")
        .update({
        appliedPoints: 0,
        updatedAt: new Date().toISOString(),
    })
        .eq("id", cart.id);
    if (error) {
        console.error("Failed to remove loyalty points:", error);
        throw {
            status: 500,
            message: "Failed to remove loyalty points",
        };
    }
    return getCart(userId);
}
//# sourceMappingURL=cart.service.js.map