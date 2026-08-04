import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/testemunho/presentation/testemunho_screen.dart';

import 'support/fake_url_launcher.dart';

void main() {
  setUp(installFakeUrlLauncher);

  // Janela alta para o formulário caber sem rolagem (botão no fim da lista).
  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('mostra o formulário de testemunho', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));
    expect(find.text('Compartilhe seu testemunho'), findsOneWidget);
    expect(find.text('Enviar Testemunho'), findsOneWidget);
  });

  testWidgets('envio vazio mostra validação e não conclui', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pump();
    expect(find.textContaining('Escreva um pouco mais'), findsOneWidget);
    expect(find.text('Informe o seu nome.'), findsOneWidget);
    expect(find.text('Abrimos o WhatsApp com o seu testemunho'), findsNothing);
  });

  testWidgets('com nome e texto válidos, monta a mensagem e abre o WhatsApp',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    var received = '';
    await tester.pumpWidget(
      MaterialApp(
        home: TestemunhoScreen(
          onSubmit: (nome, whatsapp, titulo, texto) async => received = texto,
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Seu nome'),
      'Ana Maria',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Título'),
      'Cura e restauração',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Seu testemunho'),
      'Deus curou a minha família e restaurou a nossa casa.',
    );
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pumpAndSettle();

    expect(find.text('Abrimos o WhatsApp com o seu testemunho'), findsOneWidget);
    expect(received, contains('Deus curou'));

    // A mensagem pronta chegou ao WhatsApp com nome, título e testemunho.
    expect(fake.launched.single, startsWith('https://wa.me/?text='));
    final decoded = Uri.decodeComponent(fake.launched.single);
    expect(decoded, contains('Testemunho'));
    expect(decoded, contains('Ana Maria'));
    expect(decoded, contains('Cura e restauração'));
    expect(decoded, contains('Deus curou'));

    // "Escrever outro" volta ao formulário.
    await tester.tap(find.text('Escrever outro'));
    await tester.pumpAndSettle();
    expect(find.text('Compartilhe seu testemunho'), findsOneWidget);
  });
}
