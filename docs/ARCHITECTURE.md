# Arquitetura — mapeamento código ↔ documentos oficiais

Este documento conecta a estrutura do código às decisões já congeladas
(GOEL-ARCH-P2A-01, P2A-02A, P2A-02B-A1 e Adendos). O código **não** redefine
arquitetura; apenas a materializa.

## Estrutura de diretórios

```
GOEL-CHURCH/
├── lib/                     # Camada de entrega (Flutter) — Delivery Layer
│   ├── main.dart            # ponto de entrada
│   ├── app/                 # shell: MaterialApp, tema, (navegação nos slices seguintes)
│   │   └── theme/           # acessibilidade como requisito (público idoso)
│   ├── bootstrap/           # Slice 01: tela neutra de inicialização
│   └── core/                # utilitários transversais da UI (sem regra de negócio)
├── packages/
│   └── goel_domain/         # DOMÍNIO em Dart puro — NÃO importa Flutter
│       └── lib/
│           ├── goel_domain.dart   # superfície pública (Stable Module Boundaries)
│           └── src/               # interno ao módulo
├── test/                    # testes de widget (app)
└── docs/
```

## Princípios materializados

| Princípio (fonte) | Como o código honra |
|---|---|
| Framework Independence (P2A-01, P2A-02B-A1) | Domínio em `packages/goel_domain`, sem dependência de `flutter` no pubspec — impedimento estrutural de acoplar à UI. |
| Stable Module Boundaries (P2A-02B-A1) | Superfície pública via `goel_domain.dart`; `src/` é interno; lint `implementation_imports: error`. |
| Monólito modular (P2A-01) | Um único deployable; módulos por bounded context (crescem por slice), colaboração por contrato. |
| Acessibilidade / público idoso (premissa) | Tema com tipografia ampliada, alvos de toque amplos, densidade confortável. |
| Android-first / iOS-ready (ADR-002) | Sem acoplamento a APIs exclusivas de plataforma na camada de entrega. |

## Modelo de execução (P2A-02A / P2A-02B)

Híbrido: **cliente Flutter + Supabase (dados/RLS) + Edge Functions (lógica
privilegiada/segredos)**. Segredos (ex.: token da Meta Cloud API) **nunca** no
cliente. Materializa-se a partir do Slice 02.

## Automação de Aniversário (decisão relevante)

A `birth_date` do membro **não é fator de autenticação** (A1). Sua finalidade é
a **automação de aniversário**: a Edge Function agendada `birthday-greetings`
(diária, às ~08:00 BRT) busca os aniversariantes do dia **com opt-in** e envia,
**automaticamente e sem qualquer intervenção humana**, uma saudação pelo
WhatsApp. O envio depende do consentimento de comunicação (`whatsapp_opt_in`),
coletado no cadastro (Slice 04). É o módulo *Comunicação e Relacionamento /
Automações* do Pacote 1. A validação jurídica final do consentimento é do
Pacote 3.

## Versículo do Dia — domínio público (Opção A, decisão do owner)

Fonte **primária**: tradução de **domínio público** (Almeida antiga / Tradução
Brasileira), empacotada em `assets/content/versiculos_dominio_publico.json` e
servida por `LocalVerseRepository` — **offline-first, sem licença, sem custo,
sem rede**. Seleção determinística por dia.

A **NVI é licenciada** (Biblica) e fica como **upgrade futuro** (Opção B): o
`OnlineVerseRepository` + a Edge Function `verse-of-the-day` permanecem no código
para quando houver licença/chave, mas **não são usados por padrão**.

## O que está deliberadamente FORA deste código (por ora)

- **Domínio Pastoral Sensível** (Assistente por IA, histórico emocional) e
  **Pedido de Oração** — Slices 08–09, **adiados** até a Parte B e o Pacote 3
  definirem base legal (LGPD), consentimento, retenção, política de menores e a
  estratégia de vinculação entre domínios (pendência 2.X.3).
- Persistência real, autenticação real, integrações externas — entram nos slices
  correspondentes, sempre atrás de suas credenciais/provisionamento.
