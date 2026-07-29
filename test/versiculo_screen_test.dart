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
  });

  testWidgets('na tela só há o botão de compartilhar; a frase aparece ao tocar',
      (tester) async {
    // Viewport alto: o botão fica dentro da área tocável do teste.
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: VersiculoScreen(repository: _FakeVerseRepository())),
    );
    await tester.pumpAndSettle();

    // Botão presente; a frase-gatilho ainda NÃO aparece na tela.
    expect(find.text('Compartilhar'), findsOneWidget);
    expect(find.text(kGatilhoCompartilhar), findsNothing);

    // Ao tocar em "Compartilhar", a frase-gatilho surge na folha.
    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(find.text(kGatilhoCompartilhar), findsOneWidget);
    expect(find.text('Compartilhar no WhatsApp'), findsOneWidget);
    expect(find.text('Copiar texto'), findsOneWidget);
  });
}
