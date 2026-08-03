import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/content/data/local_verse_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('carrega o versículo do dia da tradução de domínio público', () async {
    final repo = LocalVerseRepository();
    final verse = await repo.verseForToday(DateTime(2026, 1, 1));

    expect(verse.reference, isNotEmpty);
    expect(verse.text, isNotEmpty);
  });

  test('mesmo dia resolve o mesmo versículo (determinístico)', () async {
    final repo = LocalVerseRepository();
    final a = await repo.verseForToday(DateTime(2026, 7, 25));
    final b = await repo.verseForToday(DateTime(2026, 7, 25));
    expect(a.reference, b.reference);
  });

  // Sprint 5 — correção definitiva do defeito "apenas cinco versículos".
  test('a rotação carrega MUITO mais do que 5 versículos distintos', () async {
    final repo = LocalVerseRepository();
    final refs = <String>{};
    final base = DateTime(2026, 1, 1);
    for (var i = 0; i < 60; i++) {
      final v = await repo.verseForToday(base.add(Duration(days: i)));
      refs.add(v.reference);
    }
    // Antes o fallback limitava a 5. Agora o acervo é amplo (60+).
    expect(refs.length, greaterThan(5));
    expect(refs.length, greaterThanOrEqualTo(60));
  });
}
