"use strict";
// BACKEND/src/dashboard/services/admin.menu.service.ts
Object.defineProperty(exports, "__esModule", { value: true });
exports.listCategories = listCategories;
exports.createCategory = createCategory;
exports.updateCategory = updateCategory;
exports.deleteCategory = deleteCategory;
exports.listItems = listItems;
exports.createItem = createItem;
exports.updateItem = updateItem;
exports.deleteItem = deleteItem;
const supabase_1 = require("../../core/config/supabase");
/* ===============================================================
   🔤 SLUGIFY HELPER — used for Categories and Menu Items
   =============================================================== */
function slugify(text) {
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
async function listCategories() {
    const { data, error } = await supabase_1.supabase
        .from("Category")
        .select("*")
        .order("position", { ascending: true });
    if (error)
        throw error;
    return data;
}
async function createCategory(payload) {
    const { title, position } = payload;
    const slug = slugify(title);
    const { data, error } = await supabase_1.supabase
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
    if (error)
        throw error;
    return data;
}
async function updateCategory(id, payload) {
    const patch = {};
    if (typeof payload.title === "string") {
        patch.title = payload.title;
        patch.slug = slugify(payload.title); // auto-update slug
    }
    if (typeof payload.position === "number") {
        patch.position = payload.position;
    }
    const { data, error } = await supabase_1.supabase
        .from("Category")
        .update(patch)
        .eq("id", id)
        .select()
        .single();
    if (error)
        throw error;
    return data;
}
async function deleteCategory(id) {
    const { error } = await supabase_1.supabase.from("Category").delete().eq("id", id);
    if (error)
        throw error;
}
/* ===============================================================
   🍔 MENU ITEMS
   =============================================================== */
async function listItems(filters) {
    const { categoryId, search, isActive } = filters;
    let q = supabase_1.supabase
        .from("MenuItem")
        .select("*")
        .order("title", { ascending: true });
    if (categoryId)
        q = q.eq("categoryId", categoryId);
    if (typeof isActive === "boolean")
        q = q.eq("isActive", isActive);
    if (search && search.trim())
        q = q.ilike("title", `%${search.trim()}%`);
    const { data, error } = await q;
    if (error)
        throw error;
    return data;
}
/* ===============================================================
   🍔 CREATE ITEM (slug auto-generated)
   =============================================================== */
async function createItem(payload) {
    const { categoryId, title, description, imageUrl, basePrice, isActive, isPopular, iikoProductId, } = payload;
    if (!iikoProductId || !iikoProductId.trim()) {
        throw {
            status: 400,
            message: "iikoProductId is required. Create product in iiko first.",
        };
    }
    const slug = slugify(title);
    const { data, error } = await supabase_1.supabase
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
    if (error)
        throw error;
    return data;
}
/* ===============================================================
   🍔 UPDATE ITEM (if title changes → slug updates)
   =============================================================== */
async function updateItem(id, payload) {
    const patch = {};
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
    const { data, error } = await supabase_1.supabase
        .from("MenuItem")
        .update(patch)
        .eq("id", id)
        .select()
        .single();
    if (error)
        throw error;
    return data;
}
/* ===============================================================
   🗑 DELETE ITEM
   =============================================================== */
async function deleteItem(id) {
    const { error } = await supabase_1.supabase.from("MenuItem").delete().eq("id", id);
    if (error)
        throw error;
}
//# sourceMappingURL=admin.menu.service.js.map