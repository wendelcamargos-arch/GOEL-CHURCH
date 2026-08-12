import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/whatsapp/whatsapp_links.dart';
import 'package:goel_church/features/servo/presentation/servo_screen.dart';

import 'support/fake_url_launcher.dart';

void main() {
  setUp(installFakeUrlLauncher);

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2800);
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

  const nome = 'Pedro';
  const zap = '62999990000';
  const mensagemMidia = 'QUERO SER SERVO — GOEL CHURCH\n\n'
      'Nome: $nome\n'
      'WhatsApp: $zap\n'
      'Área de interesse: Mídia\n\n'
      'Quero servir na equipe de Mídia.';

  Future<void> preencherBase(WidgetTester tester) async {
    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), nome);
    await tester.enterText(find.widgetWithText(TextField, 'WhatsApp'), zap);
  }

  testWidgets('campos obrigatórios: nome, WhatsApp e área', (tester) async {
    tall(tester);
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));
    await tester.tap(find.text('Enviar inscrição'));
    await tester.pump();
    expect(find.text('Informe o seu nome.'), findsOneWidget);
    expect(find.text('Informe o seu WhatsApp.'), findsOneWidget);
    expect(find.text('Escolha ao menos uma área.'), findsOneWidget);
    expect(find.text('Mensagem copiada!'), findsNothing);
  });

  testWidgets('copia a mensagem EXATA (área Mídia) e abre o grupo (sem wa.me)',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await preencherBase(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();
    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();

    expect(find.text('Mensagem copiada!'), findsOneWidget);
    expect(copied.single, mensagemMidia);

    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();
    expect(fake.launched.single, WhatsAppLinks.servo);
    expect(fake.launched.single, isNot(startsWith('https://wa.me/?text=')));

    expect(find.text('Preparamos sua mensagem'), findsOneWidget);
    expect(find.textContaining('Inscrição enviada'), findsNothing);
    expect(find.textContaining('enviada'), findsNothing);
  });

  testWidgets('várias áreas → frase no plural (na mensagem copiada)',
      (tester) async {
    tall(tester);
    installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await preencherBase(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, 'Recepção'));
    await tester.pump();
    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();

    expect(copied.single, contains('Área de interesse: Mídia, Recepção'));
    expect(copied.single,
        contains('Quero servir nas equipes de Mídia e Recepção.'),);
  });

  testWidgets('falha ao abrir o grupo preserva o texto copiado', (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher()..ok = false;
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await preencherBase(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();
    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir grupo'));
    await tester.pumpAndSettle();

    expect(fake.launched.single, WhatsAppLinks.servo);
    expect(copied.last, mensagemMidia);
  });

  testWidgets('"Copiar novamente" recopia a mensagem', (tester) async {
    tall(tester);
    installFakeUrlLauncher();
    final copied = spyClipboard(tester);
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await preencherBase(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();
    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();
    expect(copied.length, 1);

    await tester.tap(find.text('Copiar novamente'));
    await tester.pumpAndSettle();
    expect(copied.length, 2);
    expect(copied.last, mensagemMidia);
  });
}
