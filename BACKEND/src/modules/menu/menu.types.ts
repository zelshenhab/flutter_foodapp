export interface CategoryDto {
  id: string;
  title: string;
}

export interface MenuItemDto {
  id: string;
  name: string;
  price: number;
  image: string;
  categoryId: string;
  desc?: string;
}

