import { prisma } from "../../core/config/db";

export async function fetchPromos() {
  const now = new Date();
  return prisma.promo.findMany({
    where: {
      active: true,
      OR: [{ validFrom: null }, { validFrom: { lte: now } }],
      AND: [{ validTo: null }, { validTo: { gte: now } }],
    },
    orderBy: { id: "desc" },
  });
}
