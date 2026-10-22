-- Elvoria setup for the project and owner UID supplied by the store owner.
-- Run in Supabase Dashboard > SQL Editor. Safe to run again: policies are replaced by name.

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  product_type text not null default 'Phone case',
  description text default '',
  price numeric(10,2) not null default 25 check (price >= 0),
  image_url text default '',
  images jsonb not null default '[]'::jsonb,
  iphone_models jsonb not null default '[]'::jsonb,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.platforms (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

grant select on public.products, public.platforms to anon, authenticated;
grant insert, update, delete on public.products, public.platforms to authenticated;

alter table public.products enable row level security;
alter table public.platforms enable row level security;

drop policy if exists "Public can view active products" on public.products;
create policy "Public can view active products"
on public.products for select to anon, authenticated
using (is_active or auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid);

drop policy if exists "Owner manages products" on public.products;
create policy "Owner manages products"
on public.products for all to authenticated
using (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid)
with check (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid);

drop policy if exists "Public can view active platforms" on public.platforms;
create policy "Public can view active platforms"
on public.platforms for select to anon, authenticated
using (is_active or auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid);

drop policy if exists "Owner manages platforms" on public.platforms;
create policy "Owner manages platforms"
on public.platforms for all to authenticated
using (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid)
with check (auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid);

-- Public bucket means shoppers can view product photos; only the owner can upload/change/delete them.
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Owner uploads product images" on storage.objects;
create policy "Owner uploads product images"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'product-images'
  and auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid
);

drop policy if exists "Owner views product image files" on storage.objects;
create policy "Owner views product image files"
on storage.objects for select to authenticated
using (
  bucket_id = 'product-images'
  and auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid
);

drop policy if exists "Owner updates product images" on storage.objects;
create policy "Owner updates product images"
on storage.objects for update to authenticated
using (
  bucket_id = 'product-images'
  and auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid
)
with check (
  bucket_id = 'product-images'
  and auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid
);

drop policy if exists "Owner deletes product images" on storage.objects;
create policy "Owner deletes product images"
on storage.objects for delete to authenticated
using (
  bucket_id = 'product-images'
  and auth.uid() = 'f6211fb3-abff-4e3c-ac42-e55274d0fe03'::uuid
);
