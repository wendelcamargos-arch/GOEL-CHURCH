# GOEL COMMUNITY PLATFORM — Arquitetura Diretora (V2.0)

> **Documento oficial da plataforma V2.0.** Apenas planejamento — **nenhuma
> implementação, nenhum código**. A Release **1.1.0 permanece congelada**.
>
> **Evolução de nome:** o antigo "Message Hub" deixa de ser um módulo isolado e
> passa a integrar esta plataforma maior. Nomes de trabalho anteriores
> ("Goel Church Backend Platform") ficam **substituídos** por **GOEL COMMUNITY
> PLATFORM** (nome oficial). O `docs/v2/goel-message-hub.md` passa a detalhar o
> **Módulo 1 — Atendimento**.

## Objetivo

**Centralizar todo o relacionamento da igreja** — atendimento, comunidade,
membros, comunicação e inteligência — sobre um **backend próprio** (Goel), com
moderação, histórico, auditoria e governança LGPD. O **WhatsApp deixa de ser o
destino principal** e passa a ser **apenas um dos canais** de saída.

## Arquitetura geral

```
┌──────────┐   ┌──────────────┐   ┌────────────────────┐   ┌───────────┐   ┌───────────────────────┐
│   APP    │──▶│ BACKEND GOEL │──▶│ PAINEL ADMIN (web) │──▶│  EQUIPE   │──▶│  CANAL DE SAÍDA        │
│ (membro) │   │ Supabase:    │   │ moderação/gestão   │   │ responsáv.│   │  WhatsApp Business ·   │
│          │   │ Auth·RLS·    │   │ filas·aprovação·   │   │           │   │  Push · E-mail ·       │
│          │◀──│ Postgres·    │   │ auditoria·config   │   │           │   │  Comunicados           │
└──────────┘   │ Edge·Storage │   └────────────────────┘   └───────────┘   └───────────────────────┘
               │ ·Realtime    │
               └──────────────┘
```

**Princípios:** framework independence (domínio em Dart puro), offline-first
onde couber, **RLS** em todas as tabelas, escrita sensível via Edge Functions
autenticadas, **auditoria imutável**, PII restrita por papel. **Sem Firebase.**

---

## MÓDULO 1 — ATENDIMENTO
Pedidos de Oração · Testemunhos · Quero Ser Servo · Gabinete Pastoral

- **Arquitetura:** app envia solicitações ao Backend Goel; entram em **fila de
  moderação**; equipe aprova; publicação por **canal de saída** (WhatsApp
  Business e/ou grupo). Detalhe completo em `docs/v2/goel-message-hub.md`.
- **Banco:** `submissions` (type, autor, corpo, visibilidade, status, consent),
  `moderation_actions` (auditoria), `publications` (canal, alvo, método),
  `pastoral_cases` (gabinete: caso, responsável, situação).
- **Fluxo:** enviar → PENDENTE → moderar → APROVADO → publicado/atendido →
  CONCLUÍDO (auditoria em cada passo).
- **Permissões:** Membro (cria/lê o seu); Moderador (fila, aprovar/rejeitar);
  Pastoral (gabinete); Admin (tudo + config).
- **LGPD:** consentimento por finalidade; anonimização; retenção; revogação.
- **Integrações:** WhatsApp Business (saída), Push (aviso à equipe).
- **Roadmap:** Fase 1 captura+fila+moderação (publicação manual) → Fase 2
  templates/anonimização → Fase 3 WhatsApp Business assistido.

## MÓDULO 2 — COMUNIDADE
Goel Home · Pequenos Grupos · Eventos · Integrações

- **Arquitetura:** catálogo de grupos/eventos no Backend; inscrição e presença;
  "integrações" = jornada de acolhimento do novo membro.
- **Banco:** `small_groups` (nome, líder, local, horário), `group_members`
  (grupo↔membro), `events` (evento, data, local), `event_rsvp`,
  `integration_journey` (etapas do acolhimento).
- **Fluxo:** descobrir grupo/evento → inscrever/confirmar → participar →
  acompanhamento de presença/crescimento.
- **Permissões:** Membro (ver/inscrever); Líder (gerir seu grupo/presença);
  Admin (catálogo).
- **LGPD:** dados de participação com consentimento; visibilidade por papel.
- **Integrações:** Comunicação (lembretes por Push/WhatsApp), Maps (local).
- **Roadmap:** Fase 1 catálogo + inscrição → Fase 2 presença/frequência →
  Fase 3 jornada de integração.

## MÓDULO 3 — MEMBROS
Cadastro · Perfis · Famílias · Aniversários · Batismo · Ministérios

