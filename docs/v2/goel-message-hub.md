# GOEL COMMUNITY PLATFORM — Módulo 1 · ATENDIMENTO (Message Hub)

> **Documento oficial da V2.0.** Apenas documentação — **nenhuma implementação
> nesta etapa**. A Release **1.1.0 permanece congelada**.
>
> **Posicionamento:** o antigo "Message Hub" deixa de ser módulo isolado e passa
> a ser o **Módulo 1 — Atendimento** da **GOEL COMMUNITY PLATFORM** (ver
> `docs/v2/GOEL_COMMUNITY_PLATFORM.md`). Nasce da auditoria oficial do WhatsApp
> (`docs/rc1/auditoria-whatsapp.md`): como a plataforma não permite postar
> automaticamente em grupos de convite, a Goel Church terá um **backend próprio**
> de recebimento, moderação e publicação.
>
> **Novo fluxo oficial:** `App → Supabase → Fila de moderação → Painel
> Administrativo → Equipe responsável → WhatsApp Business (quando aplicável) →
> Grupo`. O WhatsApp passa a ser **um dos canais de saída** (via Módulo 4 —
> Comunicação), não o destino único.

## 1. Visão geral

O **Goel Church Message Hub** centraliza as mensagens enviadas pelos membros
(Testemunhos, Pedidos de Oração, Quero Ser Servo), com **moderação, histórico,
auditoria e aprovação** antes de qualquer publicação — e prepara a **integração
futura com o WhatsApp Business**.

### Módulos contemplados
- **Testemunhos**
- **Pedidos de Oração**
- **Quero Ser Servo**

### Objetivos
- **Moderação** (revisar antes de publicar)
- **Histórico** (tudo registrado)
- **Auditoria** (quem fez o quê, quando)
- **Aprovação** (fluxo com estados)
- **Integração futura com WhatsApp Business** (publicação assistida/automática)

## 2. Arquitetura

```
┌──────────┐   envio    ┌────────────┐   leitura/gestão   ┌────────────────────┐
│   APP    │ ─────────▶ │  SUPABASE  │ ◀────────────────▶ │ PAINEL ADMIN (web) │
│ (membro) │            │ (dados +   │                    │  (equipe/moderação)│
└──────────┘            │  RLS +     │                    └─────────┬──────────┘
                        │  Edge Fns) │                              │ aprova
                        └────────────┘                              ▼
                                                        ┌────────────────────┐
                                                        │ EQUIPE RESPONSÁVEL │
                                                        └─────────┬──────────┘
                                                                  │ publica
                                                                  ▼
                                                        ┌────────────────────┐
                                                        │   WHATSAPP → GRUPO │
                                                        └────────────────────┘
```

**Camadas:**
1. **App (membro):** formulários já existentes (Testemunho/Oração/Servo) passam
   a **enviar para o Supabase** (além do fluxo atual de WhatsApp, que continua
   como atalho opcional na 1.1.0).
2. **Supabase:** persistência, `RLS` (row-level security), Edge Functions para
   escrita/validação e trilha de auditoria.
3. **Painel Administrativo (web):** a equipe vê a fila, **modera e aprova**.
4. **Equipe responsável:** publica no grupo — manual (copiar/abrir WhatsApp)
   na 1ª fase; **assistida/automática** via WhatsApp Business na fase futura.
5. **WhatsApp → Grupo:** destino final da mensagem aprovada.

## 3. Fluxos

### 3.1 Fluxo geral (comum aos 3 módulos)
```
Membro envia → grava no Supabase (status: PENDENTE) →
aparece no Painel → Moderador revisa →
  ├─ APROVADO   → Publicado no grupo (manual/assistido) → status: PUBLICADO
  ├─ REJEITADO  → status: REJEITADO (com motivo)
  └─ EDITADO    → ajusta texto → volta para APROVAÇÃO
Toda transição gera registro de AUDITORIA.
```

### 3.2 Testemunho
Nome · WhatsApp (opcional) · Título · Texto · consentimento de publicação →
`PENDENTE` → moderação (remover dados sensíveis) → `APROVADO` → publicação.

### 3.3 Pedido de Oração
Nome · WhatsApp (opcional) · Pedido · **flag de privacidade** (público no grupo
ou somente equipe) → `PENDENTE` → triagem → `APROVADO`/`SOMENTE EQUIPE`.

