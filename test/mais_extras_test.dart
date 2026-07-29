import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/galeria/presentation/galeria_screen.dart';
import 'package:goel_church/features/propositos/presentation/propositos_screen.dart';
import 'package:goel_church/features/devocional_tematico/presentation/devocional_tematico_screen.dart';

void main() {
  testWidgets('Galeria mostra as pastas Fotos e Vídeos do Google Drive',
      (tester) async {
    final abertos = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: GaleriaScreen(onAbrir: (url) async => abertos.add(url)),
    ),);
    expect(find.text('Fotos'), findsOneWidget);
    expect(find.text('Vídeos'), findsOneWidget);
    expect(find.text('Abrir no Google Drive'), findsWidgets);

    // Tocar em "Fotos" abre a pasta geral do Drive (link real por padrão).
    await tester.tap(find.text('Fotos'));
    await tester.pump();
    expect(abertos.single, contains('drive.google.com'));
  });

  testWidgets('Propósitos mostra intro e lista numerada', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PropositosScreen()));
    expect(find.text('Propósitos no Monte'), findsWidgets);
    expect(find.text('Jejum e oração'), findsOneWidget);
  });

  testWidgets('Devocional temático lista e abre o detalhe', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DevocionalTematicoScreen(
          appBarTitle: 'Devocional Homens',
          introTitulo: 'Para os homens',
          introSubtitulo: 'Sub',
          itens: [
            ItemDevocional('Liderança', 'Corpo do devocional aqui.',
                autor: 'Goel',),
          ],
        ),
      ),
    );

    expect(find.text('Para os homens'), findsOneWidget);
    await tester.tap(find.text('Liderança'));
    await tester.pumpAndSettle();
    expect(find.text('Devocional'), findsOneWidget); // AppBar do detalhe
    expect(find.textContaining('Corpo do devocional'), findsOneWidget);
  });
}
