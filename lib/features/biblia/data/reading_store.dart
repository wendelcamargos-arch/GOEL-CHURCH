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
}
