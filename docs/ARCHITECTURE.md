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

## O que está deliberadamente FORA deste código (por ora)

- **Domínio Pastoral Sensível** (Assistente por IA, histórico emocional) e
  **Pedido de Oração** — Slices 08–09, **adiados** até a Parte B e o Pacote 3
  definirem base legal (LGPD), consentimento, retenção, política de menores e a
  estratégia de vinculação entre domínios (pendência 2.X.3).
- Persistência real, autenticação real, integrações externas — entram nos slices
  correspondentes, sempre atrás de suas credenciais/provisionamento.
