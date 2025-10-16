"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getOrders = getOrders;
exports.getOrder = getOrder;
exports.postOrder = postOrder;
const order_service_1 = require("./order.service");
function getOrders(req, res) {
    const userId = req.user.userId;
    const data = (0, order_service_1.listOrders)(userId);
    return res.json(data);
}
function getOrder(req, res) {
    const userId = req.user.userId;
    const { orderId } = req.params;
    const order = (0, order_service_1.getOrderById)(userId, orderId);
    if (!order)
        return res.status(404).json({ message: "Order not found" });
    return res.json(order);
}
function postOrder(req, res) {
    const userId = req.user.userId;
    const body = req.body;
    if (!body?.items || !Array.isArray(body.items) || body.items.length === 0) {
        return res.status(400).json({ message: "items array is required" });
    }
    const created = (0, order_service_1.createOrder)(userId, body);
    return res.status(201).json(created);
}
//# sourceMappingURL=order.controller.js.map