// BACKEND/src/dashboard/models/admin.menu.types.ts

export interface AdminCategoryCreate {
  title: string;
  slug: string;
  position?: number;
}

export interface AdminCategoryUpdate {
  title?: string;
  slug?: string;
  position?: number;
}

export interface AdminMenuItemCreate {
  categoryId: number;
  title: string;
  slug: string;
  description?: string;
  imageUrl?: string;
  basePrice: number;
  isActive: boolean;
  isPopular: boolean;
}

export interface AdminMenuItemUpdate {
  categoryId?: number;
  title?: string;
  slug?: string;
  description?: string;
  imageUrl?: string | null;
  basePrice?: number;
  isActive?: boolean;
  isPopular?: boolean;
}

export interface AdminMenuItemFilters {
  categoryId?: number;
  search?: string;
  isActive?: boolean;
}
