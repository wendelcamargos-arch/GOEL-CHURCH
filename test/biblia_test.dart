import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/biblia_livros.dart';
import 'package:goel_church/features/biblia/presentation/biblia_screen.dart';

void main() {
  test('catálogo tem os 66 livros', () {
    expect(kLivrosBiblia.length, 66);
    expect(kLivrosBiblia.where((l) => l.antigoTestamento).length, 39);
    expect(kLivrosBiblia.where((l) => !l.antigoTestamento).length, 27);
  });

  testWidgets('Bíblia lista livros e abre os capítulos', (tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: BibliaScreen())));
    expect(find.text('Antigo Testamento'), findsOneWidget);
    expect(find.text('Gênesis'), findsOneWidget);

    await tester.tap(find.text('Gênesis'));
    await tester.pumpAndSettle();

    // Tela de capítulos: escolha do capítulo + célula "1".
    expect(find.text('Escolha o capítulo'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    // Tela de leitura do capítulo.
    expect(find.text('Gênesis 1'), findsOneWidget);
  });
}
