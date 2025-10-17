import { prisma } from "../../core/config/db";

export async function listCategories() {
  return prisma.category.findMany({ orderBy: { position: "asc" } });
}

export async function listItems(params: { categorySlug?: string; search?: string }) {
  const { categorySlug, search } = params;
  return prisma.menuItem.findMany({
    where: {
      AND: [
        { isActive: true },
        categorySlug ? { category: { slug: categorySlug } } : {},
        search ? { title: { contains: search, mode: "insensitive" } } : {},
      ],
    },
    include: {
      optionGroups: { include: { options: true } },
      category: { select: { id: true, title: true, slug: true } },
    },
    orderBy: [{ isPopular: "desc" }, { id: "asc" }],
  });
}
