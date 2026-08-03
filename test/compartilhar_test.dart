import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/presentation/compartilhar_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('card do versículo mostra texto/referência e alterna o QR',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompartilharVersiculoScreen(
          texto: 'Porque Deus amou o mundo de tal maneira...',
          referencia: 'João 3:16',
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Card com identidade e conteúdo.
    expect(find.text('GOEL CHURCH'), findsOneWidget);
    expect(find.textContaining('Deus amou o mundo'), findsOneWidget);
    expect(find.text('João 3:16'), findsOneWidget);
    expect(find.text('Compartilhar texto'), findsOneWidget);

    // QR começa ausente e aparece ao ativar.
    expect(find.byType(QrImageView), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('Compartilhar imagem + QR'), findsOneWidget);
  });
}
