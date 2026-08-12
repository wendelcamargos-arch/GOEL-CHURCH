import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/presentation/biblia_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_bible.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'Bíblia: Livro → Capítulo → Versículo → Leitor, com o texto real',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BibliaScreen(repository: FakeBibleRepository())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antigo Testamento'), findsOneWidget);
    expect(find.text('Novo Testamento'), findsOneWidget);
    expect(find.text('Gênesis'), findsOneWidget);

    await tester.tap(find.text('Gênesis'));
    await tester.pumpAndSettle();
    expect(find.text('Escolha o capítulo'), findsOneWidget);

    // Capítulo → grade de versículos (nova etapa do fluxo oficial).
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    expect(find.text('Escolha o versículo'), findsOneWidget);
    expect(find.text('Gênesis 1'), findsOneWidget);

    // Versículo → leitor, posicionado no versículo escolhido.
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.text('Gênesis 1'), findsWidgets);
    expect(
      find.textContaining('No principio creou Deus', findRichText: true),
      findsOneWidget,
    );
  });
}
