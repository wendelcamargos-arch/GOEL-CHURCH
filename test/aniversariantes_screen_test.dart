import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/aniversariantes/presentation/aniversariantes_screen.dart';

void main() {
  testWidgets('lista os aniversariantes ordenados por dia', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AniversariantesScreen(
          mesLabel: 'julho',
          itens: [
            Aniversariante('Ana Souza', 20),
            Aniversariante('Bruno Lima', 3),
          ],
        ),
      ),
    );

    expect(find.textContaining('Aniversariantes de julho'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.text('Bruno Lima'), findsOneWidget);
    expect(find.text('Dia 3'), findsOneWidget);
    expect(find.text('Dia 20'), findsOneWidget);
  });

  testWidgets('sem itens, mostra o estado vazio', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AniversariantesScreen(mesLabel: 'agosto', itens: []),
      ),
    );
    expect(find.textContaining('Nenhum aniversariante em agosto'),
        findsOneWidget,);
  });
}
