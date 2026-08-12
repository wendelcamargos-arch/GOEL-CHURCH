import 'bible_models.dart';

/// Interpreta referências digitadas ("João 3:16", "sl 23", "1 co 13:4") e
/// resolve para [VerseRef], validando capítulo/versículo pelos metadados.
///
/// Precedência: **nome completo** vence a abreviação (evita ambiguidades de
/// acento, ex.: "jo" → Jó; para João use "joão"/"joao").
class ReferenceParser {
  final List<BibleBookMeta> livros;
  final Map<String, String> _index; // chave normalizada -> bookId

  ReferenceParser(this.livros) : _index = _buildIndex(livros);

  static const _acentos = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
  static const _limpos = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

  static String _norm(String s) {
    final sb = StringBuffer();
    for (final ch in s.trim().toLowerCase().split('')) {
      final i = _acentos.indexOf(ch);
      sb.write(i >= 0 ? _limpos[i].toLowerCase() : ch);
    }
    return sb.toString().replaceAll(RegExp(r'\s+'), ' ');
  }

  static Map<String, String> _buildIndex(List<BibleBookMeta> livros) {
    final m = <String, String>{};
    void put(String k, String id) => m.putIfAbsent(k, () => id);
    // 1) nomes completos (têm precedência)
    for (final b in livros) {
      final n = _norm(b.nome);
      put(n, b.id);
      put(n.replaceAll(' ', ''), b.id);
    }
    // 2) abreviações (só se ainda não houver a chave)
    for (final b in livros) {
      final a = _norm(b.abrev);
      put(a, b.id);
      put(a.replaceAll(' ', ''), b.id);
    }
    return m;
  }

  /// Nº mínimo de caracteres para a busca por prefixo dos nomes dos livros.
  /// Abaixo disso só há correspondência EXATA (nome completo ou abreviação),
  /// para "sl" não competir com uma digitação ainda em curso.
  static const minCaracteresPrefixo = 3;

  /// Busca **livros** por nome ou abreviação — case-insensitive e
  /// accent-insensitive. Usada para navegação ("rom" → Romanos), com
  /// prioridade sobre a busca textual nos versículos.
  ///
  /// Ordem de relevância:
  /// 0. nome completo exato ("romanos");
  /// 1. abreviação exata ("rm", "sl");
  /// 2. nome começa com o termo ("rom", "roma", "joa");
  /// 3. abreviação começa com o termo;
  /// 4. termo começa com a abreviação + 1 caractere ("slm" → Sl);
  /// 5. nome contém o termo ("samuel" → 1 Samuel, 2 Samuel).
  ///
  /// Empates preservam a ordem canônica (Gênesis → Apocalipse).
  List<BibleBookMeta> buscarLivros(String termo) {
    final q = _norm(termo).replaceAll(' ', '');
    if (q.isEmpty) return const [];
    final longoBastante = q.length >= minCaracteresPrefixo;

    final pontuados = <({int score, BibleBookMeta livro})>[];
    for (final b in livros) {
      final nome = _norm(b.nome).replaceAll(' ', '');
      final abrev = _norm(b.abrev).replaceAll(' ', '');
      final int? score;
      if (nome == q) {
        score = 0;
      } else if (abrev == q) {
        score = 1;
      } else if (!longoBastante) {
        score = null;
      } else if (nome.startsWith(q)) {
        score = 2;
      } else if (abrev.startsWith(q)) {
        score = 3;
      } else if (q.startsWith(abrev) && q.length <= abrev.length + 1) {
        score = 4;
      } else if (nome.contains(q)) {
        score = 5;
      } else {
        score = null;
      }
      if (score != null) pontuados.add((score: score, livro: b));
    }

    pontuados.sort((a, b) {
      final porScore = a.score.compareTo(b.score);
      return porScore != 0 ? porScore : a.livro.ordem.compareTo(b.livro.ordem);
    });
    return [for (final p in pontuados) p.livro];
  }

  /// Resolve a referência; retorna `null` se o livro/capítulo/versículo forem
  /// inválidos ou o texto não puder ser interpretado.
  VerseRef? resolve(String entrada) {
    final norm = _norm(entrada);
    final match = RegExp(r'^(.+?)\s*(\d+)(?::(\d+))?$').firstMatch(norm);
    if (match == null) return null;
    final nome = match.group(1)!.trim();
    final cap = int.parse(match.group(2)!);
    final ver = match.group(3) != null ? int.parse(match.group(3)!) : null;

    final id = _index[nome] ?? _index[nome.replaceAll(' ', '')];
    if (id == null) return null;

    final meta = livros.firstWhere((b) => b.id == id);
    if (cap < 1 || cap > meta.totalCapitulos) return null;
    if (ver != null) {
      final vmax = meta.versiculosDoCapitulo(cap);
      if (ver < 1 || ver > vmax) return null;
    }
    return VerseRef(id, cap, ver);
  }
}
