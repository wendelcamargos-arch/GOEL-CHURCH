-- Slice 03 — schema mínimo de AUTENTICAÇÃO (projeto Supabase PRINCIPAL).
-- Contém apenas o necessário para login/identidade. O perfil do membro
-- (cadastro) é do Slice 04. Dados pastorais sensíveis NÃO ficam aqui — vão no
-- projeto Supabase separado (Slices 08-09, adiados).

-- Estados do ciclo de vida da identidade (canônico — A1 §2.X).
do $$ begin
  create type identity_state as enum ('pre_registered', 'active', 'suspended', 'ended');
exception when duplicate_object then null; end $$;

-- Identidade: pessoa, referenciada pelo identificador canônico (A1 §2.X.2).
create table if not exists identities (
  id           uuid primary key default gen_random_uuid(),
  display_name text not null,
  state        identity_state not null default 'pre_registered',
  created_at   timestamptz not null default now()
);

-- Vínculo credencial → identidade. Uma credencial (número) pode vincular MAIS
-- DE UMA identidade (WhatsApp compartilhado — A1 §4).
create table if not exists phone_identity_links (
  phone_e164  text not null,
  identity_id uuid not null references identities(id) on delete cascade,
  primary key (phone_e164, identity_id)
);
create index if not exists idx_links_phone on phone_identity_links (phone_e164);

-- Desafios de OTP. O código NUNCA é armazenado em texto (apenas hash).
-- cooldown_until implementa o escalonamento REVERSÍVEL (A2.1B): nunca permanente.
create table if not exists otp_challenges (
  phone_e164     text primary key,
  code_hash      text not null,
  expires_at     timestamptz not null,
  attempts       int not null default 0,
  last_sent_at   timestamptz,
  cooldown_until timestamptz
);

-- RLS: estas tabelas são acessadas SOMENTE server-side (service role bypassa
-- RLS). Nenhuma policy pública → o cliente (anon/authenticated) não lê nem
-- escreve diretamente. Coerente com "autorização server-side" (P2A-02B).
alter table identities            enable row level security;
alter table phone_identity_links  enable row level security;
alter table otp_challenges        enable row level security;
