# Sprint 5 — GOEL CHURCH · BIBLE ENGINE (apresentação p/ aprovação)

> Arquitetura aprovada. Antes de escrever código, apresenta-se: fonte de dados,
> estrutura de JSON, diretórios, manifest, pipeline de importação e cache.
> **Nenhuma importação/implementação inicia antes da aprovação. Nenhuma Release
> antes da conclusão da Sprint.**

---

## PARTE 1 — Fonte de dados (aprovar antes de importar)

### Origem
- **Tradução:** João Ferreira de Almeida — **edição de 1911** (revista).
- **Digitalização candidata:** projeto **JFAAL** (pasta `original`), que fornece
  o texto 1911 em JSON no formato `[{abbrev, book, chapters:[[...]]}]`.

### Licença
- **Domínio público** por antiguidade: obra de 1911 (mais de 110 anos); Almeida
  faleceu em 1691. No Brasil, obras assim já são de domínio público.
- ⚠️ **Não** usaremos ACF, ARA/RA nem NVI — essas têm direitos reservados
  (SBTB / SBB / Bíblica). O dataset thiagobodruk (AA/ACF/NVI) é **CC BY-NC com
  direitos reservados** → **descartado**.
- Nota: a transcrição do JFAAL pede atribuição (CC BY 3.0 BR) para a *edição
  digital* deles; o **texto-base 1911 é PD**. Podemos (a) usar a transcrição
  JFAAL com o devido crédito, ou (b) usar outra digitalização PD sem exigência
  de atribuição. **Decisão do Owner.**

### Contagem (alvo canônico — validado na importação)
- **66** livros · **1.189** capítulos · **31.102** versículos (cânon protestante).
- O pipeline de importação **falha** se as contagens não baterem (ver Parte 6).
- Exemplos de verificação: Gênesis 50 cap.; Salmos 150 cap. / Sl 119 = 176
  versículos; Sl 117 = 2 versículos; Apocalipse 22 cap.

**→ Aprovar a fonte (origem + licença + atribuição) antes de eu importar.**

---

## PARTE 2 — Estrutura de diretórios

```
assets/biblia/
  manifest.json                 # metadados (1x, pequeno)
  livros/                        # conteúdo — 1 arquivo por livro (66), sob demanda
    genesis.json … apocalipse.json
  planos/                        # planos de leitura (EU-05)
    30-dias.json  90-dias.json  anual.json

lib/features/biblia/
  data/
    asset_bible_repository.dart  # implementa o contrato (manifest + livros, cache LRU)
    bible_manifest.dart          # carrega/valida o manifest
    bible_search.dart            # busca por palavra em isolate (Stream)
    reading_store.dart           # persistência (SharedPreferences): favoritos,
                                 # marca-textos, anotações, histórico, plano,
                                 # "continue lendo", fonte, tema do leitor
  presentation/
    biblia_screen.dart           # livros (usa manifest)
    capitulos_screen.dart        # capítulos
    leitura_screen.dart          # REESCRITA: scroll contínuo, ações no versículo,
                                 # fonte, tema do leitor, modo púlpito, modo culto
    busca_screen.dart            # pesquisa palavra + referência
    favoritos_screen.dart        # favoritos + anotações + marca-textos
    planos_screen.dart           # planos de leitura + progresso
    verse_share_card.dart        # card de imagem do versículo (identidade Goel)

packages/goel_domain/lib/src/biblia/
  bible_models.dart              # BibleBookMeta, BibleChapter, VerseRef
  bible_repository.dart          # CONTRATO
  reading_models.dart            # Highlight, Note, Favorite, HistoryEntry, PlanProgress
  reference_parser.dart          # "João 3:16", "sl 23", "1 co 13:4" → VerseRef

tool/
  build_biblia.dart              # pipeline de importação (roda 1x, local)
```

## PARTE 3 — Formato dos JSON

### `manifest.json` (metadados; permite navegar/validar sem abrir livros)
```json
{
  "traducao": "Almeida 1911 — Domínio Público",
  "versao": 1,
  "livros": [
    { "id": "genesis", "nome": "Gênesis", "abrev": "Gn",
      "testamento": "AT", "ordem": 1,
      "versiculosPorCapitulo": [31, 25, 24, "…50 itens…"] }
  ]
}
```

### `livros/<id>.json` (conteúdo — carregado sob demanda, 1 livro por vez)
```json
{
  "id": "joao", "nome": "João", "abrev": "Jo",
  "capitulos": [
    ["No princípio era o Verbo…", "Ele estava no princípio com Deus…"]
  ]
}
```
`capitulos[c-1][v-1]` = texto. (Mesma forma do dataset de origem → import direto.)

### `planos/<id>.json` (EU-05)
```json
{ "id": "anual", "nome": "Bíblia em 1 ano", "dias": 365,
  "leituras": [ ["genesis 1", "genesis 2", "genesis 3"], ["genesis 4", "…"] ] }
```

