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

  testWidgets('mostra o botão de ouvir a Palavra', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: VersiculoScreen(repository: _FakeVerseRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ouvir a Palavra'), findsOneWidget);
    // O gatilho só aparece ao final do áudio.
    expect(find.text(kGatilhoCompartilhar), findsNothing);
  });

  testWidgets('ao final do áudio, exibe o gatilho das 7 pessoas',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: VersiculoScreen(
          repository: _FakeVerseRepository(),
          debugStartCompleted: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(kGatilhoCompartilhar), findsOneWidget);
    expect(find.text('Compartilhar com 7 pessoas'), findsOneWidget);
  });
}
