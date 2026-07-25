import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:goel_domain/goel_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Devocionais publicados pela igreja (leitura pública no Supabase) com
/// offline-first: cache do último resultado + fallback local se offline.
class SupabaseDevotionalRepository implements DevotionalRepository {
  final SupabaseClient _client;

  List<Devotional>? _cache;
  List<Devotional>? _fallback;

  SupabaseDevotionalRepository(this._client);

  @override
  Future<List<Devotional>> list() async {
    try {
      final data = await _client
          .from('devotionals')
          .select()
          .eq('published', true)
          .order('published_at', ascending: false)
          .limit(50);
      final list = (data as List<dynamic>)
          .map((e) => _fromRow(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) {
        _cache = list;
        return list;
      }
    } catch (_) {
      // cai para cache/fallback
    }
    return _cache ?? await _loadFallback();
  }

  Devotional _fromRow(Map<String, dynamic> r) => Devotional(
        id: r['id'].toString(),
        title: r['title'] as String,
        body: r['body'] as String,
        author: r['author'] as String?,
        publishedAt: DateTime.parse(r['published_at'] as String),
      );

  Future<List<Devotional>> _loadFallback() async {
    _fallback ??= await _readFallbackAsset();
    return _fallback!;
  }

  Future<List<Devotional>> _readFallbackAsset() async {
    final raw =
        await rootBundle.loadString('assets/content/devotionals_fallback.json');
    return (jsonDecode(raw) as List<dynamic>)
        .map((e) => Devotional(
              id: e['id'] as String,
              title: e['title'] as String,
              body: e['body'] as String,
              author: e['author'] as String?,
              publishedAt: DateTime.parse(e['publishedAt'] as String),
            ))
        .toList();
  }
}