### 3.4 Quero Ser Servo
Nome · Contato · Área(s) → `PENDENTE` → equipe de integração assume →
`EM CONTATO` → `CONCLUÍDO`.

## 3.5 Estados da mensagem (máquina de estados)

```
                 ┌───────────┐
   enviar  ─────▶│  PENDENTE │
                 └─────┬─────┘
        moderação      │
      ┌────────────────┼───────────────────┐
      ▼                ▼                    ▼
 ┌──────────┐   ┌─────────────┐      ┌──────────────┐
 │ APROVADO │   │  REJEITADO  │      │ SOMENTE_EQUIPE│  (oração privada)
 └────┬─────┘   └─────────────┘      └──────┬───────┘
      │ publicar (canal de saída)           │ atender internamente
      ▼                                      ▼
 ┌───────────┐                        ┌────────────┐
 │ PUBLICADO │                        │ CONCLUÍDO  │
 └───────────┘                        └────────────┘
      (Servo: PENDENTE → EM_CONTATO → CONCLUÍDO)
```

- **Transições válidas:** `PENDENTE → APROVADO | REJEITADO | SOMENTE_EQUIPE`;
  `APROVADO → PUBLICADO`; `SOMENTE_EQUIPE → CONCLUÍDO`; `PENDENTE → EM_CONTATO →
  CONCLUÍDO` (Servo). Edição mantém o item em moderação (não pula estados).
- **Regra:** nada vai a um canal de saída sem passar por `APROVADO` (ou o
  atendimento interno correspondente).

## 3.6 Fluxo de aprovação

1. Item entra como `PENDENTE` na **fila de moderação** (Painel Admin).
2. Moderador **revisa** (pode **editar** para remover PII/ajustar texto).
3. **Aprova** (→ pronto para publicar), **rejeita** (com motivo) ou marca
   **somente equipe** (oração privada).
4. Publicação ocorre pelo **Módulo 4 — Comunicação** (WhatsApp Business/Push/
   e-mail/grupo), gerando `publications` + `delivery_log`.
5. Cada passo grava **auditoria** imutável (ver 3.7).

## 3.7 Auditoria

- Toda transição de estado e toda publicação gera registro **imutável**
  (`moderation_actions`, `publications`) com **ator, ação, motivo/edição e
  carimbo de tempo**.
- Tabelas de auditoria são **append-only** (sem update/delete).
- Acesso a PII e exportações também são registrados (Módulo 3/Governança).

## 3.8 Integração futura

- **WhatsApp Business (Cloud/Groups API)** como **um dos canais** de saída
  (Módulo 4), sujeito a **Official Business Account** + custo/elegibilidade.
- Publicação evolui de **manual** (copiar/abrir) → **assistida** → **automática**
  conforme a viabilidade, sem mudar o contrato de moderação/aprovação.
- Grupos de convite atuais **não** são adotáveis pela Groups API — decisão de
  arquitetura de comunidade (ver auditoria WhatsApp).

## 4. Modelo de dados (proposto)

> Esquema conceitual — nomes/tipos finais definidos na implementação.

### `submissions` (mensagens dos membros)
| Campo | Tipo | Notas |
|---|---|---|
| `id` | uuid (PK) | |
| `type` | enum | `TESTEMUNHO` · `ORACAO` · `SERVO` |
| `author_name` | text | nome informado |
| `author_user_id` | uuid (FK auth) | se logado |
| `author_whatsapp` | text (nullable) | opcional |
| `title` | text (nullable) | testemunho |
| `body` | text | pedido/testemunho |
| `areas` | text[] (nullable) | servo |
| `visibility` | enum | `PUBLICO` · `SOMENTE_EQUIPE` (oração) |
| `status` | enum | `PENDENTE` · `APROVADO` · `REJEITADO` · `PUBLICADO` · `EM_CONTATO` · `CONCLUIDO` |
| `consent` | bool | consentimento de publicação (LGPD) |
| `created_at` | timestamptz | |
| `updated_at` | timestamptz | |

