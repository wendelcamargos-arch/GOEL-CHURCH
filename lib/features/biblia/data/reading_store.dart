import 'package:shared_preferences/shared_preferences.dart';

/// Persistência offline do Bible Engine (SharedPreferences).
///
/// Guarda o estado do usuário — o conteúdo bíblico é imutável (assets). Cresce
/// por etapa: favoritos (EU-01) agora; marca-textos, anotações, histórico,
/// "continue lendo" e progresso de plano nas etapas seguintes.
class ReadingStore {
  final SharedPreferences _prefs;
  ReadingStore(this._prefs);

  static Future<ReadingStore> abrir() async =>
      ReadingStore(await SharedPreferences.getInstance());

  static const _kFavoritos = 'biblia.favoritos';
  static const _kUltimaLeitura = 'biblia.ultimaLeitura';
  static const _kHistorico = 'biblia.historico';
  static const _kMarcas = 'biblia.marcas'; // "chave=cor" por linha
  static const _kNotas = 'biblia.notas.'; // prefixo + chave
  static const _maxHistorico = 50;

  // --- Favoritos (EU-01) ---

  /// Lista de referências favoritadas (chaves "bookId:cap:ver"), mais recentes
  /// ao final.
  List<String> favoritos() => _prefs.getStringList(_kFavoritos) ?? const [];

  bool isFavorito(String chave) => favoritos().contains(chave);

  /// Alterna o favorito; retorna `true` se passou a ser favorito.
  Future<bool> alternarFavorito(String chave) async {
    final f = favoritos().toList();
    final removeu = f.remove(chave);
    if (!removeu) f.add(chave);
    await _prefs.setStringList(_kFavoritos, f);
    return !removeu;
  }

  // --- Progresso dos planos de leitura (EU-05 / EU-12) ---

  String _kPlano(String planoId) => 'biblia.plano.$planoId';

  /// Dias já lidos (1-based) de um plano.
  Set<int> diasLidos(String planoId) =>
      (_prefs.getStringList(_kPlano(planoId)) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  bool diaLido(String planoId, int dia) => diasLidos(planoId).contains(dia);

  /// Marca/desmarca um dia como lido; retorna `true` se ficou lido.
  Future<bool> alternarDia(String planoId, int dia) async {
    final dias = diasLidos(planoId);
    // remove() retorna true se estava lido → então desmarcamos (agora = false).
    final agora = !dias.remove(dia);
    if (agora) dias.add(dia);
    await _prefs.setStringList(
      _kPlano(planoId),
      dias.map((d) => '$d').toList(),
    );
    return agora;
  }

  // --- Continue lendo (EU-07) ---

  /// Guarda a última posição de leitura (bookId + capítulo).
  Future<void> salvarUltimaLeitura(String bookId, int capitulo) =>
      _prefs.setString(_kUltimaLeitura, '$bookId:$capitulo');

  /// Última posição, ou nulo se nunca leu.
  ({String bookId, int capitulo})? ultimaLeitura() {
    final v = _prefs.getString(_kUltimaLeitura);
    if (v == null) return null;
    final p = v.split(':');
    final c = p.length >= 2 ? int.tryParse(p[1]) : null;
    if (p[0].isEmpty || c == null) return null;
    return (bookId: p[0], capitulo: c);
  }

  // --- Histórico (EU-06) ---

  /// Registra um capítulo lido no topo do histórico (sem duplicar em sequência).
  Future<void> registrarHistorico(String bookId, int capitulo) async {
    final chave = '$bookId:$capitulo';
    final h = List<String>.from(_prefs.getStringList(_kHistorico) ?? const [])
      ..remove(chave);
    h.insert(0, chave);
    if (h.length > _maxHistorico) h.removeRange(_maxHistorico, h.length);
    await _prefs.setStringList(_kHistorico, h);
  }

  /// Histórico (mais recentes primeiro) como "bookId:cap".
  List<String> historico() => _prefs.getStringList(_kHistorico) ?? const [];

  // --- Marca-texto (EU-02) ---

  Map<String, String> _marcasMap() {
    final res = <String, String>{};
    for (final linha in _prefs.getStringList(_kMarcas) ?? const <String>[]) {
      final i = linha.indexOf('=');
      if (i > 0) res[linha.substring(0, i)] = linha.substring(i + 1);
    }
    return res;
  }

  /// Mapa completo de marca-textos (chave → cor).
  Map<String, String> marcas() => _marcasMap();

  /// Cor da marca-texto do versículo (amarelo/verde/azul/rosa), ou nulo.
  String? corVersiculo(String chave) => _marcasMap()[chave];

  /// Define a cor (nula/'' remove a marca).
  Future<void> marcarVersiculo(String chave, String? cor) async {
    final m = _marcasMap();
    if (cor == null || cor.isEmpty) {
      m.remove(chave);
    } else {
      m[chave] = cor;
    }
    await _prefs.setStringList(
      _kMarcas,
      [for (final e in m.entries) '${e.key}=${e.value}'],
    );
  }

  // --- Anotações / Notas pessoais (EU-03 / EU-11) ---

  String? anotacao(String chave) => _prefs.getString('$_kNotas$chave');

  Future<void> salvarAnotacao(String chave, String texto) async {
    if (texto.trim().isEmpty) {
      await _prefs.remove('$_kNotas$chave');
    } else {
      await _prefs.setString('$_kNotas$chave', texto.trim());
    }
  }
}
