"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hasServiceRole = exports.supabase = void 0;
const supabase_js_1 = require("@supabase/supabase-js");
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const key = SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY || "";
exports.supabase = SUPABASE_URL && key
    ? (0, supabase_js_1.createClient)(SUPABASE_URL, key)
    : null;
exports.hasServiceRole = Boolean(SUPABASE_SERVICE_ROLE_KEY);
//# sourceMappingURL=supabase.js.map