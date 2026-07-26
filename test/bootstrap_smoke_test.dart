import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/app/goel_app.dart';

void main() {
  testWidgets('o app inicializa e exibe o Splash com marca e slogan',
      (tester) async {
    await tester.pumpWidget(const GoelApp());

    expect(find.text('GOEL CHURCH'), findsOneWidget);
    expect(
      find.textContaining('Compartilhando Esperança'),
      findsOneWidget,
    );
  });

  testWidgets('sem backend configurado, mostra aviso discreto de dev',
      (tester) async {
    await tester.pumpWidget(const GoelApp(supabaseConfigured: false));
    expect(find.textContaining('não configurado'), findsOneWidget);
  });

  testWidgets('com backend configurado, o Splash fica limpo (sem aviso de dev)',
      (tester) async {
    await tester.pumpWidget(const GoelApp(supabaseConfigured: true));
    expect(find.textContaining('não configurado'), findsNothing);
  });
}
