# Edge Functions — Autenticação (Slice 03)

Execução **server-side** do login por WhatsApp OTP. O token da Meta e o service
role do Supabase vivem **apenas aqui** — nunca no cliente.

## Funções

| Função | Papel |
|---|---|
| `request-otp` | Emite OTP via WhatsApp para números elegíveis. Resposta **uniforme** (anti-enumeração). |
| `verify-otp` | Valida o código. Escalonamento reversível. Resolve sessão ou seleção de identidade. |
| `select-identity` | Conclui a autenticação no caso de WhatsApp compartilhado. |
| `save-profile` | Salva o perfil do membro (valida a sessão; upsert server-side). Slice 04. |
| `birthday-greetings` | **Agendada** — envia a saudação automática de aniversário. Slice 04. |
| `verse-of-the-day` | Versículo do dia (NVI) de API bíblica **licenciada**, chave server-side. Slice 06. |

### Conteúdo bíblico (Slice 06) — licenciamento

A **NVI é conteúdo licenciado** (Biblica), não é domínio público. `verse-of-the-day`
busca o texto de uma **API bíblica licenciada** (ex.: API.Bible) com a chave
protegida server-side. Configure:

```bash
supabase secrets set \
  BIBLE_API_URL=https://api.scripture.api.bible \
  BIBLE_API_KEY=<sua-chave> \
  BIBLE_NVI_ID=<id-da-NVI-na-API>
supabase functions deploy verse-of-the-day
```

Sem essas chaves, o app usa um **fallback offline de domínio público**. A licença
da NVI e a curadoria do conteúdo são responsabilidade do owner.

## Variáveis de ambiente (secrets)

```bash
supabase secrets set \
  META_WHATSAPP_TOKEN=... \
  META_WHATSAPP_PHONE_NUMBER_ID=... \
  META_WHATSAPP_OTP_TEMPLATE=goel_otp \
  META_WHATSAPP_OTP_TEMPLATE_LANG=pt_BR \
  META_WHATSAPP_BIRTHDAY_TEMPLATE=goel_aniversario \
  META_WHATSAPP_BIRTHDAY_TEMPLATE_LANG=pt_BR \
  OTP_PEPPER=<segredo-aleatório> \
  SCHEDULER_SECRET=<segredo-do-agendador>
# SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY e SUPABASE_JWT_SECRET já são
# providos pelo runtime das Edge Functions.
```

Parâmetros operacionais opcionais (têm defaults sensatos; são calibração, não
arquitetura): `OTP_DIGITS`, `OTP_TTL_SECONDS`, `OTP_MAX_ATTEMPTS`,
`OTP_RESEND_GAP_SECONDS`, `OTP_COOLDOWN_BASE_SECONDS`, `SESSION_TTL_SECONDS`.

## Pré-requisitos externos (do seu lado)

1. **Meta WhatsApp Business API** com número verificado e um **template de
   autenticação aprovado** (`META_WHATSAPP_OTP_TEMPLATE`).
2. Migração `supabase/migrations/0001_auth.sql` aplicada.
3. Membros **pré-registrados** (enrollment controlado): inserir em `identities`
   (state `pre_registered`) e `phone_identity_links`.

## Deploy

```bash
supabase db push                       # migrações: 0001 auth, 0002 perfil, 0003 devocionais
supabase functions deploy request-otp
supabase functions deploy verify-otp
supabase functions deploy select-identity
supabase functions deploy save-profile
supabase functions deploy birthday-greetings
```

### Agendar a automação de aniversário (diária, ~08:00 BRT)

Configure um agendamento (Supabase Scheduled Functions / pg_cron) para chamar
`birthday-greetings` uma vez ao dia, enviando o header `x-scheduler-secret`.
Ex.: cron `0 11 * * *` (UTC) ≈ 08:00 America/Sao_Paulo. Requer um template de
aniversário aprovado (`META_WHATSAPP_BIRTHDAY_TEMPLATE`).

> **Escopo/LGPD:** estas funções tratam identidade/telefone (domínio Comunidade
> e Membros), **não** dados pastorais sensíveis. Os Slices 08–09 permanecem
> adiados até a Parte B / Pacote 3.
