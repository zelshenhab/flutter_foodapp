# FoodApp Backend

A Node.js/Express backend for the Flutter food delivery app with Supabase integration.

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up environment variables:**
   Create a `.env` file in the root directory with:
   ```env
   # Supabase Configuration
   SUPABASE_URL="https://your-project.supabase.co"
   SUPABASE_SERVICE_KEY="your-supabase-service-role-key"
   
   # JWT
   JWT_SECRET="your-super-secret-jwt-key-here"
   JWT_REFRESH_SECRET="your-super-secret-refresh-key-here"
   
   # Server
   PORT=4000
   NODE_ENV=development
   ```

3. **Set up database:**
   Run the SQL scripts provided in your Supabase SQL editor:
   - Script 1: Users + Auth tables
   - Script 2: Menu + Promos tables
   - Script 3: Enums + Cart + Orders tables
   - Script 4: Indexes
   - Script 5: Seed sample data

4. **Start the server:**
   ```bash
   npm run dev
   ```

## API Endpoints

### Authentication
- `POST /api/auth/otp/request` - Request OTP code
- `POST /api/auth/otp/verify` - Verify OTP code
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user

### Menu
- `GET /api/menu/categories` - Get menu categories
- `GET /api/menu/items?category=shawarma` - Get menu items

### Cart
- `GET /api/cart` - Get user's cart
- `POST /api/cart/items` - Add item to cart
- `DELETE /api/cart/items/:id` - Remove item from cart
- `POST /api/cart/apply-promo` - Apply promo code

### Orders
- `GET /api/orders` - Get user's orders
- `GET /api/orders/:id` - Get order details
- `POST /api/orders/preview` - Preview order
- `POST /api/orders` - Create order

### Support
- `POST /api/support` - Submit support ticket

### Promos
- `GET /api/promos` - Get available promos
- `GET /api/promos/:code` - Validate promo code

## Database Schema

The app uses PostgreSQL with the following main entities:
- Users (phone-based authentication)
- Categories and MenuItems
- Cart and CartItems
- Orders and OrderItems
- Promos
- Support tickets

## Features

- Phone-based authentication with OTP
- Menu browsing with categories
- Shopping cart functionality
- Order management
- Promo code system
- Support ticket system
