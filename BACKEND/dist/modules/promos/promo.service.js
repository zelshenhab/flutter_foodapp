"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchActivePromos = fetchActivePromos;
exports.findPromoByCode = findPromoByCode;
const supabase_1 = require("../../core/config/supabase");
const fallbackPromos = [
    { id: "p1", title: "Скидка новичкам", description: "10% на первый заказ от 1000 ₽", type: "percent", amount: 10, code: "WELCOME", validTo: null },
    { id: "p2", title: "Комбо выходного", description: "Скидка 300 ₽ при заказе от 1500 ₽", type: "fixed", amount: 300, code: "WEEKEND300", validTo: null },
    { id: "p3", title: "Бесплатный соус", description: "Добавьте соус бесплатно к шаурме", type: "fixed", amount: 50, code: "FREESAUCE", validTo: null },
];
async function fetchActivePromos() {
    if (!supabase_1.supabase)
        return fallbackPromos;
    const { data, error } = await supabase_1.supabase.from("promos").select("id,title,description,type,amount,code,valid_to");
    if (error || !data)
        return fallbackPromos;
    return data.map((p) => ({
        id: p.id,
        title: p.title,
        description: p.description,
        type: p.type,
        amount: Number(p.amount),
        code: p.code,
        validTo: p.valid_to,
    }));
}
async function findPromoByCode(code) {
    if (!supabase_1.supabase)
        return fallbackPromos.find((p) => p.code.toLowerCase() === code.toLowerCase()) || null;
    const { data, error } = await supabase_1.supabase
        .from("promos")
        .select("id,title,description,type,amount,code,valid_to")
        .ilike("code", code)
        .maybeSingle();
    if (error || !data)
        return null;
    return {
        id: data.id,
        title: data.title,
        description: data.description,
        type: data.type,
        amount: Number(data.amount),
        code: data.code,
        validTo: data.valid_to,
    };
}
//# sourceMappingURL=promo.service.js.map