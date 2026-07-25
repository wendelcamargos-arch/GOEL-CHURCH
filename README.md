# Goel Church

> Uma igreja para você frequentar e uma família para você pertencer.

Aplicativo oficial da Goel Church. Este repositório contém a **camada de entrega
mobile (Flutter)** e o **domínio (Dart puro)**, construídos sobre a arquitetura
oficial já aprovada (Pacotes 1 e 2A).

## Stack (ratificada)

| Camada | Tecnologia |
|---|---|
| Frontend | Flutter (Android-first, iOS-ready) |
| Domínio | Dart puro (Framework Independence) |
| Backend / Auth / Storage | Supabase (região Brasil) |
| Execução server-side | Supabase Edge Functions |
| Banco | PostgreSQL (projeto separado para o domínio pastoral sensível) |
| Push | Firebase Cloud Messaging |
| Observabilidade | Sentry |
| Vídeos / Lives | YouTube |
| Autenticação | WhatsApp OTP (Meta Cloud API, token server-side) |

## Princípios que o código respeita

- **Framework Independence:** o domínio vive em `packages/goel_domain` e não
  importa Flutter.
- **Stable Module Boundaries:** módulos colaboram por superfície pública.
- **Acessibilidade (público idoso):** requisito arquitetural, não estético.
- **Offline-first** para conteúdo consultivo (Bíblia, devocionais, pregações).

## Roadmap do MVP (Vertical Slices)

| Slice | Escopo | Status |
|---|---|---|
| 01 | Bootstrap | ✅ |
| 02 | Integração Flutter + Supabase | ✅ |
| 03 | Login via WhatsApp OTP | ⏳ |
| 04 | Cadastro do membro | ⏳ |
| 05 | Home | ⏳ |
| 06 | Versículo do dia | ⏳ |
| 07 | Devocional | ⏳ |
| 08 | Pedido de oração | ⛔ adiado (LGPD — Parte B / Pacote 3) |
| 09 | Assistente Pastoral por IA | ⛔ adiado (LGPD — Parte B / Pacote 3) |

> Os Slices 08 e 09 tratam de dados sensíveis (religião + emoção) e permanecem
> **adiados** até a base legal, o consentimento e a estratégia de vinculação
> serem definidos na Parte B e no Pacote 3.

## Como rodar (ambiente com Flutter instalado)

```bash
flutter pub get
flutter test                     # testes de widget do app
dart test packages/goel_domain   # testes do domínio (Dart puro)

# Rodar com o Supabase conectado (credenciais injetadas no build — nunca no código):
flutter run \
  --dart-define=SUPABASE_URL=https://<seu-projeto>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<sua-anon-key>

# Sem --dart-define, o app roda em modo "Supabase não configurado" (degradação graciosa).
```

> A `anon key` é pública por natureza (uso no cliente). Credenciais privilegiadas
> e segredos (ex.: token da Meta Cloud API) ficam **server-side** em Edge
> Functions — nunca no app.

Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) para o mapeamento entre o código
e a arquitetura oficial.
