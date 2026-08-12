import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/whatsapp/whatsapp_links.dart';
import 'package:goel_church/features/testemunho/presentation/testemunho_screen.dart';

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

  const nome = 'Ana Maria';
  const zap = '62999990000';
  const texto = 'Deus curou a minha familia e restaurou a nossa casa.';
  const mensagemEsperada =
      'QUEREMOS OUVIR SEU TESTEMUNHO PARA EDIFICAR CADA DIA A NOSSA FÉ\n\n'
      'Nome: $nome\n'
      'WhatsApp: $zap\n\n'
      'Testemunho:\n'
      '$texto';

  Future<void> preencher(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), nome);
    await tester.enterText(find.widgetWithText(TextField, 'WhatsApp'), zap);
    await tester.enterText(
        find.widgetWithText(TextField, 'Seu testemunho'), texto,);
  }

  testWidgets('campos obrigatórios: nome, WhatsApp e testemunho', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pump();
    expect(find.text('Informe o seu nome.'), findsOneWidget);
    expect(find.text('Informe o seu WhatsApp.'), findsOneWidget);
    expect(find.textContaining('Escreva um pouco mais'), findsOneWidget);
    // Sem WhatsApp, não avança.
    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), nome);
    await tester.enterText(
        find.widgetWithText(TextField, 'Seu testemunho'), texto,);
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pump();
    expect(find.text('Informe o seu WhatsApp.'), findsOneWidget);
    expect(find.text('Mensagem copiada!'), findsNothing);
  });

  testWidgets('copia a mensagem EXATA e abre o grupo correto (sem wa.me)',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pumpAndSettle();

    // Orientação (não afirma envio) + clipboard com a mensagem final exata.
    expect(find.text('Mensagem copiada!'), findsOneWidget);
    expect(copied.single, mensagemEsperada);

    // Abrir grupo → link oficial; nunca wa.me/?text=.
    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();
    expect(fake.launched.single, WhatsAppLinks.testemunhos);
    expect(fake.launched.single, isNot(startsWith('https://wa.me/?text=')));

    // Sucesso honesto — "Preparamos sua mensagem", nunca "enviado".
    expect(find.text('Preparamos sua mensagem'), findsOneWidget);
    expect(find.textContaining('enviado'), findsNothing);
    expect(find.textContaining('Testemunho enviado'), findsNothing);
  });

  testWidgets('falha ao abrir o grupo preserva o texto copiado', (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher()..ok = false;
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();

    // Mesmo com falha ao abrir, a mensagem permanece copiada.
    expect(fake.launched.single, WhatsAppLinks.testemunhos);
    expect(copied.last, mensagemEsperada);
  });

  testWidgets('"Copiar novamente" recopia a mensagem', (tester) async {
    tall(tester);
    installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: TestemunhoScreen()));

    await preencher(tester);
    await tester.tap(find.text('Enviar Testemunho'));
    await tester.pumpAndSettle();
    expect(copied.length, 1);

    await tester.tap(find.text('Copiar novamente'));
    await tester.pumpAndSettle();
    expect(copied.length, 2);
    expect(copied.last, mensagemEsperada);
  });
}
