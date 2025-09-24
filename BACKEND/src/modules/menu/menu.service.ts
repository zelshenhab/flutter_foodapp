export async function listCategories() {
  return [{ id: 1, title: "Shawarma" }];
}
export async function listItems(categoryId: number) {
  return [{ id: 101, categoryId, title: "Chicken Shawarma", price: 5.99 }];
}
