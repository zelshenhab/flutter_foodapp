import { Prisma, PrismaClient } from "@prisma/client";
import { prisma } from "../../core/config/db";

type Pricing = {
  items: Array<{
    id: number;
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
    optionIds: number[];
  }>;
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  promoCode?: string | null;
};

function toNum(d: Prisma.Decimal | number | null | undefined) {
  return Number(d || 0);
}

async function getOrCreateCart(userId: number) {
  const existing = await prisma.cart.findUnique({ where: { userId } });
  if (existing) return existing;
  return prisma.cart.create({ data: { userId } });
}

export async function getCart(userId: number): Promise<Pricing> {
  const cart = await getOrCreateCart(userId);
  const items = await prisma.cartItem.findMany({
    where: { cartId: cart.id },
    include: { menuItem: true },
    orderBy: { id: "asc" },
  });

  const mapped = items.map((ci) => {
    const unitPrice = toNum(ci.unitPriceSnapshot);
    const lineTotal = toNum(ci.lineTotal);
    return {
      id: ci.id,
      title: ci.menuItem.title,
      quantity: ci.quantity,
      unitPrice,
      lineTotal,
      optionIds: (ci.optionsJson as any)?.optionIds || [],
    };
  });

  const subtotal = mapped.reduce((s, it) => s + it.lineTotal, 0);
  // simple delivery rule for now:
  const deliveryFee = subtotal > 0 ? 1.5 : 0;

  let discount = 0;
  if (cart.promoCode) {
    discount = await computePromoDiscount(cart.promoCode, subtotal);
  }
  const total = Math.max(0, subtotal - discount + deliveryFee);

  return {
    items: mapped,
    subtotal: round2(subtotal),
    discount: round2(discount),
    deliveryFee: round2(deliveryFee),
    total: round2(total),
    promoCode: cart.promoCode,
  };
}

function round2(n: number) {
  return Math.round(n * 100) / 100;
}

async function computeUnitPrice(menuItemId: number, optionIds: number[]) {
  const item = await prisma.menuItem.findUnique({ where: { id: menuItemId } });
  if (!item) throw { status: 404, message: "Menu item not found" };
  let price = toNum(item.basePrice);

  if (optionIds.length) {
    const opts = await prisma.menuOption.findMany({ where: { id: { in: optionIds } } });
    price += opts.reduce((s, o) => s + toNum(o.priceDelta), 0);
  }
  return { price, title: item.title };
}

export async function addItem(userId: number, input: { itemId: number; quantity: number; optionIds?: number[] }) {
  const { itemId } = input;
  const quantity = Math.max(1, input.quantity || 1);
  const optionIds = input.optionIds || [];

  const cart = await getOrCreateCart(userId);
  const { price } = await computeUnitPrice(itemId, optionIds);

  const unit = new Prisma.Decimal(price);
  const line = new Prisma.Decimal(round2(price * quantity));

  const created = await prisma.cartItem.create({
    data: {
      cartId: cart.id,
      menuItemId: itemId,
      quantity,
      unitPriceSnapshot: unit,
      optionsJson: { optionIds },
      lineTotal: line,
    },
  });

  // update cart timestamp
  await prisma.cart.update({ where: { id: cart.id }, data: { updatedAt: new Date() } });
  return created.id;
}

export async function removeItem(userId: number, cartItemId: number) {
  const cart = await getOrCreateCart(userId);
  const item = await prisma.cartItem.findUnique({ where: { id: cartItemId } });
  if (!item || item.cartId !== cart.id) throw { status: 404, message: "Cart item not found" };
  await prisma.cartItem.delete({ where: { id: cartItemId } });
}

export async function applyPromo(userId: number, code: string) {
  const cart = await getOrCreateCart(userId);
  // Validate promo exists & active
  const promo = await prisma.promo.findUnique({ where: { code } });
  if (!promo || !promo.active) throw { status: 400, message: "Invalid promo" };
  // Save on cart
  await prisma.cart.update({ where: { id: cart.id }, data: { promoCode: code } });
  return getCart(userId);
}

async function computePromoDiscount(code: string, subtotal: number) {
  const promo = await prisma.promo.findUnique({ where: { code } });
  if (!promo || !promo.active) return 0;

  // date window check
  const now = new Date();
  // if validFrom/validTo set, ensure now in range
  if ((promo.validFrom && promo.validFrom > now) || (promo.validTo && promo.validTo < now)) {
    return 0;
  }

  if (promo.minSubtotal && toNum(promo.minSubtotal) > subtotal) return 0;

  const type = promo.type;
  const value = toNum(promo.value);
  if (type === "percent") {
    return round2((value / 100) * subtotal);
  }
  if (type === "fixed") {
    return Math.min(round2(value), subtotal);
  }
  return 0;
}

export async function clearCart(cartId: number) {
  await prisma.cartItem.deleteMany({ where: { cartId } });
  await prisma.cart.update({ where: { id: cartId }, data: { promoCode: null } });
}

export async function getCartRecord(userId: number) {
  return getOrCreateCart(userId);
}
