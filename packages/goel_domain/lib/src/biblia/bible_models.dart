// Modelos do Bible Engine (Dart puro — Framework Independence).

/// Metadados de um livro (do manifest). NÃO contém o texto dos versículos.
class BibleBookMeta {
  final String id;
  final String nome;
  final String abrev;
  final String testamento; // 'AT' | 'NT'
  final int ordem; // 1..66
  final List<int> versiculosPorCapitulo;

  const BibleBookMeta({
    required this.id,
    required this.nome,
    required this.abrev,
    required this.testamento,
    required this.ordem,
    required this.versiculosPorCapitulo,
  });

  int get totalCapitulos => versiculosPorCapitulo.length;

  /// Nº de versículos de um capítulo (1-based). 0 se o capítulo não existir.
  int versiculosDoCapitulo(int capitulo) {
    if (capitulo < 1 || capitulo > versiculosPorCapitulo.length) return 0;
    return versiculosPorCapitulo[capitulo - 1];
  }

  bool get isAntigoTestamento => testamento == 'AT';
}

/// Um capítulo carregado (texto real dos versículos). `versiculos[i]` = versículo
/// de número `i + 1`.
class BibleChapter {
  final String bookId;
  final int numero;
  final List<String> versiculos;

  const BibleChapter({
    required this.bookId,
    required this.numero,
    required this.versiculos,
  });

  int get totalVersiculos => versiculos.length;
}

/// Referência canônica: livro + capítulo (+ versículo opcional).
class VerseRef {
  final String bookId;
  final int capitulo;

  /// Nulo → capítulo inteiro.
  final int? versiculo;

  const VerseRef(this.bookId, this.capitulo, [this.versiculo]);

  /// Chave estável para persistência (favoritos, marca-textos, anotações).
  String get chave =>
      versiculo == null ? '$bookId:$capitulo' : '$bookId:$capitulo:$versiculo';

  static VerseRef? fromChave(String chave) {
    final p = chave.split(':');
    if (p.length < 2) return null;
    final c = int.tryParse(p[1]);
    if (p[0].isEmpty || c == null) return null;
    final v = p.length >= 3 ? int.tryParse(p[2]) : null;
    return VerseRef(p[0], c, v);
  }

  @override
  bool operator ==(Object other) =>
      other is VerseRef &&
      other.bookId == bookId &&
      other.capitulo == capitulo &&
      other.versiculo == versiculo;

  @override
  int get hashCode => Object.hash(bookId, capitulo, versiculo);

  @override
  String toString() => chave;
}

/// Ocorrência de busca por palavra.
class SearchHit {
  final VerseRef ref;
  final String livroNome;
  final String livroAbrev;
  final String texto;

  const SearchHit({
    required this.ref,
    required this.livroNome,
    required this.livroAbrev,
    required this.texto,
  });

  /// Rótulo curto da referência (ex.: "Jo 3:16").
  String get rotulo => '$livroAbrev ${ref.capitulo}:${ref.versiculo}';
}
