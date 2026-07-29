import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/contribua/presentation/contribua_screen.dart';

void main() {
  testWidgets('mostra chave Pix, favorecido e dados bancários', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContribuaScreen(
            pixKey: 'contato@goelchurch.org',
            pixKeyLabel: 'E-mail',
            favorecido: 'Goel Church',
            banco: 'Banco Exemplo',
            agencia: '0001',
            conta: '12345-6',
          ),
        ),
      ),
    );

    expect(find.text('Contribua'), findsOneWidget);
    expect(find.text('contato@goelchurch.org'), findsOneWidget);
    expect(find.textContaining('Goel Church'), findsWidgets);
    expect(find.text('Banco Exemplo'), findsOneWidget);
  });

  testWidgets('tocar em "Copiar chave" copia e mostra confirmação',
      (tester) async {
    // Captura a escrita no clipboard sem plataforma real.
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ContribuaScreen(pixKey: '00.000.000/0001-00'),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Copiar chave'));
    await tester.pump(); // dispara o SnackBar

    expect(copied, '00.000.000/0001-00');
    expect(find.textContaining('copiada'), findsOneWidget);
  });
}
