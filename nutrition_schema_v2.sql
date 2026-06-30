-- nutrition_schema_v2.sql
-- Rode DEPOIS de nutrition_schema.sql e foods_seed.sql.
-- Adiciona suporte a múltiplas tabelas de alimentos (TACO, TBCA, custom),
-- medidas caseiras e cadastro de alimentos personalizados.

-- ===================== Novos campos na tabela foods =====================
alter table public.foods
  add column if not exists origem text not null default 'taco',
  add column if not exists tbca_codigo text;

-- Índice único parcial para código TBCA (só onde não é null)
create unique index if not exists foods_tbca_codigo_idx
  on public.foods (tbca_codigo) where tbca_codigo is not null;

-- Garante que proteina/carbo/gordura aceitam null (TACO tem alimentos com valores ausentes)
alter table public.foods alter column proteina drop not null;
alter table public.foods alter column carbo drop not null;
alter table public.foods alter column gordura drop not null;

-- ===================== Medidas caseiras =====================
-- Tabela global de medidas. Cada alimento pode usar qualquer medida.
-- gramas = peso em gramas correspondente a 1 unidade da medida.

create table if not exists public.food_measures (
  id bigint generated always as identity primary key,
  nome text not null,      -- "Colher de sopa"
  abrev text not null,     -- "col. sopa"
  gramas numeric not null  -- peso médio em gramas de 1 unidade
);

alter table public.food_measures enable row level security;

create policy "Authenticated users can view measures"
  on public.food_measures for select
  using (auth.role() = 'authenticated');

-- Semente: medidas caseiras brasileiras padrão
insert into public.food_measures (nome, abrev, gramas) values
  ('Grama',             'g',         1),
  ('Colher de café',    'col. café',  3),
  ('Colher de chá',     'col. chá',   5),
  ('Colher de sobremesa','col. sobr.', 10),
  ('Colher de sopa',    'col. sopa',  15),
  ('Concha pequena',    'concha p.',  60),
  ('Concha média',      'concha m.', 90),
  ('Concha grande',     'concha g.', 120),
  ('Xícara de café',    'xíc. café', 50),
  ('Xícara de chá',     'xíc. chá',  200),
  ('Copo americano',    'copo am.',  200),
  ('Copo duplo',        'copo dup.', 350),
  ('Copo de requeijão', 'copo req.', 200),
  ('Prato raso',        'prato',     200),
  ('Prato fundo',       'prato f.',  300),
  ('Fatia fina',        'fatia f.',   25),
  ('Fatia média',       'fatia m.',   40),
  ('Fatia grossa',      'fatia g.',   60),
  ('Unidade pequena',   'un. p.',     80),
  ('Unidade média',     'un. m.',    150),
  ('Unidade grande',    'un. g.',    250),
  ('Porção (100g)',      'porção',   100),
  ('Sachê',             'sachê',      20),
  ('Tablete',           'tablete',    25),
  ('Barra',             'barra',      40),
  ('Bisnaga pequena',   'bisn. p.',   50),
  ('Bisnaga grande',    'bisn. g.',  100),
  ('Pacote',            'pacote',    100)
on conflict do nothing;

-- ===================== Política para custom foods =====================
-- Alunos podem inserir alimentos com is_custom=true; personal também
drop policy if exists "Users can add custom foods" on public.foods;
create policy "Authenticated users can add custom foods"
  on public.foods for insert
  with check (auth.uid() = created_by and is_custom = true);

create policy "Personal can insert any food"
  on public.foods for insert
  with check (public.is_personal());

-- ===================== Índice de busca full-text (if not exists) =====================
create index if not exists foods_nome_idx on public.foods using gin (to_tsvector('portuguese', nome));
