-- Wendy's Goals — Supabase database schema
-- Paste this whole file into Supabase → SQL Editor → New query, then click Run.
-- It is safe to run more than once.

-- ─────────────────────────────────────────────────────────────
-- GOALS: every trackable item (supplements, water, steps, Spanish,
-- declutter, piano, etc.). A goal stays the same day after day until
-- Wendy changes it.
--   track  = 'check'   → done / not done (optionally N times a week/month)
--            'minutes' → time logged (per day, or per week/month)
--            'count'   → a number for the day (water glasses, steps)
--   period = 'day' | 'week' | 'month'
--   times  = how many times per week/month (1 for daily goals)
--   amount = minutes per time (minutes goals) or daily target (count goals)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.goals (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  section      text not null check (section in ('health','intellect','home','spiritual','music','family','prep')),
  grp          text,                        -- optional list it belongs to, e.g. 'Supplements', 'Exercise'
  name         text not null,
  track        text not null check (track in ('check','minutes','count')),
  amount       integer check (amount is null or amount >= 0),
  period       text not null default 'day' check (period in ('day','week','month')),
  times        integer not null default 1 check (times >= 1),
  unit         text,                        -- for count goals: 'glasses', 'steps'
  entry        text not null default 'tap' check (entry in ('tap','number')),
  action_label text,                        -- e.g. 'I finished a book'
  note_label   text,                        -- e.g. 'Now reading'
  details      text,                        -- the note itself, e.g. the book title
  sort_order   integer not null default 0,
  active       boolean not null default true,
  created_at   timestamptz not null default now()
);

-- LOGS: one row each time Wendy checks something off or logs time.
-- For count goals (water, steps) there is one row per day holding the number.
create table if not exists public.logs (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  goal_id    uuid not null references public.goals(id) on delete cascade,
  log_date   date not null,
  minutes    integer check (minutes is null or minutes >= 0),
  count      integer check (count is null or count >= 0),
  created_at timestamptz not null default now()
);
create index if not exists logs_user_date_idx on public.logs (user_id, log_date);
create index if not exists logs_goal_idx on public.logs (goal_id);

-- MINISTERING: the people Wendy ministers to, and each contact with them.
create table if not exists public.people (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name       text not null,
  every_days integer not null default 14 check (every_days > 0),   -- 7, 14, 30, 90
  sort_order integer not null default 0,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.contacts (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  person_id    uuid not null references public.people(id) on delete cascade,
  kind         text not null check (kind in ('visit','call','text','card','brought')),
  contact_date date not null,
  notes        text,
  created_at   timestamptz not null default now()
);
create index if not exists contacts_person_idx on public.contacts (person_id, contact_date desc);

-- REFLECTIONS: the daily Christlike-attribute self-evaluation (scores 1–5).
create table if not exists public.reflections (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  ref_date   date not null,
  scores     jsonb not null default '{}'::jsonb,  -- {"faith":4,"hope":5,...}
  thoughts   text,
  updated_at timestamptz not null default now(),
  primary key (user_id, ref_date)
);

-- ─────────────────────────────────────────────────────────────
-- SECURITY: Row Level Security so a signed-in user can only ever see and
-- change her own rows. This is what makes it safe for the public "anon"
-- key to live in config.js on GitHub Pages.
-- ─────────────────────────────────────────────────────────────
alter table public.goals       enable row level security;
alter table public.logs        enable row level security;
alter table public.people      enable row level security;
alter table public.contacts    enable row level security;
alter table public.reflections enable row level security;

drop policy if exists "own goals" on public.goals;
create policy "own goals" on public.goals for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "own logs" on public.logs;
create policy "own logs" on public.logs for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid()
              and exists (select 1 from public.goals g where g.id = goal_id and g.user_id = auth.uid()));

drop policy if exists "own people" on public.people;
create policy "own people" on public.people for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "own contacts" on public.contacts;
create policy "own contacts" on public.contacts for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid()
              and exists (select 1 from public.people p where p.id = person_id and p.user_id = auth.uid()));

drop policy if exists "own reflections" on public.reflections;
create policy "own reflections" on public.reflections for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Table permissions for signed-in users (Supabase usually grants these already).
grant select, insert, update, delete on public.goals, public.logs, public.people,
  public.contacts, public.reflections to authenticated;
