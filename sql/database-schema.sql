-- Run this file first in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 display_name text not null default 'Member' check (char_length(display_name)<=60),
 bio text default '' check (char_length(bio)<=250),
 currency text not null default 'BDT' check(currency in ('BDT','USD','EUR','GBP','INR')),
 avatar_url text, avatar_path text, monthly_income numeric(14,2) default 0 check(monthly_income>=0),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.user_roles (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 role text not null check(role in ('admin','moderator')),
 created_at timestamptz not null default now(), unique(user_id,role)
);
create table if not exists public.prayer_records (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 date date not null, fajr boolean, dhuhr boolean, asr boolean, maghrib boolean, isha boolean, notes text default '',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(user_id,date)
);
create table if not exists public.expenses (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 date date not null, spent_on date not null default current_date, amount numeric(14,2) not null check(amount>0), category text not null, description text default '',
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.trading_records (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 date date not null, instrument text not null, session text default 'Other', strategy text default '',
 entry_price numeric, stop_loss numeric, take_profit numeric, risk_percent numeric check(risk_percent is null or risk_percent>=0),
 planned_risk_amount numeric(14,2) check(planned_risk_amount is null or planned_risk_amount>=0),
 result text not null check(result in ('win','loss','breakeven')),
 winning_amount numeric(14,2) not null default 0 check(winning_amount>=0),
 losing_amount numeric(14,2) not null default 0 check(losing_amount>=0),
 notes text default '', created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 check(not (winning_amount>0 and losing_amount>0)),
 check((result<>'win' or winning_amount>0) and (result<>'loss' or losing_amount>0))
);
create table if not exists public.daily_tasks (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 title text not null check(char_length(title)<=120), description text default '', date date not null, completed boolean not null default false,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.announcements (
 id uuid primary key default gen_random_uuid(), title text not null check(char_length(title)<=120),
 body text not null check(char_length(body)<=1000), created_by uuid references auth.users(id) on delete set null,
 created_at timestamptz not null default now()
);

-- Compatibility migration: CREATE TABLE IF NOT EXISTS does not add columns
-- to tables that already existed. These ALTERs make this setup safe to rerun
-- against earlier versions of this project.
alter table public.profiles
  add column if not exists display_name text not null default 'Member',
  add column if not exists bio text default '',
  add column if not exists currency text not null default 'BDT',
  add column if not exists avatar_url text,
  add column if not exists avatar_path text,
  add column if not exists monthly_income numeric(14,2) not null default 0,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.prayer_records
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists date date not null default current_date,
  add column if not exists fajr boolean,
  add column if not exists dhuhr boolean,
  add column if not exists asr boolean,
  add column if not exists maghrib boolean,
  add column if not exists isha boolean,
  add column if not exists notes text not null default '',
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.expenses
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists date date not null default current_date,
  add column if not exists spent_on date,
  add column if not exists amount numeric(14,2) not null default 0,
  add column if not exists category text not null default 'Other',
  add column if not exists description text not null default '',
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- Keep both date column names compatible with earlier app/database versions.
update public.expenses
set date = coalesce(spent_on, date, created_at::date, current_date),
    spent_on = coalesce(spent_on, date, created_at::date, current_date);
alter table public.expenses alter column date set default current_date;
alter table public.expenses alter column spent_on set default current_date;
alter table public.expenses alter column date set not null;
alter table public.expenses alter column spent_on set not null;

alter table public.trading_records
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists date date not null default current_date,
  add column if not exists instrument text not null default 'UNKNOWN',
  add column if not exists session text not null default 'Other',
  add column if not exists strategy text not null default '',
  add column if not exists entry_price numeric,
  add column if not exists stop_loss numeric,
  add column if not exists take_profit numeric,
  add column if not exists risk_percent numeric,
  add column if not exists planned_risk_amount numeric(14,2),
  add column if not exists result text not null default 'breakeven',
  add column if not exists winning_amount numeric(14,2) not null default 0,
  add column if not exists losing_amount numeric(14,2) not null default 0,
  add column if not exists notes text not null default '',
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.daily_tasks
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists title text not null default 'Untitled task',
  add column if not exists description text not null default '',
  add column if not exists date date not null default current_date,
  add column if not exists completed boolean not null default false,
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.user_roles
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists role text not null default 'moderator',
  add column if not exists created_at timestamptz not null default now();

alter table public.announcements
  add column if not exists title text not null default 'Announcement',
  add column if not exists body text not null default '',
  add column if not exists created_by uuid references auth.users(id) on delete set null,
  add column if not exists created_at timestamptz not null default now();


create index if not exists prayer_user_date_idx on public.prayer_records(user_id,date);
create index if not exists expense_user_date_idx on public.expenses(user_id,date);
create index if not exists trading_user_date_idx on public.trading_records(user_id,date);
create index if not exists tasks_user_date_idx on public.daily_tasks(user_id,date);
create index if not exists roles_user_idx on public.user_roles(user_id);
create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at=now(); return new; end; $$;
do $$ declare t text; begin foreach t in array array['profiles','prayer_records','expenses','trading_records','daily_tasks'] loop
 execute format('drop trigger if exists set_updated_at on public.%I',t);
 execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()',t);
end loop; end $$;
-- Create a profile automatically at signup. Client code also handles missing profiles safely.
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,display_name) values(new.id,coalesce(new.raw_user_meta_data->>'display_name',split_part(new.email,'@',1))) on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
-- Admin check and aggregate stats run with controlled definer rights.
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.user_roles where user_id=auth.uid() and role='admin'); $$;
create or replace function public.admin_platform_stats() returns json language plpgsql stable security definer set search_path=public as $$
begin
 if not public.is_admin() then raise exception 'Administrator access required'; end if;
 return json_build_object(
 'total_users',(select count(*) from auth.users),
 'total_profiles',(select count(*) from public.profiles),
 'prayer_records',(select count(*) from public.prayer_records),
 'expense_records',(select count(*) from public.expenses)
 );
end; $$;
revoke all on function public.admin_platform_stats() from public, anon;
grant execute on function public.admin_platform_stats() to authenticated;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;
