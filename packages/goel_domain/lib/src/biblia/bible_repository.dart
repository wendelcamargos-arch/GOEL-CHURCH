import 'bible_models.dart';

/// Contrato do Bible Engine (offline-first). A implementação (camada de dados)
/// carrega o manifest e os livros sob demanda; o domínio não conhece assets.
abstract class BibleRepository {
  /// Lista os 66 livros (metadados do manifest).
  Future<List<BibleBookMeta>> livros();

  /// Carrega um capítulo (texto real dos versículos) sob demanda.
  Future<BibleChapter> capitulo(String bookId, int numero);

  /// Interpreta uma referência digitada ("João 3:16", "sl 23") → [VerseRef].
  Future<VerseRef?> resolverReferencia(String entrada);

  /// Busca por palavra; emite ocorrências à medida que encontra (offline).
  /// [testamento] opcional restringe o escopo a 'AT' ou 'NT'.
  Stream<SearchHit> buscarPalavra(String termo, {String? testamento});
}
