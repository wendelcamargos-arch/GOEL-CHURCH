# GOEL CHURCH — Registro de Defeitos (Homologação)

> **FASE OFICIAL: HOMOLOGAÇÃO** — Release **1.1.0 (Version Code 9)**,
> `STATUS: RELEASE CERTIFIED`.
>
> **Regra de governança:** nenhuma alteração pode ser implementada sem um
> **defeito reproduzível** registrado aqui **ou** uma **aprovação formal do
> Owner**. Nenhuma nova funcionalidade. Nenhuma nova Sprint.
>
> **Objetivo da fase:** Estabilidade · Qualidade · Confiabilidade — antes da
> publicação em Produção.

---

## Fluxo obrigatório de defeito

```
1. Receber evidência do Owner
2. Auditar
3. Identificar causa raiz
4. Implementar a MENOR correção possível
5. Executar: flutter analyze  +  flutter test
6. Gerar relatório de correção
7. Aguardar nova homologação
8. Somente então fechar o defeito
```

Cada defeito só é **FECHADO** após nova homologação do Owner (passo 8).

---

## Convenções

**Status:**
`ABERTO` → `EM AUDITORIA` → `EM CORREÇÃO` → `AGUARDANDO HOMOLOGAÇÃO` →
`FECHADO` (ou `NÃO REPRODUZÍVEL` / `NÃO É DEFEITO`).

**ID:** `DEF-001`, `DEF-002`, … (sequencial).

**Módulo:** Bible Engine · Login · Cadastro · Home · Oração · Testemunho ·
Servo · Escalas · Redes · Como Chegar · Bible Search · Favoritos · Continue
Lendo · Planos · Modo Púlpito · Modo Culto · LGPD · Performance · Acessibilidade
· Google Play.

**Versão:** versão em que o defeito foi observado (ex.: `1.1.0 (9)`).

---

## Registro de defeitos

| ID | Módulo | Descrição | Versão | Dispositivo | Status | Correção | Data | Responsável |
|----|--------|-----------|--------|-------------|--------|----------|------|-------------|
| —  | —      | _Nenhum defeito registrado até o momento._ | 1.1.0 (9) | — | — | — | — | — |

> Ao receber uma evidência, uma nova linha é aberta com `Status: ABERTO` e o
> ciclo do fluxo obrigatório é iniciado. O campo **Correção** referencia o
> commit/relatório da menor correção aplicada.

---

## Relatórios de correção

Cada defeito corrigido recebe um relatório curto (nesta seção ou em
`docs/fixes/DEF-XXX.md`) contendo:

- **Causa raiz** (o porquê real, não o sintoma).
- **Menor correção** aplicada (arquivos/linhas).
- **Evidência de qualidade:** `flutter analyze` limpo + `flutter test` verde.
- **Commit** da correção.
- **Status de homologação:** aguardando / homologado pelo Owner.

---

### Registro da Release em homologação
```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  9
STATUS        RELEASE CERTIFIED
FASE          HOMOLOGAÇÃO
CICLO         Teste → Correção → Nova homologação → Produção
```