## PARTE 4 — Estado do usuário (offline, SharedPreferences)
Conteúdo bíblico é **imutável** (assets). O que o usuário cria fica em
`reading_store` (JSON em SharedPreferences):
- `favoritos: [ref]` (EU-01)
- `marcaTextos: { ref: cor }` — amarelo/verde/azul/rosa (EU-02)
- `anotacoes: { ref: texto }` (EU-03)
- `historico: [ {ref, ts} ]` (EU-06)
- `continueLendo: { bookId, capitulo, offset }` (EU-07)
- `planoProgresso: { planoId, diaAtual }` (EU-05)
- `fonte: double`, `temaLeitor: claro|escuro` (EU-09 / Tema do leitor)

## PARTE 5 — Estratégia de cache e carregamento
- **manifest**: carregado 1x no `AssetBibleRepository`, mantido em memória (pequeno).
- **Livros**: **cache LRU** de N (ex.: 3) livros decodificados (`List<List<String>>`).
  Acesso a capítulo = índice O(1). Ao exceder N, descarta o menos usado (memória
  limitada — nunca a Bíblia inteira).
- **Scroll contínuo**: `ListView.builder` renderiza o capítulo atual e, ao fim,
  anexa o próximo (mesmo livro = instantâneo; próximo livro = carrega o arquivo).
- **Busca por palavra**: roda em **isolate**, lê os arquivos de livro em
  sequência (sem poluir o LRU do leitor), emite ocorrências por `Stream` com
  referência + trecho. Escopo opcional (AT/NT/livro).
- **Busca contextual futura (EU-08)**: contrato `SearchStrategy` abstrato — hoje
  `KeywordSearch`; amanhã pluga-se `ContextualSearch` sem mudar a UI.

## PARTE 6 — Pipeline de importação (`tool/build_biblia.dart`, roda 1x)
1. Lê o dataset de origem (Almeida 1911, formato `[{abbrev, book, chapters}]`).
2. Mapeia cada livro → `id` (slug), `nome`, `abrev` (pt), `testamento`, `ordem`.
3. **Valida** contra a tabela canônica: 66 livros; contagem de capítulos por
   livro; total 1.189 capítulos; 31.102 versículos. **Aborta** se divergir.
4. Emite `manifest.json` + `livros/<id>.json` (formato compacto do app).
5. Imprime relatório de contagens para conferência do Owner.
6. (Só então) registra `assets/biblia/` no `pubspec.yaml` e commita.

## PARTE 7 — Novas dependências (todas offline, sem API)
- `shared_preferences` — persistência do estado do usuário.
- `share_plus` — compartilhar **texto e imagem** do versículo (EU-04).
- `wakelock_plus` — **Modo culto**: manter a tela ligada durante a leitura (EU-10).
- (Captura da imagem do versículo: `RepaintBoundary` nativo do Flutter — sem dep.)

## PARTE 8 — Recursos ampliados (EU-01…EU-10) → onde vivem
| EU | Recurso | Camada |
|----|---------|--------|
| 01 | Favoritos | reading_store + favoritos_screen |
| 02 | Marca-texto (4 cores) | reading_store + leitura_screen |
| 03 | Anotações por versículo | reading_store + leitura_screen |
| 04 | Compartilhar imagem (identidade Goel) | verse_share_card + share_plus |
| 05 | Plano de leitura (30/90/anual) | planos/*.json + planos_screen |
| 06 | Histórico | reading_store |
| 07 | Continue lendo | reading_store + leitura_screen |
| 08 | Busca palavra/referência (+contextual futura) | bible_search + reference_parser |
| 09 | Modo púlpito (fonte ampliada) | leitura_screen |
| 10 | Modo culto (tela sempre ligada) | leitura_screen + wakelock_plus |

## PARTE 9 — Testes previstos
- Manifest: 66 livros; contagens canônicas; 1.189 capítulos.
- Cada livro carrega; capítulos/versículos batem com o manifest.
- Capítulo longo (Sl 119 = 176 v.) exibe todos; capítulo curto (Sl 117 = 2 v.).
- Referência: parse válido/inválido.
- Busca por palavra: termo conhecido → ocorrências esperadas.
- Favoritos / marca-texto / anotações: adicionar, remover, persistir.
- Plano de leitura: progresso avança e persiste.
- Compartilhar (texto e formato do card de imagem).

## PARTE 10 — Arquitetura preservada
Domain (Dart puro) · Contracts (`BibleRepository`, `SearchStrategy`) ·
Repository (`AssetBibleRepository`) · **offline-first** · **sem API externa**.

---

### Aprovações necessárias antes de codar
1. **Fonte de dados** (Parte 1): edição 1911 PD + decisão sobre atribuição JFAAL.
2. **Novas dependências** (Parte 7): shared_preferences, share_plus, wakelock_plus.
