# GOEL CHURCH — RELEASE BOARD (1.1.0)

> **STATUS: QUALITY ASSURANCE.** Fase de **desenvolvimento** da 1.1.0
> **oficialmente encerrada**. A 1.1.0 permanece **congelada** — nenhuma
> funcionalidade nova. A **V2.0 permanece bloqueada** (apenas planejamento
> aprovado, sem implementação).
>
> **Escopo de qualquer conversa da 1.1.0:** exclusivamente
> **Homologação → Defeito → Correção → Nova homologação.**
>
> Este board é a **visão de fluxo**; o `DEFECT_LOG.md` é o **registro tabular**
> oficial (severidade, prioridade, origem, etc.). Cada card aqui referencia um
> `DEF-` do log.

---

## Colunas do board

### 🗂️ BACKLOG
_Defeitos reportados, aguardando análise._

- _(vazio)_

### 🔍 EM ANÁLISE
_Em auditoria / identificação de causa raiz / correção em andamento._

- _(vazio)_

### 🛠️ CORRIGIDOS
_Correção aplicada (`analyze` limpo + `test` verde), aguardando nova homologação._

- **DEF-GP-01** — Upload recusado no Internal Testing ("código de versão 9 já
  usado"). Corrigido: versionCode 9 → 10 (AAB run #14, `f60c9a1`). Aguardando
  homologação do upload no Play. _(card completo abaixo)_

### ✅ HOMOLOGADOS
_Homologado pelo Owner após nova verificação — defeito fechado._

- _(vazio)_

---

## Fluxo do board

```
BACKLOG → EM ANÁLISE → CORRIGIDOS → HOMOLOGADOS
(reportado)  (auditar/    (analyze+test  (Owner valida
             causa raiz/   ok, aguarda    → fecha)
             corrigir)     homologação)
```

Mapeamento com o `DEFECT_LOG.md`:
`ABERTO`→BACKLOG · `EM AUDITORIA`/`EM CORREÇÃO`→EM ANÁLISE ·
`AGUARDANDO HOMOLOGAÇÃO`→CORRIGIDOS · `FECHADO`→HOMOLOGADOS.

---

## Template obrigatório de defeito

> Todo defeito encontrado no Internal Testing **deve** preencher todos os campos.

```
ID:                     DEF-<letra>-<nº>   (B/H/L/C/R/G/S… por módulo)
Título:                 <resumo curto>
Versão:                 1.1.0 (<versionCode>)
Dispositivo:            <ex.: Samsung A15>
Sistema:                <ex.: Android 16>
Passos para reproduzir: 1) … 2) … 3) …
Resultado esperado:     <o que deveria acontecer>
Resultado obtido:       <o que aconteceu>
Evidência:              <print/vídeo/descrição>
Causa raiz:             <o porquê real — preenchido na auditoria>
Arquivos alterados:     <lista — preenchido na correção>
Testes:                 flutter analyze (limpo) + flutter test (verde)
Status:                 BACKLOG | EM ANÁLISE | CORRIGIDOS | HOMOLOGADOS
```

---

## Cards

### DEF-GP-01 — Upload recusado (versionCode 9 já usado)

| Campo | Valor |
|---|---|
| **ID** | DEF-GP-01 |
| **Título** | Google Play recusa o AAB: "O código de versão 9 já foi usado. Tente outro." |
| **Versão** | 1.1.0 (9) → corrigido em 1.1.0 (10) |
| **Dispositivo** | Web (Google Play Console) |
| **Sistema** | Play Console (navegador) |
| **Passos para reproduzir** | 1) Teste interno → Criar nova versão. 2) Enviar `app-release.aab` (code 9). 3) Observar o erro no pacote. |
| **Resultado esperado** | AAB aceito como versão 9 (1.1.0). |
| **Resultado obtido** | Erro: "O código de versão 9 já foi usado. Tente outro." |
| **Evidência** | Print do Play Console (upload recusado, 2026-08-04). |
| **Causa raiz** | O versionCode 9 já havia sido consumido no Play (upload anterior). O Play exige versionCode estritamente maior que qualquer já enviado. |
| **Arquivos alterados** | `pubspec.yaml` (`1.1.0+10`), `.github/workflows/release-aab.yml` (`--build-number=10`). |
| **Testes** | `flutter analyze` limpo · `flutter test` verde (79). |
| **Status** | **CORRIGIDOS** (AAB code 10 gerado, run #14, SHA-256 `07b9f590…d341`) — aguardando homologação do upload. |

> Fecha (→ HOMOLOGADOS) quando o Owner confirmar o upload aceito no Internal
> Testing com o code 10.

---

### Registro
```
GOEL CHURCH
VERSION   1.1.0 (code 10)
STATUS    QUALITY ASSURANCE
FASE      Homologação (dev encerrado; escopo congelado)
V2.0      BLOQUEADA (apenas planejamento aprovado)
CICLO     Homologação → Defeito → Correção → Nova homologação
PLACAR    Críticos: 0 · Altos: 1 (DEF-GP-01, corrigido/aguardando)
```
