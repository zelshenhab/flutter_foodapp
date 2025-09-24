export async function fetchUser(id: number) {
  return { id, name: "John Doe" };
}
export async function saveUser(id: number, data: any) {
  return { id, ...data };
}
