import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/content/presentation/versiculo_screen.dart';
import 'package:goel_domain/goel_domain.dart';

class _FakeVerseRepository implements VerseRepository {
  @override
  Future<DailyVerse> verseForToday(DateTime today) async => const DailyVerse(
        reference: 'João 3:16',
        text: 'Porque Deus amou o mundo de tal maneira...',
      );
}

void main() {
  testWidgets('exibe o versículo do dia', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VersiculoScreen(repository: _FakeVerseRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('João 3:16'), findsOneWidget);
    expect(find.textContaining('Deus amou o mundo'), findsOneWidget);
  });
}
