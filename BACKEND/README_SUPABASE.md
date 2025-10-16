## Supabase setup

1) Open Supabase SQL editor and run `supabase_schema.sql` from this folder.
2) Add env vars in `BACKEND/.env`:
```
SUPABASE_URL=your-url
SUPABASE_ANON_KEY=your-anon-key
# if you want write/admin access via backend only
# SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
JWT_SECRET=change_me
```
3) Start backend:
```
cd BACKEND
npm install
npm run build
node dist/index.js
```

## Endpoints
- GET `/health`
- POST `/api/auth/send-otp` { phone }
- POST `/api/auth/verify-otp` { phone, code } -> { token, user }
- GET `/api/users/me` (Bearer token)
- PATCH `/api/users/me` (Bearer token)
- GET `/api/menu/categories`
- GET `/api/menu/categories/:categoryId/items`
- GET `/api/menu/items/:itemId`
- GET `/api/promos`
- POST `/api/promos/validate` { code }
- GET `/api/orders` (Bearer token)
- POST `/api/orders` (Bearer token)
- GET `/api/orders/:orderId` (Bearer token)
- POST `/api/support` (optional Bearer token)
