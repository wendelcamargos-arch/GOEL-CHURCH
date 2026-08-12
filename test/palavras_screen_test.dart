import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/palavras/presentation/palavras_screen.dart';

void main() {
  testWidgets('PALAVRAS abre a pasta do Google Drive da publicação',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final abertos = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PalavrasScreen(onAbrir: (u) async => abertos.add(u)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // As três publicações aprovadas pelo Owner.
    expect(find.text('A graça que transforma'), findsWidgets);
    expect(find.text('Fé que move montanhas'), findsWidgets);
    expect(find.text('Uma família para pertencer'), findsWidgets);

    // Destaque (mais recente) → abre a pasta correta no Drive.
    await tester.tap(find.text('A graça que transforma').first);
    await tester.pump();
    expect(
      abertos.last,
      'https://drive.google.com/drive/folders/1Blva_m4CvUVMznpYxmHLnYNMXf5o6qEU?usp=sharing',
    );

    // Um item da lista "Mais recentes" também abre o seu link.
    await tester.tap(find.text('Fé que move montanhas').first);
    await tester.pump();
    expect(
      abertos.last,
      'https://drive.google.com/drive/folders/1eNAbVXauLql90fPjRvStF2xyaZLBWJa0?usp=sharing',
    );
  });
}
