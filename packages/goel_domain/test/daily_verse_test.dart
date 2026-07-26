import 'package:goel_domain/goel_domain.dart';
import 'package:test/test.dart';

void main() {
  const verses = [
    DailyVerse(reference: 'A', text: 'a'),
    DailyVerse(reference: 'B', text: 'b'),
    DailyVerse(reference: 'C', text: 'c'),
  ];

  group('DailyVerseSelector', () {
    test('mesmo dia resolve o mesmo versículo', () {
      final d = DateTime(2026, 7, 25);
      expect(
        DailyVerseSelector.pick(verses, d).reference,
        DailyVerseSelector.pick(verses, d).reference,
      );
    });

    test('rotaciona deterministicamente por dia', () {
      expect(DailyVerseSelector.pick(verses, DateTime(2026, 1, 1)).reference, 'A');
      expect(DailyVerseSelector.pick(verses, DateTime(2026, 1, 2)).reference, 'B');
      expect(DailyVerseSelector.pick(verses, DateTime(2026, 1, 3)).reference, 'C');
      expect(DailyVerseSelector.pick(verses, DateTime(2026, 1, 4)).reference, 'A');
    });

    test('lista vazia lança StateError', () {
      expect(() => DailyVerseSelector.pick([], DateTime(2026)), throwsStateError);
    });
  });
}