### `moderation_actions` (auditoria)
| Campo | Tipo | Notas |
|---|---|---|
| `id` | uuid (PK) | |
| `submission_id` | uuid (FK) | |
| `actor_id` | uuid (FK auth) | moderador |
| `action` | enum | `APROVAR` · `REJEITAR` · `EDITAR` · `PUBLICAR` |
| `reason` | text (nullable) | motivo (rejeição) |
| `diff` | jsonb (nullable) | alteração de texto |
| `created_at` | timestamptz | carimbo imutável |

### `publications` (registro de publicação)
| Campo | Tipo | Notas |
|---|---|---|
| `id` | uuid (PK) | |
| `submission_id` | uuid (FK) | |
| `channel` | enum | `WHATSAPP_GRUPO` · `OUTRO` |
| `target` | text | grupo/lista de destino |
| `method` | enum | `MANUAL` · `BUSINESS_API` |
| `published_by` | uuid (FK auth) | |
| `published_at` | timestamptz | |

### `staff_roles` (equipe)
| Campo | Tipo | Notas |
|---|---|---|
| `user_id` | uuid (PK, FK auth) | |
| `role` | enum | `ADMIN` · `MODERADOR` · `INTEGRACAO` |
| `granted_by` | uuid (FK auth) | |
| `granted_at` | timestamptz | |

## 5. Permissões (RLS)

| Papel | Pode |
|---|---|
| **Membro** | Criar a própria `submission`; ler **apenas as suas**; revogar/apagar as suas. |
| **Moderador** | Ler a fila; aprovar/rejeitar/editar; registrar auditoria. **Não** apaga histórico. |
| **Integração** | Ver/atender `SERVO` (`EM_CONTATO` → `CONCLUIDO`). |
| **Admin** | Tudo acima + gerir papéis (`staff_roles`) + configurar destinos. |

**Princípios:** RLS em todas as tabelas; escrita sensível via **Edge Functions**
autenticadas; **auditoria imutável** (sem update/delete em `moderation_actions`);
telefone/PII visível **apenas** a papéis autorizados.

## 6. LGPD

> Pré-requisito obrigatório: cumprir `docs/rc1/EU-09-lgpd-aprovacao.md`.

- **Base legal:** consentimento específico e destacado, por finalidade
  (publicar testemunho / pedido no grupo).
- **Consentimento:** `consent` gravado com data/hora e versão do texto aceito.
- **Minimização:** publicar só o necessário; opção de **anonimizar** (ex.:
  "um irmão pediu oração").
- **Finalidade:** uso restrito à edificação/pastoral; proibido uso externo.
- **Retenção:** enquanto durar o consentimento/vínculo; descarte/anonimização
  após revogação.
- **Revogação:** o autor pode **revogar** e solicitar remoção a qualquer tempo.
- **Auditoria:** `moderation_actions` + `publications` registram todo acesso e
  publicação; canal do encarregado (DPO) publicado.
- **Segurança:** HTTPS, RLS, acesso a PII só para papéis autorizados.

## 7. Roadmap

**Fase 0 — Documentação (esta etapa)** ✅
- Arquitetura, fluxos, modelo de dados, permissões, LGPD (este documento).

**Fase 1 — Captura + Painel (MVP do Hub)**
- App envia `submissions` ao Supabase (mantendo o atalho WhatsApp da 1.1.0).
- Painel admin web: fila, aprovar/rejeitar/editar, auditoria.
- Publicação **manual** (copiar/abrir WhatsApp) pela equipe.
- Depende de: **aprovação LGPD** + RLS + papéis.

**Fase 2 — Moderação avançada**
- Templates de publicação, anonimização, filas por módulo, notificações à
  equipe, métricas.

**Fase 3 — WhatsApp Business (integração)**
- Avaliar **Official Business Account** + Cloud API / Groups API.
- Publicação **assistida/automática** conforme elegibilidade e custo.
- Migração/planejamento dos grupos (grupos de convite atuais não são adotáveis
  pela Groups API — decisão de arquitetura de comunidade).

---

### Registro
```
GOEL CHURCH
MÓDULO   Goel Church Message Hub
VERSÃO   2.0 (documentação)
ESTADO   Especificação — sem implementação
BASE     Auditoria WhatsApp (rc1) + LGPD (EU-09)
1.1.0    CONGELADA
```
