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

## Classificação de severidade

| Código | Severidade | Significado | Bloqueia publicação? |
|---|---|---|---|
| **S1** | Crítico | Trava/impede uso, perda de dados, app não abre | **Sim** |
| **S2** | Alto | Função importante quebrada, sem contorno | **Sim** |
| **S3** | Médio | Função quebrada com contorno viável | Não |
| **S4** | Baixo | Cosmético/menor | Não |
| **S5** | Melhoria | Sugestão/evolução (não é defeito) | Não |

> Cada card indica sua severidade (S1–S5). **Portão de saída do Internal
> Testing:** nenhum **S1** e nenhum **S2** abertos (ver `RELEASE_PLAN_1.1.0.md`).
> S5 (Melhoria) é registrado, mas direcionado ao planejamento (ex.: V2.0), não
> ao ciclo de correção da 1.1.0.

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

- **DEF-GP-01** _(S2 · Alto)_ — Upload recusado no Internal Testing ("código de
  versão 9 já usado"). Corrigido: versionCode 9 → 10 (AAB run #14, `f60c9a1`).
  Aguardando homologação do upload no Play. _(card completo abaixo)_

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
| **Severidade** | **S2 — Alto** |
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
FASE      Homologação (preparação da Release ENCERRADA; escopo congelado)
V2.0      BLOQUEADA (apenas planejamento aprovado)
CICLO     Homologação → Defeito → Correção → Nova homologação
SEVERID.  S1 Crítico · S2 Alto · S3 Médio · S4 Baixo · S5 Melhoria
PLACAR    S1: 0 · S2: 1 (DEF-GP-01, corrigido/aguardando) · S3: 0 · S4: 0
```
