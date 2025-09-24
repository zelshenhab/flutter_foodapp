export async function fetchCart(userId: number) {
  return { userId, items: [] };
}
export async function addToCart(userId: number, itemId: number) {
  return { userId, itemId };
}
