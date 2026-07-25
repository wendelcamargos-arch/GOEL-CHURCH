# Edge Functions — Autenticação (Slice 03)

Execução **server-side** do login por WhatsApp OTP. O token da Meta e o service
role do Supabase vivem **apenas aqui** — nunca no cliente.

## Funções

| Função | Papel |
|---|---|
| `request-otp` | Emite OTP via WhatsApp para números elegíveis. Resposta **uniforme** (anti-enumeração). |
| `verify-otp` | Valida o código. Escalonamento reversível. Resolve sessão ou seleção de identidade. |
| `select-identity` | Conclui a autenticação no caso de WhatsApp compartilhado. |

## Variáveis de ambiente (secrets)

```bash
supabase secrets set \
  META_WHATSAPP_TOKEN=... \
  META_WHATSAPP_PHONE_NUMBER_ID=... \
  META_WHATSAPP_OTP_TEMPLATE=goel_otp \
  META_WHATSAPP_OTP_TEMPLATE_LANG=pt_BR \
  OTP_PEPPER=<segredo-aleatório>
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
supabase db push                       # aplica a migração
supabase functions deploy request-otp
supabase functions deploy verify-otp
supabase functions deploy select-identity
```

> **Escopo/LGPD:** estas funções tratam identidade/telefone (domínio Comunidade
> e Membros), **não** dados pastorais sensíveis. Os Slices 08–09 permanecem
> adiados até a Parte B / Pacote 3.
