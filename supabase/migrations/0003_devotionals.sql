-- Slice 07 — devocionais (conteúdo próprio da igreja).
-- Leitura pública dos publicados; escrita apenas pela administração (server-side
-- / painel — fora do MVP mobile).

create table if not exists devotionals (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  body         text not null,
  author       text,
  published    boolean not null default false,
  published_at timestamptz not null default now()
);

alter table devotionals enable row level security;

-- Leitura pública apenas dos devocionais publicados.
drop policy if exists devotionals_public_read on devotionals;
create policy devotionals_public_read on devotionals
  for select using (published = true);

create index if not exists idx_devotionals_published_at
  on devotionals (published_at desc) where published = true;
