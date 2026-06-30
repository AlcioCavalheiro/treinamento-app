-- Rode isso no SQL Editor do Supabase, DEPOIS de já ter rodado schema.sql.
-- Cria o sistema de acompanhamento nutricional (anamnese, plano alimentar, diário e peso).

-- ===================== Banco de alimentos =====================
-- Catálogo compartilhado (não é por usuário). Semente: Tabela TACO (UNICAMP/NEPA, dados abertos),
-- valores por 100g. Alunos/personal também podem cadastrar alimentos próprios (is_custom).

create table if not exists public.foods (
  id bigint generated always as identity primary key,
  taco_id int unique,
  nome text not null,
  grupo text,
  kcal numeric not null,
  proteina numeric not null default 0,
  carbo numeric not null default 0,
  gordura numeric not null default 0,
  fibra numeric,
  sodio numeric,
  is_custom boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists foods_nome_idx on public.foods using gin (to_tsvector('portuguese', nome));

alter table public.foods enable row level security;

create policy "Anyone logged in can view foods"
  on public.foods for select
  using (auth.role() = 'authenticated');

create policy "Users can add custom foods"
  on public.foods for insert
  with check (auth.uid() = created_by and is_custom = true);

-- ===================== Dados nutricionais por aluno =====================
-- Mesmo padrão do training_data: 1 linha por aluno.
-- anamnese: dados físicos + metas calculadas (preenchido pelo personal).
-- meal_plan: refeições sugeridas pelo personal (jsonb, estrutura livre no app).
-- food_log: registro diário do que o aluno comeu (array jsonb).
-- weight_log: histórico de peso/medidas (array jsonb).

create table if not exists public.nutrition_data (
  user_id uuid references auth.users(id) on delete cascade primary key,
  anamnese jsonb not null default '{}'::jsonb,
  meal_plan jsonb not null default '{}'::jsonb,
  food_log jsonb not null default '[]'::jsonb,
  weight_log jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.nutrition_data enable row level security;

create policy "Users can view own nutrition data"
  on public.nutrition_data for select
  using (auth.uid() = user_id);

create policy "Users can insert own nutrition data"
  on public.nutrition_data for insert
  with check (auth.uid() = user_id);

create policy "Users can update own nutrition data"
  on public.nutrition_data for update
  using (auth.uid() = user_id);

-- Personal enxerga e edita o nutrition_data de qualquer aluno (reaproveita is_personal() do schema.sql)
create policy "Personal can view all nutrition_data"
  on public.nutrition_data for select
  using (public.is_personal());

create policy "Personal can update all nutrition_data"
  on public.nutrition_data for update
  using (public.is_personal());

create policy "Personal can insert nutrition_data for anyone"
  on public.nutrition_data for insert
  with check (public.is_personal());

-- ===================== Semente do banco de alimentos (TACO) =====================
-- Rode o arquivo foods_seed.sql na sequência (591 alimentos, ~55KB de INSERT).
