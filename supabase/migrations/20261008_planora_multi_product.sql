-- Planora multi-product license migration, phase 1
-- Run in Supabase SQL Editor after making a database backup.
-- Existing licenses are assigned to BUDGET automatically.
begin;
alter table public.planora_licenses
  add column if not exists product_code text;
update public.planora_licenses
  set product_code = 'BUDGET'
  where product_code is null;
alter table public.planora_licenses
  alter column product_code set default 'BUDGET';
alter table public.planora_licenses
  alter column product_code set not null;
alter table public.planora_licenses
  drop constraint if exists planora_licenses_product_code_check;
alter table public.planora_licenses
  add constraint planora_licenses_product_code_check
  check (product_code in ('BUDGET','GOLD'));
create index if not exists planora_licenses_product_code_idx
  on public.planora_licenses(product_code);
commit;

-- IMPORTANT: This migration only prepares the license table.
-- Before enabling Gold sales, review/update the existing
-- generate_planora_license and activate_planora RPC functions so
-- activation validates the license's product_code server-side.
-- Do not rely on a client-side product check for access control.
