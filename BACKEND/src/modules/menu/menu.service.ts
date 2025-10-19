import { supabase } from "../../core/config/supabase";

export async function listCategories() {
  const { data, error } = await supabase
    .from('Category')
    .select('*')
    .order('position', { ascending: true });

  if (error) {
    throw { status: 500, message: "Failed to fetch categories" };
  }

  // Transform to match frontend expectations
  return data?.map(cat => ({
    id: cat.slug, // Use slug as ID for frontend compatibility
    title: cat.title,
  })) || [];
}

export async function listItems(params: { category?: string; search?: string }) {
  const { category, search } = params;
  
  let query = supabase
    .from('MenuItem')
    .select(`
      *,
      Category!inner(id, title, slug)
    `)
    .eq('isActive', true);

  if (category) {
    query = query.eq('Category.slug', category);
  }

  if (search) {
    query = query.ilike('title', `%${search}%`);
  }

  query = query.order('isPopular', { ascending: false })
               .order('id', { ascending: true });

  const { data, error } = await query;

  if (error) {
    throw { status: 500, message: "Failed to fetch menu items" };
  }

  // Transform to match frontend expectations
  return (data || []).map((row) => ({
    id: row.slug, // Use slug as ID for frontend compatibility
    name: row.title,
    price: Number(row.basePrice),
    image: row.imageUrl || "assets/images/Chicken-Shawarma-8.jpg",
    categoryId: row.Category.slug,
    description: row.description,
    serverId: row.id,
  })) || [];
}