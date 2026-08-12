import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/escalas/presentation/escalas_screen.dart';

void main() {
  testWidgets('abre o detalhe, ajusta o rodízio e mostra compartilhar/copiar',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EscalasScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mídia'));
    await tester.pumpAndSettle();

    // Padrão: 4 semanas.
    expect(find.textContaining('próximas 4 semanas'), findsOneWidget);
    expect(find.text('Compartilhar no grupo'), findsOneWidget);
    expect(find.text('Copiar'), findsOneWidget);

    // Ajusta o rodízio para 8 semanas e o texto de equilíbrio acompanha.
    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(find.textContaining('próximas 8 semanas'), findsOneWidget);
  });

  testWidgets('EU-05: equipe é editável (adicionar e remover)', (tester) async {
    tester.view.physicalSize = const Size(1200, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: EscalasScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mídia'));
    await tester.pumpAndSettle();

    // Mídia começa com 4 pessoas.
    expect(find.text('Equipe (4)'), findsOneWidget);

    // Adicionar uma pessoa via diálogo.
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Nome'), 'Joana');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Equipe (5)'), findsOneWidget);
    expect(find.text('Joana'), findsWidgets);

    // Remover a primeira pessoa da lista.
    await tester.tap(find.byTooltip('Remover').first);
    await tester.pumpAndSettle();
    expect(find.text('Equipe (4)'), findsOneWidget);
  });
}
