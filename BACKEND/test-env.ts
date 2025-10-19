import dotenv from 'dotenv';

dotenv.config();

console.log('🔍 Environment Variables Test:');
console.log('SUPABASE_URL:', process.env.SUPABASE_URL ? '✅ Found' : '❌ Missing');
console.log('SUPABASE_SERVICE_KEY:', process.env.SUPABASE_SERVICE_KEY ? '✅ Found' : '❌ Missing');
console.log('JWT_SECRET:', process.env.JWT_SECRET ? '✅ Found' : '❌ Missing');
console.log('PORT:', process.env.PORT || 'Not set (will use default 4000)');

if (process.env.SUPABASE_URL) {
  console.log('\nSUPABASE_URL value:', process.env.SUPABASE_URL);
}
if (process.env.SUPABASE_SERVICE_KEY) {
  console.log('SUPABASE_SERVICE_KEY length:', process.env.SUPABASE_SERVICE_KEY.length);
}
