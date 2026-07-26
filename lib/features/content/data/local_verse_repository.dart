import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:goel_domain/goel_domain.dart';

/// Versículo do dia a partir de uma tradução de DOMÍNIO PÚBLICO
/// (Almeida antiga / Tradução Brasileira), empacotada no app.
///
/// Decisão Opção A: offline-first PRIMÁRIO, sem licença, sem custo, sem rede.
/// A seleção é determinística por dia (mesmo dia → mesmo versículo).
/// A NVI licenciada (via [OnlineVerseRepository]) fica como upgrade futuro.
class LocalVerseRepository implements VerseRepository {
  List<DailyVerse>? _cache;

  @override
  Future<DailyVerse> verseForToday(DateTime today) async {
    _cache ??= await _load();
    return DailyVerseSelector.pick(_cache!, today);
  }

  Future<List<DailyVerse>> _load() async {
    final raw = await rootBundle
        .loadString('assets/content/versiculos_dominio_publico.json');
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => DailyVerse(
              reference: e['reference'] as String,
              text: e['text'] as String,
            ),)
        .toList();
  }
}
