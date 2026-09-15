create extension if not exists pgcrypto;

create table if not exists households (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  invite_code text not null unique default upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 10)),
  created_at timestamptz not null default now()
);

create table if not exists household_members (
  household_id uuid not null references households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (household_id, user_id)
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  status text not null check (status in ('purchased', 'considering')),
  name text not null,
  product_code text,
  category text not null default 'Diğer',
  image text,
  original_price text,
  purchased_price text,
  link text,
  description text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function is_household_member(target_household_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from household_members
    where household_id = target_household_id
      and user_id = auth.uid()
  );
$$;

alter table households enable row level security;
alter table household_members enable row level security;
alter table products enable row level security;

drop policy if exists "Members view households" on households;
drop policy if exists "Members view memberships" on household_members;
drop policy if exists "Members manage shared products" on products;

create policy "Members view households"
on households for select to authenticated
using (is_household_member(id));

create policy "Members view memberships"
on household_members for select to authenticated
using (is_household_member(household_id));

create policy "Members manage shared products"
on products for all to authenticated
using (is_household_member(household_id))
with check (is_household_member(household_id));

create or replace function create_household(household_name text)
returns households
language plpgsql
security definer
set search_path = public
as $$
declare
  created_household households;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into households (name)
  values (trim(household_name))
  returning * into created_household;

  insert into household_members (household_id, user_id)
  values (created_household.id, auth.uid());

  return created_household;
end;
$$;

create or replace function join_household(invitation_code text)
returns households
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_household households;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  select * into selected_household
  from households
  where invite_code = upper(trim(invitation_code));

  if selected_household.id is null then
    raise exception 'Invalid invitation code';
  end if;

  insert into household_members (household_id, user_id)
  values (selected_household.id, auth.uid())
  on conflict (household_id, user_id) do nothing;

  return selected_household;
end;
$$;

grant execute on function is_household_member(uuid) to authenticated;
grant execute on function create_household(text) to authenticated;
grant execute on function join_household(text) to authenticated;
