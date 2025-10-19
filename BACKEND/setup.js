#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🍔 FoodApp Backend Setup');
console.log('========================\n');

// Check if .env exists
const envPath = path.join(__dirname, '.env');
if (!fs.existsSync(envPath)) {
  console.log('📝 Creating .env file...');
  
  const envContent = `# Supabase Configuration
SUPABASE_URL="https://your-project.supabase.co"
SUPABASE_SERVICE_KEY="your-supabase-service-role-key"

# JWT Secrets (generate secure keys for production)
JWT_SECRET="your-super-secret-jwt-key-here"
JWT_REFRESH_SECRET="your-super-secret-refresh-key-here"

# Server
PORT=4000
NODE_ENV=development

# SMS (for production - optional)
# SMS_API_KEY=your-sms-api-key
# SMS_API_URL=https://api.sms-provider.com
`;

  fs.writeFileSync(envPath, envContent);
  console.log('✅ .env file created');
} else {
  console.log('✅ .env file already exists');
}

console.log('\n📋 Next steps:');
console.log('1. Update SUPABASE_URL and SUPABASE_SERVICE_KEY in .env with your Supabase credentials');
console.log('2. Run: npm install');
console.log('3. Make sure you have run the SQL scripts in your Supabase database');
console.log('4. Run: npm run dev');
console.log('\n🚀 Your backend will be running on http://localhost:4000');
console.log('📖 API documentation available at http://localhost:4000/api/health');
