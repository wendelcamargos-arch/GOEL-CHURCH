import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/agenda/presentation/agenda_screen.dart';
import 'package:goel_church/features/pregacoes/presentation/pregacoes_screen.dart';

void main() {
  testWidgets('Agenda lista eventos ordenados por data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AgendaScreen(
          eventos: [
            Evento(
              titulo: 'Segundo evento',
              quando: DateTime(2026, 8, 20, 19),
              local: 'Templo',
            ),
            Evento(
              titulo: 'Primeiro evento',
              quando: DateTime(2026, 8, 2, 18),
              local: 'Salão',
            ),
          ],
        ),
      ),
    );

    expect(find.text('Próximos encontros'), findsOneWidget);
    expect(find.text('Primeiro evento'), findsOneWidget);
    expect(find.text('Segundo evento'), findsOneWidget);
    // O primeiro card (topo) é o evento mais próximo (dia 2).
    final primeiro = tester.getTopLeft(find.text('Primeiro evento'));
    final segundo = tester.getTopLeft(find.text('Segundo evento'));
    expect(primeiro.dy, lessThan(segundo.dy));
  });

  testWidgets('Pregações lista as mensagens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PregacoesScreen(
          pregacoes: [
            Pregacao(
              titulo: 'Mensagem de fé',
              pregador: 'Pr. Teste',
              quando: DateTime(2026, 7, 6),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Mensagem de fé'), findsOneWidget);
    expect(find.textContaining('Pr. Teste'), findsOneWidget);
  });

  testWidgets('Pregação sem onAbrir mostra aviso ao tocar', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PregacoesScreen(
          pregacoes: [
            Pregacao(
              titulo: 'Mensagem de fé',
              pregador: 'Pr. Teste',
              quando: DateTime(2026, 7, 6),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Mensagem de fé'));
    await tester.pump();
    expect(find.textContaining('em breve'), findsOneWidget);
  });
}
