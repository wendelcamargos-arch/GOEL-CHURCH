# Sprint 5 — Bíblia Offline (PLANO — aguardando aprovação do Owner)

> Nenhuma implementação inicia antes da aprovação. Nenhuma Release antes da
> conclusão desta Sprint.

## 1. Objetivo
Leitor completo da Bíblia, **100% offline**, tradução **Almeida — Domínio
Público**, sem placeholders, sem "Em breve", sem API externa.

## 2. Arquitetura (mantém Domain / Contracts / Repository / offline-first)

```
Camadas
 goel_domain (Dart puro — regras/contratos, sem Flutter)
   ├─ BibleBookMeta (id, nome, abrev, testamento, versiculosPorCapitulo[])
   ├─ BibleChapter (bookId, numero, versiculos: List<String>)
   ├─ VerseRef (bookId, capitulo, versiculo)  + parse/format
   ├─ BibleRepository (CONTRATO)
   │     books() : List<BibleBookMeta>
   │     chapter(bookId, n) : BibleChapter
   │     resolveReference(String) : VerseRef?         // "João 3:16", "sl 23"
   │     search(query, escopo) : Stream<SearchHit>    // por palavra
   └─ ReadingState (favoritos, últimaLeitura, fonte, tema) — modelo

 lib/features/biblia/data
   ├─ asset_bible_repository.dart   // implementa BibleRepository via JSON assets
   ├─ bible_manifest.dart           // carrega o manifest (metadados, 1x)
   ├─ bible_search.dart             // busca por palavra em isolate (stream)
   └─ reading_state_store.dart      // SharedPreferences (prefs/favoritos/posição)

 lib/features/biblia/presentation
   ├─ biblia_screen.dart      // livros (já existe — passa a usar o manifest)
   ├─ capitulos_screen.dart   // capítulos (já existe)
   ├─ leitura_screen.dart     // REESCRITA: scroll contínuo real, fonte, ações
   ├─ busca_screen.dart       // NOVO: pesquisa por palavra e por referência
   └─ favoritos_screen.dart   // NOVO: lista de favoritos
```

## 3. Formato dos JSONs (offline, sob demanda)

Um arquivo **por livro** (66 arquivos) + um **manifest** pequeno de metadados.
Assim carregamos **Livro → Capítulo → Versículos sob demanda** e **nunca a
Bíblia inteira** de uma vez.

### 3.1 `assets/biblia/manifest.json` (carregado 1x — só metadados, poucos KB)
```json
{
  "traducao": "Almeida — Domínio Público",
  "livros": [
    { "id": "genesis", "nome": "Gênesis", "abrev": "Gn", "testamento": "AT",
      "versiculosPorCapitulo": [31, 25, 24, 26, 32, "…50 itens…"] },
    { "id": "salmos", "nome": "Salmos", "abrev": "Sl", "testamento": "AT",
      "versiculosPorCapitulo": [6, 12, 8, "…150 itens…"] }
  ]
}
```
- `versiculosPorCapitulo.length` = nº de capítulos; cada valor = nº de
  versículos (permite navegação e validação de referência **sem** abrir o livro).

### 3.2 `assets/biblia/livros/<id>.json` (carregado sob demanda, 1 livro por vez)
```json
{
  "id": "joao",
  "nome": "João",
  "capitulos": [
    ["No princípio era o Verbo…", "Ele estava no princípio com Deus…"],
    ["E, ao terceiro dia, houve…"]
  ]
}
```
- `capitulos[c-1][v-1]` = texto do versículo. Formato compacto (arrays),
  parse rápido, um livro por vez em memória (ex.: Salmos ~2.461 versículos ≈
  poucas centenas de KB — nunca a Bíblia toda).

## 4. Estratégia de carregamento
- **Início:** carrega `manifest.json` (metadados) uma única vez → lista de
  livros e contagens. Cache em memória (pequeno).
