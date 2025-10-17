import { Prisma } from "@prisma/client";
import { prisma } from "../../core/config/db";
import * as cartSvc from "../cart/cart.service";

/** -------- Already implemented (Phase 3) ---------- */
type Preview = {
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  promoCode?: string | null;
  items: Array<{
    title: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
  }>;
};

export async function preview(userId: number): Promise<Preview> {
  return cartSvc.getCart(userId);
}

export async function createOrder(
  userId: number,
  input: {
    paymentMethod: "cod" | "card";
    address: any;
    notes?: string;
  }
) {
  const cartRec = await cartSvc.getCartRecord(userId);
  const cart = await cartSvc.getCart(userId);
  if (cart.items.length === 0) throw { status: 400, message: "Cart is empty" };

  const order = await prisma.$transaction(async (tx) => {
    const created = await tx.order.create({
      data: {
        userId,
        status: "pending",
        paymentMethod: input.paymentMethod,
        paymentStatus: input.paymentMethod === "cod" ? "unpaid" : "pending",
        subtotal: new Prisma.Decimal(cart.subtotal),
        discount: new Prisma.Decimal(cart.discount),
        deliveryFee: new Prisma.Decimal(cart.deliveryFee),
        total: new Prisma.Decimal(cart.total),
        addressSnapshot: input.address || { text: "N/A" },
        promoCode: cart.promoCode || null,
        notes: input.notes || null,
      },
    });

    const cartItems = await tx.cartItem.findMany({
      where: { cartId: cartRec.id },
      include: { menuItem: true },
      orderBy: { id: "asc" },
    });

    for (const ci of cartItems) {
      await tx.orderItem.create({
        data: {
          orderId: created.id,
          menuItemId: ci.menuItemId,
          titleSnap: ci.menuItem.title,
          optionsSnap: (ci.optionsJson as Prisma.InputJsonValue) ?? Prisma.JsonNull,
          unitPrice: ci.unitPriceSnapshot,
          quantity: ci.quantity,
          lineTotal: ci.lineTotal,
        },
      });
    }

    await cartSvc.clearCart(cartRec.id);
    return created;
  });

  return { orderId: order.id, status: order.status, total: Number(order.total) };
}

/** -------- New: list & details (Phase 4) ---------- */

export async function listOrders(
  userId: number,
  opts: { status?: string; page?: number; limit?: number }
) {
  const page = Math.max(1, Number(opts.page || 1));
  const limit = Math.min(50, Math.max(1, Number(opts.limit || 10)));
  const where: Prisma.OrderWhereInput = {
    userId,
    ...(opts.status ? { status: opts.status as any } : {}),
  };

  const [totalCount, rows] = await Promise.all([
    prisma.order.count({ where }),
    prisma.order.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
      select: {
        id: true,
        status: true,
        total: true,
        discount: true,
        deliveryFee: true,
        subtotal: true,
        promoCode: true,
        paymentMethod: true,
        paymentStatus: true,
        createdAt: true,
      },
    }),
  ]);

  return {
    data: rows.map((o) => ({
      ...o,
      total: Number(o.total),
      subtotal: Number(o.subtotal),
      discount: Number(o.discount),
      deliveryFee: Number(o.deliveryFee),
    })),
    page,
    limit,
    totalCount,
    totalPages: Math.ceil(totalCount / limit),
  };
}

export async function getOrderDetail(userId: number, orderId: number) {
  const order = await prisma.order.findFirst({
    where: { id: orderId, userId },
    include: {
      items: {
        select: {
          id: true,
          menuItemId: true,
          titleSnap: true,
          optionsSnap: true,
          unitPrice: true,
          quantity: true,
          lineTotal: true,
        },
        orderBy: { id: "asc" },
      },
    },
  });
  if (!order) throw { status: 404, message: "Order not found" };

  return {
    ...order,
    total: Number(order.total),
    subtotal: Number(order.subtotal),
    discount: Number(order.discount),
    deliveryFee: Number(order.deliveryFee),
    items: order.items.map((it) => ({
      ...it,
      unitPrice: Number(it.unitPrice),
      lineTotal: Number(it.lineTotal),
    })),
  };
}
