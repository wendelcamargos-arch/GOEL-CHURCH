import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:goel_domain/goel_domain.dart';

/// Implementação offline do [BibleRepository] (Almeida 1911, domínio público).
///
/// Carrega o `manifest.json` uma vez e os livros **sob demanda** com **cache
/// LRU** (nunca a Bíblia inteira em memória). A busca por palavra varre os
/// arquivos de livro sem poluir o cache de leitura.
class AssetBibleRepository implements BibleRepository {
  static const _dir = 'assets/biblia';
  static const _maxCache = 3;

  List<BibleBookMeta>? _livros;
  ReferenceParser? _parser;
  final Map<String, List<List<String>>> _cache = {};
  final List<String> _ordemLru = [];

  @override
  Future<List<BibleBookMeta>> livros() async {
    return _livros ??= await _carregarManifest();
  }

  Future<List<BibleBookMeta>> _carregarManifest() async {
    final raw = await rootBundle.loadString('$_dir/manifest.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final ls = (data['livros'] as List).cast<Map<String, dynamic>>();
    return [
      for (final m in ls)
        BibleBookMeta(
          id: m['id'] as String,
          nome: m['nome'] as String,
          abrev: m['abrev'] as String,
          testamento: m['testamento'] as String,
          ordem: (m['ordem'] as num).toInt(),
          versiculosPorCapitulo:
              (m['versiculosPorCapitulo'] as List).map((e) => (e as num).toInt()).toList(),
        ),
    ];
  }

  @override
  Future<BibleChapter> capitulo(String bookId, int numero) async {
    final caps = await _livroCacheado(bookId);
    if (numero < 1 || numero > caps.length) {
      throw RangeError('Capítulo $numero inexistente em "$bookId".');
    }
    return BibleChapter(
      bookId: bookId,
      numero: numero,
      versiculos: caps[numero - 1],
    );
  }

  @override
  Future<VerseRef?> resolverReferencia(String entrada) async {
    _parser ??= ReferenceParser(await livros());
    return _parser!.resolve(entrada);
  }

  @override
  Stream<SearchHit> buscarPalavra(String termo, {String? testamento}) async* {
    final q = _normalizar(termo);
    if (q.isEmpty) return;
    final ls = await livros();
    for (final b in ls) {
      if (testamento != null && b.testamento != testamento) continue;
      final caps = await _decodificarLivro(b.id); // sem poluir o LRU
      for (var c = 0; c < caps.length; c++) {
        final versos = caps[c];
        for (var v = 0; v < versos.length; v++) {
          if (_normalizar(versos[v]).contains(q)) {
            yield SearchHit(
              ref: VerseRef(b.id, c + 1, v + 1),
              livroNome: b.nome,
              livroAbrev: b.abrev,
              texto: versos[v],
            );
          }
        }
      }
    }
  }

  // --- cache LRU ---

  Future<List<List<String>>> _livroCacheado(String bookId) async {
    final cached = _cache[bookId];
    if (cached != null) {
      _ordemLru
        ..remove(bookId)
        ..add(bookId);
      return cached;
    }
    final caps = await _decodificarLivro(bookId);
    _cache[bookId] = caps;
    _ordemLru.add(bookId);
    while (_ordemLru.length > _maxCache) {
      _cache.remove(_ordemLru.removeAt(0));
    }
    return caps;
  }

  Future<List<List<String>>> _decodificarLivro(String bookId) async {
    final raw = await rootBundle.loadString('$_dir/livros/$bookId.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return [
      for (final c in (data['capitulos'] as List)) (c as List).cast<String>(),
    ];
  }

  static const _acentos = 'áàâãäéèêëíìîïóòôõöúùûüç';
  static const _limpos = 'aaaaaeeeeiiiiooooouuuuc';

  static String _normalizar(String s) {
    final sb = StringBuffer();
    for (final ch in s.trim().toLowerCase().split('')) {
      final i = _acentos.indexOf(ch);
      sb.write(i >= 0 ? _limpos[i] : ch);
    }
    return sb.toString();
  }
}
