import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/servo/presentation/servo_screen.dart';

import 'support/fake_url_launcher.dart';

void main() {
  setUp(installFakeUrlLauncher);

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('escolher Mídia monta "Quero servir na equipe de Mídia."',
      (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), 'Pedro');
    await tester.enterText(
      find.widgetWithText(TextField, 'WhatsApp / contato'),
      '62999990000',
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();

    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();

    expect(find.text('Abrimos o WhatsApp com a sua inscrição'), findsOneWidget);

    final decoded = Uri.decodeComponent(fake.launched.single);
    expect(fake.launched.single, startsWith('https://wa.me/?text='));
    expect(decoded, contains('Quero Ser Servo'));
    expect(decoded, contains('Pedro'));
    expect(decoded, contains('Quero servir na equipe de Mídia.'));
  });

  testWidgets('várias áreas viram frase no plural', (tester) async {
    tall(tester);
    final fake = installFakeUrlLauncher();
    await tester.pumpWidget(const MaterialApp(home: ServoScreen()));

    await tester.enterText(find.widgetWithText(TextField, 'Seu nome'), 'Ana');
    await tester.enterText(
      find.widgetWithText(TextField, 'WhatsApp / contato'),
      '62999990000',
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Mídia'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, 'Recepção'));
    await tester.pump();

    await tester.tap(find.text('Enviar inscrição'));
    await tester.pumpAndSettle();

    final decoded = Uri.decodeComponent(fake.launched.single);
    expect(decoded, contains('Quero servir nas equipes de Mídia e Recepção.'));
  });
}
