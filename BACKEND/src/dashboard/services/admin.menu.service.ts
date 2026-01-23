// BACKEND/src/dashboard/services/admin.menu.service.ts

import { supabase } from "../../core/config/supabase";
import {
  AdminCategoryCreate,
  AdminCategoryUpdate,
  AdminMenuItemCreate,
  AdminMenuItemUpdate,
  AdminMenuItemFilters,
} from "../models/admin.menu.types";

/* ===============================================================
   🔤 SLUGIFY HELPER — used for Categories and Menu Items
   =============================================================== */
function slugify(text: string): string {
  return text
    .toString()
    .toLowerCase()
    .trim()
    .replace(/\s+/g, "-")
    .replace(/[^\w\-]+/g, "")
    .replace(/\-\-+/g, "-");
}

/* ===============================================================
   🟧 CATEGORIES
   =============================================================== */

export async function listCategories() {
  const { data, error } = await supabase
    .from("Category")
    .select("*")
    .order("position", { ascending: true });

  if (error) throw error;
  return data;
}

export async function createCategory(payload: AdminCategoryCreate) {
  const { title, position } = payload;

  const slug = slugify(title);

  const { data, error } = await supabase
    .from("Category")
    .insert([
      {
        title,
        slug,
        position: position ?? 0,
      },
    ])
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function updateCategory(id: number, payload: AdminCategoryUpdate) {
  const patch: AdminCategoryUpdate = {};

  if (typeof payload.title === "string") {
    patch.title = payload.title;
    patch.slug = slugify(payload.title); // auto-update slug
  }

  if (typeof payload.position === "number") {
    patch.position = payload.position;
  }

  const { data, error } = await supabase
    .from("Category")
    .update(patch)
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

export async function deleteCategory(id: number) {
  const { error } = await supabase.from("Category").delete().eq("id", id);
  if (error) throw error;
}

/* ===============================================================
   🍔 MENU ITEMS
   =============================================================== */

export async function listItems(filters: AdminMenuItemFilters) {
  const { categoryId, search, isActive } = filters;

  let q = supabase
    .from("MenuItem")
    .select("*")
    .order("title", { ascending: true });

  if (categoryId) q = q.eq("categoryId", categoryId);
  if (typeof isActive === "boolean") q = q.eq("isActive", isActive);
  if (search && search.trim()) q = q.ilike("title", `%${search.trim()}%`);

  const { data, error } = await q;
  if (error) throw error;

  return data;
}

/* ===============================================================
   🍔 CREATE ITEM (slug auto-generated)
   =============================================================== */
export async function createItem(payload: AdminMenuItemCreate) {
  const {
    categoryId,
    title,
    description,
    imageUrl,
    basePrice,
    isActive,
    isPopular,
    iikoProductId,
  } = payload;

  if (!iikoProductId || !iikoProductId.trim()) {
    throw {
      status: 400,
      message: "iikoProductId is required. Create product in iiko first.",
    };
  }

  const slug = slugify(title);

  const { data, error } = await supabase
    .from("MenuItem")
    .insert([
      {
        categoryId,
        title,
        slug,
        description: description ?? null,
        imageUrl: imageUrl ?? null,
        basePrice,
        isActive: isActive ?? true,
        isPopular: isPopular ?? false,
        iikoProductId, // ✅ SAVE REAL IIKO ID
      },
    ])
    .select()
    .single();

  if (error) throw error;
  return data;
}

/* ===============================================================
   🍔 UPDATE ITEM (if title changes → slug updates)
   =============================================================== */
export async function updateItem(id: number, payload: AdminMenuItemUpdate) {
  const patch: AdminMenuItemUpdate = {};

  if (typeof payload.categoryId === "number") {
    patch.categoryId = payload.categoryId;
  }

  if (typeof payload.title === "string") {
    patch.title = payload.title;
    patch.slug = slugify(payload.title); // ← auto-regenerate slug
  }

  if (payload.description !== undefined) {
    patch.description = payload.description;
  }

  if (payload.imageUrl !== undefined) {
    patch.imageUrl = payload.imageUrl;
  }

  if (typeof payload.basePrice === "number") {
    patch.basePrice = payload.basePrice;
  }

  if (typeof payload.isActive === "boolean") {
    patch.isActive = payload.isActive;
  }

  if (typeof payload.isPopular === "boolean") {
    patch.isPopular = payload.isPopular;
  }

  if (payload.iikoProductId !== undefined) {
    patch.iikoProductId = payload.iikoProductId;
  }


  const { data, error } = await supabase
    .from("MenuItem")
    .update(patch)
    .eq("id", id)
    .select()
    .single();

  if (error) throw error;
  return data;
}

/* ===============================================================
   🗑 DELETE ITEM
   =============================================================== */
export async function deleteItem(id: number) {
  const { error } = await supabase.from("MenuItem").delete().eq("id", id);
  if (error) throw error;
}
