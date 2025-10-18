import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error('❌ Missing Supabase environment variables:');
  console.error('SUPABASE_URL:', supabaseUrl ? '✅ Set' : '❌ Missing');
  console.error('SUPABASE_SERVICE_KEY:', supabaseServiceKey ? '✅ Set' : '❌ Missing');
  console.error('');
  console.error('Please check your .env file and make sure it contains:');
  console.error('SUPABASE_URL="https://your-project.supabase.co"');
  console.error('SUPABASE_SERVICE_KEY="your-service-role-key"');
  throw new Error('Missing Supabase environment variables. Please set SUPABASE_URL and SUPABASE_SERVICE_KEY');
}

export const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Database interface to match your schema
export interface User {
  id: number;
  phone: string;
  name?: string;
  avatarUrl?: string;
  createdAt: string;
}

export interface Category {
  id: number;
  title: string;
  slug: string;
  position: number;
}

export interface MenuItem {
  id: number;
  categoryId: number;
  title: string;
  slug: string;
  description?: string;
  imageUrl?: string;
  basePrice: number;
  isActive: boolean;
  isPopular: boolean;
}

export interface Cart {
  id: number;
  userId: number;
  promoCode?: string;
  updatedAt: string;
}

export interface CartItem {
  id: number;
  cartId: number;
  menuItemId: number;
  quantity: number;
  unitPriceSnapshot: number;
  optionsJson?: any;
  lineTotal: number;
}

export interface Order {
  id: number;
  userId: number;
  status: 'pending' | 'preparing' | 'delivering' | 'completed' | 'cancelled';
  paymentMethod: 'cod' | 'card';
  paymentStatus?: string;
  subtotal: number;
  discount: number;
  deliveryFee: number;
  total: number;
  addressSnapshot: any;
  promoCode?: string;
  notes?: string;
  createdAt: string;
}

export interface OrderItem {
  id: number;
  orderId: number;
  menuItemId: number;
  titleSnap: string;
  optionsSnap?: any;
  unitPrice: number;
  quantity: number;
  lineTotal: number;
}

export interface Promo {
  id: number;
  code: string;
  title: string;
  description?: string;
  type: 'percent' | 'fixed';
  value: number;
  validFrom?: string;
  validTo?: string;
  minSubtotal?: number;
  active: boolean;
}
