"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.supabase = void 0;
const path_1 = __importDefault(require("path"));
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config({ path: path_1.default.resolve(__dirname, "../../../.env") });
const supabase_js_1 = require("@supabase/supabase-js");
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
if (!supabaseUrl || !supabaseServiceKey) {
    console.error('❌ Missing Supabase environment variables:');
    console.error('SUPABASE_URL:', supabaseUrl ? '✅ Set' : '❌ Missing');
    console.error('SUPABASE_SERVICE_KEY:', supabaseServiceKey ? '✅ Set' : '❌ Missing');
    console.error('');
    console.error('Please check your .env file and make sure it contains:');
    console.error('SUPABASE_URL="https://nwaphgvmxtaalyxpgfdt.supabase.co"');
    console.error('SUPABASE_SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDYxNDM2MywiZXhwIjoyMDc2MTkwMzYzfQ.ReZcP4FIdvDgkdY1TbxlJ_RD_YsBjs9XZzFAHFdQvAo"');
    throw new Error('Missing Supabase environment variables. Please set SUPABASE_URL and SUPABASE_SERVICE_KEY');
}
exports.supabase = (0, supabase_js_1.createClient)(supabaseUrl, supabaseServiceKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false
    }
});
//# sourceMappingURL=supabase.js.map