- **Arquitetura:** perfis no Backend com **leitura** protegida (resolve
  EU-04/EU-07); vínculos de família e ministério.
- **Banco:** `profiles` (nome, nascimento, contato, consentimentos),
  `families` + `family_members`, `ministries` + `ministry_members`,
  `baptisms` (data, responsável).
- **Fluxo:** cadastro/perfil → consentimentos → diretório (por papel),
  aniversários do mês, vínculos de família/ministério.
- **Permissões:** Membro (edita o seu, revoga); Líder (seu ministério); Admin
  (diretório completo + exportação auditada).
- **LGPD:** **pré-requisito** (EU-09) — nada de PII sem base legal, RLS e
  auditoria; aniversários só nome + dia.
- **Integrações:** Atendimento/Comunidade (identidade do membro), Comunicação
  (aniversários), Inteligência (indicadores).
- **Roadmap:** Fase 1 perfis+consentimento+aniversários → Fase 2 diretório+
  famílias → Fase 3 ministérios/batismo.

## MÓDULO 4 — COMUNICAÇÃO
WhatsApp Business · Push · E-mail · Comunicados

- **Arquitetura:** **camada de canais** que recebe pedidos de envio do Backend e
  entrega pelo canal apropriado; o **WhatsApp é um dos canais**, não o destino
  único.
- **Banco:** `messages_outbox` (conteúdo, canal, alvo, status, agendamento),
  `channel_configs` (credenciais/config por canal — segredo no backend),
  `announcements` (comunicados), `delivery_log` (auditoria de envio).
- **Fluxo:** conteúdo aprovado → outbox → canal (WhatsApp Business/Push/E-mail)
  → registro de entrega.
- **Permissões:** Comunicação/Admin (enviar/agendar); demais papéis só
  solicitam via seus módulos.
- **LGPD:** opt-in por canal; descadastro fácil; sem envio sem base legal.
- **Integrações:** WhatsApp Business (OBA + Cloud API — elegibilidade/custo),
  provedor de Push, provedor de E-mail.
- **Roadmap:** Fase 1 Push + Comunicados → Fase 2 E-mail → Fase 3 WhatsApp
  Business.

## MÓDULO 5 — INTELIGÊNCIA
Dashboard Pastoral · Indicadores · Relatórios · Métricas

- **Arquitetura:** camada **analítica derivada** (views/materialized views/jobs)
  sobre o Backend; **apenas agregados**, com privacidade por design.
- **Banco:** views/tabelas de agregação (participação, leitura bíblica, oração,
  testemunhos, pequenos grupos, escalas); `report_snapshots` (histórico).
- **Fluxo:** dados dos módulos 1–4 → agregação → Dashboard/Relatórios.
- **Permissões:** Liderança/Admin (ver); acesso auditado.
- **LGPD:** somente agregados; nada de expor conteúdo pessoal individual sem
  base legal.
- **Integrações:** consome todos os módulos; exportável (futuro BI).
- **Roadmap:** Fase 1 Dashboard base + indicadores âncora → Fase 2 relatórios +
  filtros → Fase 3 métricas avançadas.

---

## Inteligência Artificial (IA)

> **Decisão do Owner: NÃO implementar IA na V2.0.** Registrado também no
> `GOEL_CHURCH_2_MASTER_PLAN.md`.

- **Motivo:** evitar **custo recorrente** para a igreja.
- **Direção futura (quando técnica e adequada ao produto):** estudar um modelo
  em que **o próprio usuário conecte a sua conta** para recursos de IA
  **opcionais** — **nunca** como requisito do app.
- **Nesta fase:** nenhuma implementação; apenas registro arquitetural.

## Governança e faseamento

- **Gate LGPD** antes de qualquer módulo que trate dado pessoal (1, 3 e partes
  de 2/4).
- **Sem Firebase**; crash/analytics a decidir (pós‑1.1.0).
- **Homologação por onda/módulo** (mesmo rito da 1.1.0): Internal → Closed →
  Produção; 0 críticos e 0 altos para promover.
- **1.1.0 permanece congelada**; a V2.0 só abre após o encerramento oficial da
  homologação da 1.1.0.

---

### Registro
```
GOEL COMMUNITY PLATFORM (V2.0)
MÓDULOS   1 Atendimento · 2 Comunidade · 3 Membros · 4 Comunicação · 5 Inteligência
ARQUIT.   App → Backend Goel → Painel Admin → Equipe → Canal de saída
CANAIS    WhatsApp Business · Push · E-mail · Comunicados (WhatsApp = 1 dos canais)
IA        Adiada (sem custo recorrente; futuro: usuário conecta a própria conta)
ESTADO    Planejamento — sem implementação
1.1.0     CONGELADA
```
