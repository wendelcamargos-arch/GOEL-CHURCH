import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/oracao/presentation/oracao_screen.dart';

import 'support/fake_url_launcher.dart';

void main() {
  setUp(installFakeUrlLauncher);

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
    expect(find.text('Enviar Pedido'), findsOneWidget);
  });

  testWidgets('envio vazio mostra validação e não conclui', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pump();
    expect(find.text('Escreva o seu pedido.'), findsOneWidget);
    expect(find.text('Informe o seu nome.'), findsOneWidget);
    expect(find.text('Abrimos o WhatsApp com o seu pedido'), findsNothing);
  });

  testWidgets('com nome e pedido válidos, monta a mensagem e abre o WhatsApp',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    String? nomeRecebido;
    String? pedidoRecebido;
    await tester.pumpWidget(
      MaterialApp(
        home: OracaoScreen(
          onSubmit: (nome, whatsapp, pedido) async {
            nomeRecebido = nome;
            pedidoRecebido = pedido;
          },
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Seu nome'),
      'João',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Seu pedido de oração'),
      'Ore pela minha família.',
    );
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Abrimos o WhatsApp com o seu pedido'), findsOneWidget);
    expect(nomeRecebido, 'João');
    expect(pedidoRecebido, contains('família'));

    // A mensagem pré-pronta foi levada ao WhatsApp (wa.me) com nome e pedido.
    expect(fake.launched.single, startsWith('https://wa.me/?text='));
    final decoded = Uri.decodeComponent(fake.launched.single);
    expect(decoded, contains('Pedido de Oração'));
    expect(decoded, contains('João'));
    expect(decoded, contains('Ore pela minha família.'));

    await tester.tap(find.text('Fazer outro pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Peça uma oração'), findsOneWidget);
  });
}
