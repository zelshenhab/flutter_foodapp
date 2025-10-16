-- Supabase SQL schema for the food ordering app
-- Run this inside Supabase SQL editor

-- 1) Users
create table if not exists users (
  user_id text primary key,
  name text not null default 'User',
  phone text not null unique,
  email text,
  address text not null default 'ул. Пушкина 15',
  notifications boolean not null default true,
  language_code text not null default 'ru',
  avatar_path text,
  created_at timestamp with time zone not null default now()
);

-- 2) Categories
create table if not exists categories (
  id text primary key,
  title text not null
);

-- 3) Menu items
create table if not exists menu_items (
  id text primary key,
  name text not null,
  price numeric(10,2) not null,
  image text not null,
  category_id text not null references categories(id) on delete restrict,
  desc text,
  created_at timestamp with time zone not null default now()
);
create index if not exists menu_items_category_idx on menu_items(category_id);

-- 4) Promos
create type if not exists promo_type as enum ('percent', 'fixed');
create table if not exists promos (
  id text primary key,
  title text not null,
  description text not null,
  type promo_type not null,
  amount numeric(10,2) not null,
  code text not null unique,
  valid_to timestamp with time zone
);
create index if not exists promos_valid_to_idx on promos(valid_to);

-- 5) Orders and items
create type if not exists order_status as enum ('pending','preparing','onTheWay','delivered','cancelled');
create table if not exists orders (
  id text primary key,
  user_id text not null references users(user_id) on delete cascade,
  created_at timestamp with time zone not null default now(),
  restaurant text not null default 'Адам и Ева',
  delivery_fee numeric(10,2) not null default 0,
  discount numeric(10,2) not null default 0,
  status order_status not null default 'pending'
);
create index if not exists orders_user_idx on orders(user_id);

create table if not exists order_items (
  id bigserial primary key,
  order_id text not null references orders(id) on delete cascade,
  item_id text not null references menu_items(id) on delete restrict,
  name text not null,
  price numeric(10,2) not null,
  qty integer not null check (qty > 0),
  image text not null
);
create index if not exists order_items_order_idx on order_items(order_id);

-- 6) Support messages
create table if not exists support_messages (
  id text primary key,
  user_id text references users(user_id) on delete set null,
  phone text,
  subject text not null,
  message text not null,
  created_at timestamp with time zone not null default now()
);

-- Sample seed (optional)
insert into categories (id, title) values
  ('shawarma','Шаурма'),('box','Бокс с шаурмой'),('roll','Ролл'),('eurobox','Евро-бокс'),
  ('pizza','Пицца'),('salads','Закуски и салаты'),('main','Основные блюда'),('breakfast','Завтрак'),('sauces','Соусы')
on conflict (id) do nothing;

-- Example promo seeds
insert into promos (id,title,description,type,amount,code,valid_to) values
  ('p1','Скидка новичкам','10% на первый заказ от 1000 ₽','percent',10,'WELCOME',null),
  ('p2','Комбо выходного','Скидка 300 ₽ при заказе от 1500 ₽','fixed',300,'WEEKEND300',null),
  ('p3','Бесплатный соус','Добавьте соус бесплатно к шаурме','fixed',50,'FREESAUCE',null)
  on conflict (id) do nothing;
