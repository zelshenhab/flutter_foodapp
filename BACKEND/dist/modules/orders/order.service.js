"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listOrders = listOrders;
exports.getOrderById = getOrderById;
exports.createOrder = createOrder;
const db_1 = require("../../core/config/db");
function listOrders(userId) {
    return db_1.db.orders.get(userId) ?? [];
}
function getOrderById(userId, orderId) {
    const list = db_1.db.orders.get(userId) ?? [];
    return list.find((o) => o.id === orderId) ?? null;
}
function createOrder(userId, payload) {
    const id = `ord_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 6)}`;
    const next = {
        id,
        userId,
        createdAt: new Date().toISOString(),
        restaurant: "Адам и Ева",
        items: payload.items.map((i) => ({ id: i.id, name: i.name, price: i.price, qty: i.qty, image: i.image })),
        deliveryFee: payload.deliveryFee ?? 0,
        discount: payload.discount ?? 0,
        status: "pending",
    };
    const list = db_1.db.orders.get(userId) ?? [];
    list.unshift(next);
    db_1.db.orders.set(userId, list);
    return next;
}
//# sourceMappingURL=order.service.js.map