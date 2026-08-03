import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/busca_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_bible.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeBibleRepository();
    final livros = await fake.livros();
    final store = await ReadingStore.abrir();
    await tester.pumpWidget(
      MaterialApp(
        home: BuscaScreen(repository: fake, store: store, livros: livros),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('busca por PALAVRA lista ocorrências', (tester) async {
    await abrir(tester);
    await tester.enterText(find.byType(TextField), 'creou');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('Gn 1:1'), findsOneWidget);
    expect(find.textContaining('No principio creou'), findsWidgets);
  });

  testWidgets('busca por REFERÊNCIA oferece abrir o trecho', (tester) async {
    await abrir(tester);
    await tester.enterText(find.byType(TextField), 'genesis 1');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
    expect(find.text('Ir para Gênesis 1'), findsOneWidget);
  });
}
