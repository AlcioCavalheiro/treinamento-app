-- Rode isso no SQL Editor do seu projeto Supabase (Supabase Dashboard > SQL Editor > New query)

create table if not exists public.training_data (
  user_id uuid references auth.users(id) on delete cascade primary key,
  loads jsonb not null default '{}'::jsonb,
  checks jsonb not null default '{}'::jsonb,
  recovery jsonb not null default '{}'::jsonb,
  runs jsonb not null default '[]'::jsonb,
  tiros jsonb not null default '[]'::jsonb,
  muscobs jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Se a tabela já existia antes (sem a coluna muscobs), rode também:
alter table public.training_data add column if not exists muscobs jsonb not null default '{}'::jsonb;

alter table public.training_data enable row level security;

create policy "Users can view own data"
  on public.training_data for select
  using (auth.uid() = user_id);

create policy "Users can insert own data"
  on public.training_data for insert
  with check (auth.uid() = user_id);

create policy "Users can update own data"
  on public.training_data for update
  using (auth.uid() = user_id);
