# GOEL CHURCH — Release Retrospective 1.1.0

> **STATUS: EM ABERTO — a concluir no encerramento da homologação.**
> As seções que dependem da homologação (4, 5, 6, 8) só devem ser **preenchidas
> após o encerramento** (0 críticos e 0 altos). As seções de fato consolidado
> (1, 2, 3, 7) já estão registradas. Nenhuma alteração na 1.1.0; nenhuma
> implementação da V2.0.
>
> Candidata oficial: **1.1.0 (code 11)** · code 10 SUPERSEDED.

---

## 1. Resumo da Release

- **Produto:** Goel Church (app oficial da igreja).
- **Versão:** 1.1.0 · **Version Code:** 11 (candidata oficial; code 10
  SUPERSEDED).
- **Commit/Build:** `b35671a` · Run #15 · SHA-256
  `e52cd6c814454d7211a2430ab1005a183ce1ec6d3781b628593a7edeee031dc5`.
- **Assinatura:** keystore oficial `goel` (SHA1 `31:E8:C6`).
- **Destino:** Google Play → **Internal Testing** (sem Produção até homologação
  final).
- **Qualidade:** `flutter analyze` limpo · `flutter test` **79/79 PASS**.
- **Escopo entregue:** Bible Engine offline (Almeida 1911), busca, favoritos,
  planos, compartilhar, Modo Púlpito/Culto; comunidade (Oração/Testemunho/Servo
  com mensagem pronta no WhatsApp); Escalas editáveis; Home refinada; Redes
  (Instagram/YouTube/WhatsApp) e Google Maps; PALAVRAS (Google Drive).

## 2. Principais conquistas

- 📖 **Bible Engine offline completa** (66 livros / 1.189 capítulos / 31.102
  versículos), eliminando o defeito de "5 versículos".
- 🧭 **Arquitetura preservada** (domínio em Dart puro, offline-first, sem
  Firebase), com contratos estáveis.
- 🙏 **Módulos de comunidade** com mensagem pronta e limitação oficial do
  WhatsApp corretamente reconhecida e documentada.
- 🗂️ **Escalas editáveis** (adicionar/editar/remover/reordenar) com rodízio ao
  vivo.
- 🏠 **Home refinada** (UX final aprovada).
- ✅ **Qualidade contínua**: 79 testes verdes, análise limpa em toda a release.
- 🗃️ **Governança de QA sólida**: TEST_PLAN, DEFECT_LOG, RELEASE_BOARD,
  KNOWN_ISSUES, RELEASE_PLAN, ondas de homologação e certificação.
- 🧱 **Planejamento da V2.0** (Master Plan + 5 pilares + Message Hub) aprovado.

## 3. Principais dificuldades

- 🔑 **Assinatura/keystore**: divergência de chave no Play (esperado
  `31:E8:C6`), resolvida com o keystore oficial e atualização de secrets.
- ⚪ **Splash/cache**: instalações antigas causavam tela de abertura travada;
  endereçado com build limpo e instalação via trilha oficial.
- 🔢 **Colisão de versionCode** (DEF-GP-01): Play recusou code 9 ("já usado") →
  sucessivos ajustes até o **code 11** oficial.
- 💬 **Limitação da plataforma WhatsApp**: impossível auto-postar em grupo por
  link — exigiu auditoria oficial e desenho da alternativa (mensagem pronta).
- 🧪 **Testes de widget** com carregamento real de assets (pumpAndSettle) →
  padrão de repositórios FAKE e telas lazy.
- 🔐 **LGPD como trava**: Membros/Aniversariantes reais dependem de base legal e
  backend — deliberadamente adiados.

## 4. Defeitos encontrados durante a homologação
> _A preencher no encerramento — fonte: `DEFECT_LOG.md` / `RELEASE_BOARD.md`._

| ID | Módulo | Severidade | Status | Onda |
|----|--------|------------|--------|------|
| _(a preencher)_ | | | | |

Resumo pré-homologação: **DEF-GP-01** (S2/Alto) — upload recusado (code 9),
corrigido via bump para code 11.

## 5. Correções realizadas
> _A preencher no encerramento — uma linha por DEF corrigido (causa raiz +
> commit + versão corrigida)._

- _(a preencher)_

## 6. Lições aprendidas
> _A preencher no encerramento._

- _(a preencher — ex.: gestão de versionCode no Play; valor da auditoria de
  plataforma antes de prometer comportamento; governança por DEF.)_

## 7. Itens transferidos oficialmente para a Versão 2.0

- 👥 **Membros reais** (diretório) — depende de backend + LGPD (Pilar 2).
- 🎂 **Aniversariantes reais** — mesma dependência (Pilar 2).
- 📖 **Bíblia híbrida** (online + offline fallback) — EU-08 (Pilar 3).
- 💬 **Message Hub** (moderação/histórico/aprovação da comunidade; integração
  futura com WhatsApp Business) — auditoria WhatsApp (Pilar 1).
- 📊 **Inteligência** (Dashboard Pastoral e indicadores) — Pilar 5.
- 🛠️ **Administração** (escalas com backend, conteúdo, gabinete, métricas) —
  Pilar 4.
- 🐞 **Crash/Analytics** (ex.: Sentry) — decisão pós‑1.1.0 (sem Firebase).

> Referências: `docs/v2/GOEL_CHURCH_2_MASTER_PLAN.md`,
> `docs/v2/goel-message-hub.md`, `docs/KNOWN_ISSUES_1.1.0.md`.

## 8. Conclusão
> _A preencher no encerramento — declarar o resultado final da homologação e, se
> aplicável, o marco:_ **RELEASE READY FOR PRODUCTION** _(Críticos = 0 e
> Altos = 0)._

- _(a preencher)_

---

### Registro
```
GOEL CHURCH
DOCUMENTO  Release Retrospective 1.1.0
VERSÃO     1.1.0 (code 11) · code 10 SUPERSEDED
STATUS     EM ABERTO — concluir no encerramento da homologação
REGRA      Sem alteração na 1.1.0 · Sem implementação da V2.0
```
