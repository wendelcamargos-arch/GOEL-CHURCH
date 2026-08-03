import 'package:goel_domain/goel_domain.dart';

/// Repositório da Bíblia em memória para widget tests (os assets reais são
/// cobertos por bible_repository_test).
class FakeBibleRepository implements BibleRepository {
  static const _livros = [
    BibleBookMeta(
      id: 'genesis',
      nome: 'Gênesis',
      abrev: 'Gn',
      testamento: 'AT',
      ordem: 1,
      versiculosPorCapitulo: [2],
    ),
    BibleBookMeta(
      id: 'joao',
      nome: 'João',
      abrev: 'Jo',
      testamento: 'NT',
      ordem: 43,
      versiculosPorCapitulo: [1],
    ),
  ];

  static const Map<String, List<List<String>>> _dados = {
    'genesis': [
      [
        'No principio creou Deus os céus e a terra.',
        'E a terra era sem forma e vazia.',
      ],
    ],
    'joao': [
      ['No principio era o Verbo.'],
    ],
  };

  @override
  Future<List<BibleBookMeta>> livros() async => _livros;

  @override
  Future<BibleChapter> capitulo(String bookId, int numero) async {
    return BibleChapter(
      bookId: bookId,
      numero: numero,
      versiculos: _dados[bookId]![numero - 1],
    );
  }

  @override
  Future<VerseRef?> resolverReferencia(String entrada) async =>
      ReferenceParser(_livros).resolve(entrada);

  @override
  Stream<SearchHit> buscarPalavra(String termo, {String? testamento}) async* {
    final q = termo.toLowerCase().trim();
    if (q.isEmpty) return;
    for (final b in _livros) {
      if (testamento != null && b.testamento != testamento) continue;
      final caps = _dados[b.id]!;
      for (var c = 0; c < caps.length; c++) {
        for (var v = 0; v < caps[c].length; v++) {
          if (caps[c][v].toLowerCase().contains(q)) {
            yield SearchHit(
              ref: VerseRef(b.id, c + 1, v + 1),
              livroNome: b.nome,
              livroAbrev: b.abrev,
              texto: caps[c][v],
            );
          }
        }
      }
    }
  }
}
