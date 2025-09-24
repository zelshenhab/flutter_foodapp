export async function fetchOrders(userId: number) {
  return [{ id: 9001, userId, status: "pending" }];
}
export async function fetchOrderById(id: number) {
  return { id, status: "pending" };
}
