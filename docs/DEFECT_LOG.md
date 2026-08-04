# GOEL CHURCH — Registro de Defeitos (Quality Assurance)

> **FASE OFICIAL: QUALITY ASSURANCE / HOMOLOGAÇÃO** — Release **1.1.0
> (Version Code 9)**, `STATUS: RELEASE CERTIFIED`. **Escopo 1.1.0 CONGELADO.**
>
> **Este DEFECT_LOG é o ÚNICO ponto de entrada para qualquer alteração na
> versão 1.1.0.** Nenhuma alteração pode ser implementada sem um **DEF aberto**
> (defeito reproduzível) **ou** uma **aprovação formal do Owner**. Nenhuma nova
> funcionalidade. Nenhuma nova Sprint.
>
> **Objetivo: ZERO defeitos críticos antes da Produção.**
> Metas da fase: Estabilidade · Qualidade · Confiabilidade.

---

## Fluxo obrigatório de defeito

```
Evidência → Auditoria → Causa raiz → Correção mínima →
flutter analyze → flutter test → Nova homologação → Fechamento
```

Cada defeito só é **FECHADO** após nova homologação do Owner.

---

## Padrão de IDs (por módulo)

| Prefixo | Módulo |
|---|---|
| `DEF-B` | Bible Engine |
| `DEF-H` | Home |
| `DEF-L` | Login |
| `DEF-C` | Cadastro |
| `DEF-R` | Redes |
| `DEF-G` | Gabinete |
| `DEF-S` | Servo |

Formato: `DEF-<letra>-<sequencial>` (ex.: `DEF-B-01`, `DEF-H-01`).
Outros módulos seguem o mesmo padrão pela inicial (ex.: `DEF-O` Oração,
`DEF-T` Testemunho, `DEF-E` Escalas) — a confirmar quando surgir o primeiro
caso.

---

## Escalas de classificação

**Severidade** (impacto):
`CRÍTICO` (trava/impede uso, perda de dados, não abre) · `ALTO` (função
importante quebrada, sem contorno) · `MÉDIO` (função quebrada com contorno) ·
`BAIXO` (cosmético/menor).

**Prioridade** (ordem de ataque):
`P0` (agora — bloqueia Produção) · `P1` (alta) · `P2` (média) · `P3` (baixa).

**Reproduzibilidade:**
`SEMPRE` (100%) · `FREQUENTE` · `INTERMITENTE` · `RARA` · `NÃO REPRODUZÍVEL`.

**Status:**
`ABERTO` → `EM AUDITORIA` → `EM CORREÇÃO` → `AGUARDANDO HOMOLOGAÇÃO` →
`FECHADO` (ou `NÃO REPRODUZÍVEL` / `NÃO É DEFEITO`).

**Versão:** onde o defeito foi observado (ex.: `1.1.0 (9)`).
**Versão Corrigida:** onde a correção entrou (ex.: `1.1.0 (10)` ou commit).

---

## Registro de defeitos

| ID | Módulo | Descrição | Severidade | Prioridade | Reprodutibilidade | Versão | Versão Corrigida | Dispositivo | Status | Correção | Data | Responsável |
|----|--------|-----------|------------|------------|-------------------|--------|------------------|-------------|--------|----------|------|-------------|
| —  | —      | _Nenhum defeito registrado até o momento._ | — | — | — | 1.1.0 (9) | — | — | — | — | — | — |

> Ao receber uma evidência, abre-se uma nova linha com `Status: ABERTO`,
> classifica-se Severidade/Prioridade/Reprodutibilidade e inicia-se o fluxo
> obrigatório. O campo **Correção** referencia o commit/relatório da menor
> correção; **Versão Corrigida** é preenchida quando a correção entra.

### Placar (atualizar a cada mudança)

| | Crítico | Alto | Médio | Baixo |
|---|---|---|---|---|
| **Abertos** | 0 | 0 | 0 | 0 |
| **Fechados** | 0 | 0 | 0 | 0 |

> **Portão de Produção:** exige **0 defeitos CRÍTICOS abertos** (objetivo da
> fase) e homologação final do Owner.

---

## Relatórios de correção

Cada DEF corrigido recebe um relatório curto (aqui ou em `docs/fixes/DEF-XXX.md`):

- **Causa raiz** (o porquê real, não o sintoma).
- **Correção mínima** aplicada (arquivos/linhas).
- **Qualidade:** `flutter analyze` limpo + `flutter test` verde.
- **Commit** e **Versão Corrigida**.
- **Homologação:** aguardando / homologado pelo Owner.

---

### Registro da Release em homologação
```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  9
STATUS        RELEASE CERTIFIED
FASE          QUALITY ASSURANCE / HOMOLOGAÇÃO
ESCOPO        CONGELADO
CICLO         Evidência → Auditoria → Causa raiz → Correção mínima →
              analyze → test → Nova homologação → Fechamento
META          ZERO defeitos críticos antes da Produção
```
