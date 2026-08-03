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
