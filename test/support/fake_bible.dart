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
      versiculosPorCapitulo: [3],
    ),
  ];

  @override
  Future<List<BibleBookMeta>> livros() async => _livros;

  @override
  Future<BibleChapter> capitulo(String bookId, int numero) async {
    if (bookId == 'genesis') {
      return const BibleChapter(
        bookId: 'genesis',
        numero: 1,
        versiculos: [
          'No principio creou Deus os céus e a terra.',
          'E a terra era sem forma e vazia.',
        ],
      );
    }
    return const BibleChapter(
      bookId: 'joao',
      numero: 1,
      versiculos: ['No principio era o Verbo.'],
    );
  }

  @override
  Future<VerseRef?> resolverReferencia(String entrada) async => null;

  @override
  Stream<SearchHit> buscarPalavra(String termo, {String? testamento}) async* {}
}
