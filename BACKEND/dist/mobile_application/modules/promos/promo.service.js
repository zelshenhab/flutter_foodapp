"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchPromos = fetchPromos;
const supabase_1 = require("../../../core/config/supabase");
async function fetchPromos() {
    const now = new Date().toISOString();
    const { data, error } = await supabase_1.supabase
        .from("Promo") // 👈 use your actual table name in Supabase
        .select("*")
        .eq("active", true)
        .lte("validFrom", now)
        .gte("validTo", now)
        .order("id", { ascending: false });
    if (error) {
        throw { status: 500, message: "Failed to fetch promos", details: error.message };
    }
    return data ?? [];
}
//# sourceMappingURL=promo.service.js.map