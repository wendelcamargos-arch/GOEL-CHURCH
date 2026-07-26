-- Slice 04 — perfil do membro (domínio Comunidade e Membros).
-- birth_date é DADO DE PERFIL (nunca autenticação). Sua finalidade é a
-- AUTOMAÇÃO DE ANIVERSÁRIO: envio automático de mensagem no WhatsApp, sem
-- intervenção humana. O envio depende de whatsapp_opt_in (consentimento).

create table if not exists member_profiles (
  identity_id     uuid primary key references identities(id) on delete cascade,
  full_name       text not null,
  birth_date      date not null,
  whatsapp_opt_in boolean not null default false,
  updated_at      timestamptz not null default now()
);

alter table member_profiles enable row level security;

-- Leitura do próprio perfil (sub do JWT = id canônico da identidade).
-- Escrita ocorre via Edge Function (service role); não há policy de escrita
-- para o cliente.
drop policy if exists own_profile_read on member_profiles;
create policy own_profile_read on member_profiles
  for select using (identity_id = auth.uid());

-- Aniversariantes do dia (fuso do Brasil — residência de dados BR).
-- Usada pela automação diária de aniversário.
create or replace function members_with_birthday_today()
returns table (identity_id uuid, full_name text, phone_e164 text)
language sql stable as $$
  select mp.identity_id, mp.full_name, l.phone_e164
  from member_profiles mp
  join phone_identity_links l on l.identity_id = mp.identity_id
  join identities i on i.id = mp.identity_id
  where mp.whatsapp_opt_in = true
    and i.state = 'active'
    and extract(month from mp.birth_date)
        = extract(month from (now() at time zone 'America/Sao_Paulo'))
    and extract(day from mp.birth_date)
        = extract(day from (now() at time zone 'America/Sao_Paulo'));
$$;

-- A função expõe telefones — restrita ao server-side (service role). Nenhum
-- cliente (anon/authenticated) pode executá-la.
revoke all on function members_with_birthday_today() from public, anon, authenticated;