- **Leitura:** ao abrir um capítulo, carrega `livros/<id>.json` (1 livro),
  mantém em cache LRU (1–2 livros). Trocar de capítulo no mesmo livro é
  instantâneo.
- **Scroll contínuo:** a `LeituraScreen` renderiza o capítulo atual e, ao
  chegar ao fim, **anexa o próximo capítulo** (e, no fim do livro, rola para o
  próximo livro carregando o arquivo dele). `ListView.builder` (lazy).
- **Abrir referência direta:** `resolveReference("João 3:16")` valida pelo
  manifest e navega direto ao versículo.
- **Pesquisa por palavra:** roda em **isolate** varrendo os arquivos de livro
  (66) e emitindo resultados em `Stream` (com destaque/《snippet》 e referência),
  com escopo opcional (AT/NT/livro). Não carrega tudo em memória de uma vez.

## 5. Persistência (SharedPreferences — offline, sem API)
- `favoritos`: lista de referências (`bookId:cap:ver`).
- `ultimaLeitura`: `bookId`, capítulo e posição de scroll (retomar onde parou).
- `tamanhoFonte`: double (ajuste do leitor).
- `tema`: claro/escuro (ver decisão pendente nº 3).

## 6. Ações no versículo
- **Compartilhar** (WhatsApp/sistema) e **Copiar** — formato:
  `"<texto>"  — <Livro> <cap>:<ver>  · Almeida (Domínio Público) · Goel Church`.
- **Favoritar** (toggle) — persiste.

## 7. Plano de migração (dados)
1. **Fonte:** obter um dataset **comprovadamente de Domínio Público** da Almeida
   (ex.: edições PD "Almeida Recebida"/"Tradução Brasileira"/edição 1911).
   ⚠️ ACF/ARA/NVI **não** são domínio público. **Decisão do Owner nº 1.**
2. **Build script** (`tool/build_biblia.dart`) converte a fonte → 66 arquivos
   `livros/<id>.json` + `manifest.json`, **validando as contagens canônicas**
   (66 livros, 1.189 capítulos, ~31.102 versículos).
3. Registrar assets no `pubspec.yaml` (`assets/biblia/`).
4. Implementar domínio → repositório → UI → persistência.
5. QA de contagem (ex.: Salmos 119 = 176 versículos aparecem **todos**).

## 8. Testes (mínimos)
- Manifest: 66 livros; contagens de capítulos canônicas (Gn 50, Sl 150, Ap 22…);
  total 1.189 capítulos.
- Cada livro carrega; nº de capítulos e de versículos batem com o manifest.
- **Capítulo longo** (Salmos 119 = 176 v.) exibe todos — nunca "só 5".
- **Capítulo curto** (Salmos 117 = 2 v.).
- Referência: parse válido/ inválido ("João 3:16", "Sl 23", "xyz 9:9").
- Pesquisa por palavra: termo conhecido retorna ocorrências esperadas.
- Favoritos: adicionar/remover/persistir.
- Compartilhar/Copiar: formato correto.

## 9. Decisões pendentes do Owner (antes de implementar)
1. **Fonte de dados PD da Almeida** — qual edição/origem usar (licenciamento).
   Posso propor uma edição PD e trazer para conferência.
2. **Armazenamento:** recomendo **JSON por livro** (Dart puro, testável, sem
   dependência nativa). Alternativa: **SQLite (sqflite)** — ótimo para busca
   (FTS), mas adiciona dependência nativa e um .db pré-construído. **Recomendo
   JSON por livro.**
3. **Tema claro/escuro:** hoje o app é **sempre escuro** (identidade P&B). O
   escopo pede claro/escuro — confirmar se o toggle é só no leitor ou no app
   inteiro (muda a identidade atual).
4. **Interim (caminho C):** ocultar/parar a aba **Bíblia** já agora enquanto a
   Sprint roda? (Como não haverá Release até concluir, é opcional.)

## 10. Não faz parte desta Sprint
Nenhuma outra funcionalidade. Nenhuma Release até a conclusão.
