-- Run after database-schema.sql. RLS is the security boundary; never rely on UI hiding.
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.prayer_records enable row level security;
alter table public.expenses enable row level security;
alter table public.trading_records enable row level security;
alter table public.daily_tasks enable row level security;
alter table public.announcements enable row level security;
-- Profiles: a user may see/update only their own profile.
drop policy if exists "profile own select" on public.profiles;
create policy "profile own select" on public.profiles for select to authenticated using(id=auth.uid() or public.is_admin());
drop policy if exists "profile own insert" on public.profiles;
create policy "profile own insert" on public.profiles for insert to authenticated with check(id=auth.uid());
drop policy if exists "profile own update" on public.profiles;
create policy "profile own update" on public.profiles for update to authenticated using(id=auth.uid()) with check(id=auth.uid());
-- Users cannot grant themselves a role. Role rows are only readable by the role owner/admin; no client writes.
drop policy if exists "roles own or admin read" on public.user_roles;
create policy "roles own or admin read" on public.user_roles for select to authenticated using(user_id=auth.uid() or public.is_admin());
-- User-owned data policies.
do $$ declare t text; begin foreach t in array array['prayer_records','expenses','trading_records','daily_tasks'] loop
 execute format('drop policy if exists "owner select" on public.%I',t);
 execute format('create policy "owner select" on public.%I for select to authenticated using(user_id=auth.uid() or public.is_admin())',t);
 execute format('drop policy if exists "owner insert" on public.%I',t);
 execute format('create policy "owner insert" on public.%I for insert to authenticated with check(user_id=auth.uid())',t);
 execute format('drop policy if exists "owner update" on public.%I',t);
 execute format('create policy "owner update" on public.%I for update to authenticated using(user_id=auth.uid()) with check(user_id=auth.uid())',t);
 execute format('drop policy if exists "owner delete" on public.%I',t);
 execute format('create policy "owner delete" on public.%I for delete to authenticated using(user_id=auth.uid())',t);
end loop; end $$;
drop policy if exists "announcements authenticated read" on public.announcements;
create policy "announcements authenticated read" on public.announcements for select to authenticated using(true);
drop policy if exists "admin announcement insert" on public.announcements;
create policy "admin announcement insert" on public.announcements for insert to authenticated with check(public.is_admin() and created_by=auth.uid());
drop policy if exists "admin announcement delete" on public.announcements;
create policy "admin announcement delete" on public.announcements for delete to authenticated using(public.is_admin());
-- IMPORTANT: user_roles has no INSERT/UPDATE/DELETE policy. Only trusted SQL/dashboard operators may assign roles.
