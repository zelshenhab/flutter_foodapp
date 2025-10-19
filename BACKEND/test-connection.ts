import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = "https://nwaphgvmxtaalyxpgfdt.supabase.co";
const supabaseServiceKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YXBoZ3ZteHRhYWx5eHBnZmR0Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDYxNDM2MywiZXhwIjoyMDc2MTkwMzYzfQ.ReZcP4FIdvDgkdY1TbxlJ_RD_YsBjs9XZzFAHFdQvAo";

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function testConnection() {
  console.log('🔗 Testing Supabase connection...');
  
  try {
    // Test connection by fetching categories
    const { data, error } = await supabase
      .from('Category')
      .select('*')
      .limit(5);

    if (error) {
      console.error('❌ Connection failed:', error.message);
      return false;
    }

    console.log('✅ Connection successful!');
    console.log('📊 Found categories:', data?.length || 0);
    if (data && data.length > 0) {
      console.log('Sample category:', data[0]);
    }
    
    return true;
  } catch (err) {
    console.error('❌ Connection error:', err);
    return false;
  }
}

testConnection().then(success => {
  if (success) {
    console.log('\n🎉 Your Supabase backend is ready!');
    console.log('📝 Next steps:');
    console.log('1. Create .env file with your Supabase credentials');
    console.log('2. Run: npm run seed (to populate database)');
    console.log('3. Run: npm run dev (to start server)');
  } else {
    console.log('\n❌ Please check your Supabase configuration');
  }
});
