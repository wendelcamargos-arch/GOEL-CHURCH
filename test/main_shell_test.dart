import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/home/presentation/main_shell.dart';

void main() {
  testWidgets('abre no Início, saudando o membro', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(memberName: 'Ana Maria')),
    );
    expect(find.textContaining('Olá, Ana'), findsOneWidget);
  });

  testWidgets('barra inferior tem os cinco destinos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    for (final label in ['Palavras', 'Bíblia', 'Início', 'Contribua', 'Mais']) {
      expect(find.text(label), findsWidgets, reason: 'destino $label');
    }
  });

  testWidgets('sem onLogout, a aba Mais não exibe "Sair"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Sair'), findsNothing);
  });

  testWidgets('na aba Mais, "Sair" chama onLogout e volta à raiz',
      (tester) async {
    // Janela alta o bastante para a lista "Mais" caber sem rolagem.
    tester.view.physicalSize = const Size(1000, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var loggedOut = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MainShell(
                      memberName: 'Ana Maria',
                      onLogout: () => loggedOut = true,
                    ),
                  ),
                ),
                child: const Text('ir para a Home'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ir para a Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Olá, Ana'), findsOneWidget);

    await tester.tap(find.text('Mais'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Sair'));
    await tester.pumpAndSettle();

    expect(loggedOut, isTrue);
    expect(find.text('ir para a Home'), findsOneWidget);
    expect(find.textContaining('Olá, Ana'), findsNothing);
  });

  testWidgets('trocar de aba mostra o conteúdo "Em breve"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.tap(find.text('Contribua'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Em breve'), findsWidgets);
  });
}
