"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.preview = preview;
exports.createOrder = createOrder;
exports.listOrders = listOrders;
exports.getOrderDetail = getOrderDetail;
exports.completeOrder = completeOrder;
const supabase_1 = require("../../../core/config/supabase");
const cartSvc = __importStar(require("../cart/cart.service"));
const iiko_client_1 = require("../../../core/iiko/iiko.client");
const iiko_constants_1 = require("../../../core/iiko/iiko.constants");
/* ======================================================
   HELPERS
====================================================== */
function getMenuItem(ci) {
    if (!Array.isArray(ci.MenuItem) || ci.MenuItem.length === 0) {
        throw {
            status: 400,
            message: "One or more items are no longer available",
        };
    }
    return ci.MenuItem[0];
}
/* ======================================================
   PREVIEW
====================================================== */
async function preview(userId) {
    return cartSvc.getCart(userId);
}
/* ======================================================
   CREATE ORDER
====================================================== */
async function createOrder(userId, input) {
    /* -----------------------------------------
     * 1️⃣ LOAD CART
     * --------------------------------------- */
    const cartRec = await cartSvc.getCartRecord(userId);
    const cart = await cartSvc.getCart(userId);
    if (!cart.items.length) {
        throw { status: 400, message: "Cart is empty" };
    }
    /* -----------------------------------------
     * 2️⃣ CREATE ORDER (SUPABASE)
     * --------------------------------------- */
    const { data: order, error: orderError } = await supabase_1.supabase
        .from("Order")
        .insert({
        userId,
        status: "pending",
        paymentMethod: input.paymentMethod,
        paymentStatus: input.paymentMethod === "cod" ? "unpaid" : "pending",
        subtotal: cart.subtotal,
        discount: cart.discount,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
        addressSnapshot: input.address ?? { text: "N/A" },
        promoCode: cart.promoCode ?? null,
        notes: input.notes ?? null,
    })
        .select()
        .single();
    if (orderError || !order) {
        console.error("❌ ORDER INSERT ERROR:", orderError);
        throw { status: 500, message: "Failed to create order" };
    }
    /* -----------------------------------------
     * 3️⃣ LOAD CART ITEMS + MENU ITEMS
     * --------------------------------------- */
    const { data: cartItems, error: cartItemsError } = await supabase_1.supabase
        .from("CartItem")
        .select(`
      id,
      menuItemId,
      quantity,
      unitPriceSnapshot,
      lineTotal,
      MenuItem!inner (
        id,
        title,
        iikoProductId
      )
    `)
        .eq("cartId", cartRec.id)
        .order("id", { ascending: true });
    if (cartItemsError || !cartItems?.length) {
        console.error("❌ CART ITEMS ERROR:", cartItemsError);
        throw { status: 500, message: "Failed to fetch cart items" };
    }
    /* -----------------------------------------
     * 4️⃣ VALIDATE MENU ITEMS (IMPORTANT)
     * --------------------------------------- */
    for (const ci of cartItems) {
        const menuItem = getMenuItem(ci);
        if (!menuItem.iikoProductId) {
            throw {
                status: 400,
                message: `Item "${menuItem.title}" is not available for online payment`,
            };
        }
    }
    /* -----------------------------------------
     * 5️⃣ CREATE ORDER ITEMS (SUPABASE)
     * --------------------------------------- */
    const orderItems = cartItems.map((ci) => {
        const menuItem = getMenuItem(ci);
        return {
            orderId: order.id,
            menuItemId: ci.menuItemId,
            titleSnap: menuItem.title,
            unitPrice: Number(ci.unitPriceSnapshot),
            quantity: ci.quantity,
            lineTotal: Number(ci.lineTotal),
        };
    });
    const { error: orderItemsError } = await supabase_1.supabase
        .from("OrderItem")
        .insert(orderItems);
    if (orderItemsError) {
        console.error("❌ ORDER ITEMS ERROR:", orderItemsError);
        throw { status: 500, message: "Failed to create order items" };
    }
    /* -----------------------------------------
     * 6️⃣ SEND ORDER TO IIKO
     * --------------------------------------- */
    try {
        const iikoResponse = await iiko_client_1.iikoClient.request("POST", "/order/create", {
            organizationId: iiko_constants_1.IIKO_ORGANIZATION_ID,
            order: {
                externalNumber: `FOODAPP-${order.id}`,
                items: cartItems.map((ci) => {
                    const menuItem = getMenuItem(ci);
                    return {
                        productId: menuItem.iikoProductId,
                        amount: ci.quantity,
                        price: Math.round(Number(ci.unitPriceSnapshot)),
                    };
                }),
            },
        });
        await supabase_1.supabase
            .from("Order")
            .update({ iikoOrderId: iikoResponse.orderInfo.id })
            .eq("id", order.id);
    }
    catch (e) {
        console.error("❌ IIKO ORDER CREATE ERROR:", e);
        await supabase_1.supabase
            .from("Order")
            .update({ status: "failed" })
            .eq("id", order.id);
        throw { status: 500, message: "Failed to send order to iiko" };
    }
    /* -----------------------------------------
     * 7️⃣ CLEAR CART
     * --------------------------------------- */
    await cartSvc.clearCart(cartRec.id);
    return {
        orderId: order.id,
        status: order.status,
        total: Number(order.total),
    };
}
/* ======================================================
   LIST ORDERS
====================================================== */
async function listOrders(userId, opts) {
    const page = Math.max(1, Number(opts.page || 1));
    const limit = Math.min(50, Math.max(1, Number(opts.limit || 10)));
    const offset = (page - 1) * limit;
    let query = supabase_1.supabase
        .from("Order")
        .select("*")
        .eq("userId", userId)
        .order("createdAt", { ascending: false })
        .range(offset, offset + limit - 1);
    if (opts.status)
        query = query.eq("status", opts.status);
    const { data, error } = await query;
    if (error)
        throw { status: 500, message: "Failed to fetch orders" };
    return data ?? [];
}
/* ======================================================
   GET ORDER DETAIL
====================================================== */
async function getOrderDetail(userId, orderId) {
    const { data: order, error } = await supabase_1.supabase
        .from("Order")
        .select("*")
        .eq("id", orderId)
        .eq("userId", userId)
        .single();
    if (error || !order) {
        throw { status: 404, message: "Order not found" };
    }
    const { data: items } = await supabase_1.supabase
        .from("OrderItem")
        .select("*")
        .eq("orderId", orderId);
    return { ...order, items: items ?? [] };
}
/* ======================================================
   COMPLETE ORDER
====================================================== */
async function completeOrder(userId, orderId) {
    const { data, error } = await supabase_1.supabase
        .from("Order")
        .update({ status: "completed" })
        .eq("id", orderId)
        .eq("userId", userId)
        .select()
        .single();
    if (error || !data) {
        throw { status: 500, message: "Failed to complete order" };
    }
    return data;
}
//# sourceMappingURL=order.service.js.map