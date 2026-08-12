import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:goel_domain/goel_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Versículo do dia com origem ONLINE (NVI, via Edge Function `verse-of-the-day`,
/// chave server-side) e FALLBACK OFFLINE de domínio público.
///
/// Robustez para o público idoso: se a rede/API falhar, ainda exibe algo —
/// o último versículo obtido ou o fallback local de domínio público.
///
/// Nota: os textos de fallback devem ser curados para uma edição confirmada de
/// domínio público (responsabilidade do owner).
class OnlineVerseRepository implements VerseRepository {
  final SupabaseClient _client;

  DailyVerse? _lastOnline;
  List<DailyVerse>? _fallback;

  OnlineVerseRepository(this._client);

  @override
  Future<DailyVerse> verseForToday(DateTime today) async {
    try {
      final res = await _client.functions.invoke('verse-of-the-day');
      final data = res.data as Map<String, dynamic>;
      if (data['status'] == 'ok') {
        final verse = DailyVerse(
          reference: data['reference'] as String,
          text: data['text'] as String,
        );
        _lastOnline = verse;
        return verse;
      }
    } catch (_) {
      // cai para o fallback abaixo
    }
    return _lastOnline ?? await _fallbackForToday(today);
  }

  Future<DailyVerse> _fallbackForToday(DateTime today) async {
    _fallback ??= await _loadFallback();
    return DailyVerseSelector.pick(_fallback!, today);
  }

  // Sprint 5 (correção do defeito "apenas 5 versículos"): o fallback usa a
  // MESMA fonte rica de domínio público do app (60+ versículos), e não mais o
  // antigo `verses_fallback.json` (que tinha só 5). Fonte única de verdade.
  Future<List<DailyVerse>> _loadFallback() async {
    final raw = await rootBundle
        .loadString('assets/content/versiculos_dominio_publico.json');
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((e) => DailyVerse(
              reference: e['reference'] as String,
              text: e['text'] as String,
            ),)
        .toList();
    return list;
  }
}
