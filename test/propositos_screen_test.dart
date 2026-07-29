import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/propositos/presentation/propositos_screen.dart';

void main() {
  testWidgets('selecionar um propósito e firmar abre a folha de compromisso',
      (tester) async {
    // Viewport alto: cards e o botão "Firmar" ficam tocáveis no teste.
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: PropositosScreen()));
    await tester.pumpAndSettle();

    // Marca um propósito e firma.
    await tester.tap(find.text('Jejum e oração'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Firmar meu propósito'));
    await tester.pumpAndSettle();

    expect(find.text('Propósito firmado!'), findsOneWidget);
    expect(find.text('Compartilhar no WhatsApp'), findsOneWidget);
    expect(find.textContaining('Jejum e oração'), findsWidgets);
  });
}
