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
DEF → Evidência → Auditoria → Causa raiz → Correção mínima →
flutter analyze → flutter test → Nova homologação → Fechamento
```

Cada defeito só é **FECHADO** após nova homologação do Owner. **Nenhuma
implementação pode ocorrer fora deste fluxo.**

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

**Origem:** contexto/ambiente onde ocorreu — trilha, aparelho, SO, rede.
Ex.: `Google Play`, `Samsung A15`, `Android 16`, `Wi-Fi`, `Internal Testing`
(pode combinar: "Internal Testing · Samsung A15 · Android 16 · Wi-Fi").

**Tempo para reproduzir:** quanto leva/o que basta para o defeito aparecer.
Ex.: `30 segundos`, `2 minutos`, `Após Login`, `Após Reiniciar`.

---

## Registro de defeitos

| ID | Módulo | Descrição | Severidade | Prioridade | Reprodutibilidade | Origem | Tempo p/ reproduzir | Versão | Versão Corrigida | Dispositivo | Status | Correção | Data | Responsável |
|----|--------|-----------|------------|------------|-------------------|--------|---------------------|--------|------------------|-------------|--------|----------|------|-------------|
| `DEF-GP-01` | Google Play | Upload no Internal Testing recusado: "O código de versão 9 já foi usado. Tente outro." O code 9 já havia sido consumido no Play. | ALTO | P0 | SEMPRE | Google Play Console · Internal Testing | Imediato (no upload) | 1.1.0 (9) | 1.1.0 (10) | Web (Play Console) | AGUARDANDO HOMOLOGAÇÃO | Bump versionCode 9→10 (pubspec + workflow); rebuild assinado. Sem mudança de escopo/funcionalidade. | 2026-08-04 | Claude |

> Ao receber uma evidência, abre-se uma nova linha com `Status: ABERTO`,
> classifica-se Severidade/Prioridade/Reprodutibilidade e inicia-se o fluxo
> obrigatório. O campo **Correção** referencia o commit/relatório da menor
> correção; **Versão Corrigida** é preenchida quando a correção entra.

### Placar (atualizar a cada mudança)

| | Crítico | Alto | Médio | Baixo |
|---|---|---|---|---|
| **Abertos** | 0 | 1 | 0 | 0 |
| **Fechados** | 0 | 0 | 0 | 0 |

> `DEF-GP-01` (Alto) aberto — correção aplicada (code 10), **aguardando
> homologação** (upload bem-sucedido no Play). Fecha após o Owner confirmar.

> **Critério para encerrar o Internal Testing:** **CRÍTICOS = 0** e
> **ALTOS = 0** (abertos). Só então → Closed Testing → Produção (ver
> `RELEASE_PLAN_1.1.0.md`). Meta da fase: **ZERO defeitos críticos** antes da
> Produção.

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
