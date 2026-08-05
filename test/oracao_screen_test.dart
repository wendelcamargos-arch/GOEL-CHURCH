import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/whatsapp/whatsapp_links.dart';
import 'package:goel_church/features/oracao/presentation/oracao_screen.dart';

import 'support/fake_url_launcher.dart';

void main() {
  setUp(installFakeUrlLauncher);

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<String> spyClipboard(WidgetTester tester) {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
    return copied;
  }

  const nome = 'João';
  const zap = '62999990000';
  const pedido = 'Ore pela minha familia.';
  const mensagemEsperada = 'PEDIDO DE ORAÇÃO — GOEL CHURCH\n\n'
      'Nome: $nome\n'
      'WhatsApp: $zap\n\n'
      'Pedido:\n'
      '$pedido';

  Future<void> preencher(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), nome);
    await tester.enterText(find.widgetWithText(TextField, 'WhatsApp'), zap);
    await tester.enterText(
        find.widgetWithText(TextField, 'Seu pedido de oração'), pedido,);
  }

  testWidgets('campos obrigatórios: nome, WhatsApp e pedido', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pump();
    expect(find.text('Informe o seu nome.'), findsOneWidget);
    expect(find.text('Informe o seu WhatsApp.'), findsOneWidget);
    expect(find.text('Escreva o seu pedido.'), findsOneWidget);
    expect(find.text('Mensagem copiada!'), findsNothing);
  });

  testWidgets('copia a mensagem EXATA e abre o grupo correto (sem wa.me)',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pumpAndSettle();

    expect(find.text('Mensagem copiada!'), findsOneWidget);
    expect(copied.single, mensagemEsperada);

    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();
    expect(fake.launched.single, WhatsAppLinks.oracao);
    expect(fake.launched.single, isNot(startsWith('https://wa.me/?text=')));

    expect(find.text('Preparamos sua mensagem'), findsOneWidget);
    expect(find.textContaining('enviado'), findsNothing);
  });

  testWidgets('falha ao abrir o grupo preserva o texto copiado', (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher()..ok = false;
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();

    expect(fake.launched.single, WhatsAppLinks.oracao);
    expect(copied.last, mensagemEsperada);
  });

  testWidgets('"Copiar novamente" recopia a mensagem', (tester) async {
    tall(tester);
    installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: OracaoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Pedido'));
    await tester.pumpAndSettle();
    expect(copied.length, 1);

    await tester.tap(find.text('Copiar novamente'));
    await tester.pumpAndSettle();
    expect(copied.length, 2);
    expect(copied.last, mensagemEsperada);
  });
}
