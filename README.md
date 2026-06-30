# Treino — app online

App de acompanhamento de treino com login (cada usuário só vê os próprios dados) e dados salvos no Supabase (Postgres na nuvem).

## 1. Criar o projeto Supabase (gratuito)

1. Acesse https://supabase.com e crie uma conta/projeto novo.
2. No painel do projeto, vá em **SQL Editor > New query**, cole o conteúdo de [`schema.sql`](schema.sql) e rode (`Run`).
3. Rode também, na sequência:
   - [`nutrition_schema.sql`](nutrition_schema.sql) (cria o sistema de nutrição)
   - [`foods_seed.sql`](foods_seed.sql) (popula o banco com a Tabela TACO — 591 alimentos brasileiros)
   - [`nutrition_schema_v2.sql`](nutrition_schema_v2.sql) (adiciona medidas caseiras, origem do alimento e cadastro de alimentos personalizados)
   - [`tbca_seed.sql`](tbca_seed.sql) (popula o banco com a Tabela TBCA/USP — ~5.600 alimentos brasileiros; arquivo grande, pode demorar para rodar)
   - [`usda_seed.sql`](usda_seed.sql) (popula o banco com a base USDA SR Legacy — ~7.800 alimentos; nomes traduzidos automaticamente do inglês, alguns itens de marca/pratos compostos podem ficar parcialmente em inglês; arquivo grande, pode demorar para rodar)
   - [`tucunduva_seed.sql`](tucunduva_seed.sql) (popula o banco com a Tabela Tucunduva Philippi — ~1.600 alimentos brasileiros)
   - [`ibge_seed.sql`](ibge_seed.sql) (popula o banco com a Tabela de Composição Nutricional dos Alimentos Consumidos no Brasil, IBGE/POF 2008-2009 — ~1.100 alimentos brasileiros preparados)
4. Vá em **Project Settings > API** e copie:
   - **Project URL**
   - **anon public key**
5. Abra [`config.js`](config.js) e cole esses dois valores no lugar de `COLE_AQUI_...`.
6. (Opcional, recomendado) Em **Authentication > Providers > Email**, desative "Confirm email" se quiser que o cadastro libere acesso na hora, sem precisar confirmar e-mail.

## 2. Testar localmente

Abra `index.html` direto no navegador (duplo clique) ou sirva a pasta com qualquer servidor estático. Crie uma conta na tela de login e use o app.

## 3. Publicar online (Vercel)

1. Crie um repositório no GitHub com esses arquivos (`index.html`, `config.js`).
2. Em https://vercel.com, clique **Add New > Project**, importe esse repositório.
3. Não precisa de build command nem framework — é um site estático. Clique **Deploy**.
4. Pronto: a Vercel vai gerar uma URL pública (ex: `treino-app.vercel.app`) acessível de qualquer aparelho.

Qualquer atualização que você fizer no `index.html` e enviar (`git push`) para o GitHub republica automaticamente.
