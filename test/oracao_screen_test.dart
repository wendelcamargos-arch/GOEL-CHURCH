import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/oracao/presentation/oracao_screen.dart';

void main() {
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('mostra o formulário de pedido de oração', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));
    expect(find.text('Peça uma oração'), findsOneWidget);
    expect(find.text('Enviar pedido'), findsOneWidget);
  });

  testWidgets('envio vazio mostra validação e não conclui', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));
    await tester.tap(find.text('Enviar pedido'));
    await tester.pump();
    expect(find.text('Escreva o seu pedido.'), findsOneWidget);
    expect(find.text('Recebemos o seu pedido'), findsNothing);
  });

  testWidgets('com pedido válido, conclui e envia o sigilo', (tester) async {
    tall(tester);
    bool? sigiloRecebido;
    await tester.pumpWidget(
      MaterialApp(
        home: OracaoScreen(
          onSubmit: (nome, pedido, sigilo) async => sigiloRecebido = sigilo,
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Seu pedido de oração'),
      'Ore pela minha família.',
    );
    await tester.tap(find.text('Enviar pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Recebemos o seu pedido'), findsOneWidget);
    expect(sigiloRecebido, isTrue); // sigilo é o padrão

    await tester.tap(find.text('Fazer outro pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Peça uma oração'), findsOneWidget);
  });
}
