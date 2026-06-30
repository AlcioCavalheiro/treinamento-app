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

-- Plano de treino do aluno (montado pelo personal). Null = usa o plano padrão do app.
alter table public.training_data add column if not exists plan jsonb;

-- Histórico de natação registrado pelo aluno.
alter table public.training_data add column if not exists swims jsonb not null default '[]'::jsonb;

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

-- ===================== Perfis (aluno / personal) =====================

create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  role text not null default 'aluno' check (role in ('aluno','personal')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Cria o perfil automaticamente quando alguém cria conta (signUp)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email) values (new.id, new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Função auxiliar (security definer, ignora RLS) pra checar se quem está logado é personal,
-- sem cair em recursão de policy.
create or replace function public.is_personal()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists(select 1 from public.profiles where id = auth.uid() and role = 'personal');
$$;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Personal can view all profiles"
  on public.profiles for select
  using (public.is_personal());

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

-- Personal enxerga e edita o training_data de qualquer aluno
create policy "Personal can view all training_data"
  on public.training_data for select
  using (public.is_personal());

create policy "Personal can update all training_data"
  on public.training_data for update
  using (public.is_personal());

create policy "Personal can insert training_data for anyone"
  on public.training_data for insert
  with check (public.is_personal());

-- ===================== Como virar "personal" =====================
-- 1. Crie a conta normalmente pela tela de login do app (aba "Criar conta").
-- 2. Rode no SQL Editor, trocando pelo e-mail da conta:
--
--   update public.profiles set role = 'personal' where email = 'email-do-personal@exemplo.com';
--
