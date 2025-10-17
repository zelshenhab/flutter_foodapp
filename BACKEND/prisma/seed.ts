import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

async function main() {
  // categories
  const shawarma = await prisma.category.upsert({
    where: { slug: "shawarma" },
    update: {},
    create: { title: "Shawarma", slug: "shawarma", position: 1 },
  });

  // items
  const chicken = await prisma.menuItem.upsert({
    where: { slug: "chicken-shawarma" },
    update: {},
    create: {
      categoryId: shawarma.id,
      title: "Chicken Shawarma",
      slug: "chicken-shawarma",
      description: "Juicy chicken with garlic sauce",
      imageUrl: null,
      basePrice: 5.99,
      isPopular: true,
    },
  });

  // options
  const sizeGroup = await prisma.menuOptionGroup.create({
    data: { itemId: chicken.id, title: "Size", type: "single", min: 1, max: 1 },
  });
  await prisma.menuOption.createMany({
    data: [
      { groupId: sizeGroup.id, title: "Regular", priceDelta: 0 },
      { groupId: sizeGroup.id, title: "Large", priceDelta: 2 },
    ],
  });

  // promos
  await prisma.promo.upsert({
    where: { code: "WELCOME10" },
    update: {},
    create: {
      code: "WELCOME10",
      title: "Welcome 10%",
      description: "10% off your first order",
      type: "percent",
      value: 10,
      active: true,
    },
  });
}

main().finally(async () => await prisma.$disconnect());
