import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/leitura_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_bible.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('store: última leitura, histórico, marca-texto e anotação', () async {
    final s = await ReadingStore.abrir();

    await s.salvarUltimaLeitura('joao', 3);
    expect(s.ultimaLeitura()?.bookId, 'joao');
    expect(s.ultimaLeitura()?.capitulo, 3);

    await s.registrarHistorico('joao', 3);
    await s.registrarHistorico('salmos', 23);
    await s.registrarHistorico('joao', 3); // sobe ao topo sem duplicar
    expect(s.historico().first, 'joao:3');
    expect(s.historico().where((e) => e == 'joao:3').length, 1);

    await s.marcarVersiculo('joao:3:16', 'verde');
    expect(s.corVersiculo('joao:3:16'), 'verde');
    await s.marcarVersiculo('joao:3:16', null);
    expect(s.corVersiculo('joao:3:16'), isNull);

    await s.salvarAnotacao('joao:3:16', 'minha nota');
    expect(s.anotacao('joao:3:16'), 'minha nota');
  });

  testWidgets('Modo púlpito esconde a AppBar e oferece sair', (tester) async {
    final fake = FakeBibleRepository();
    final livros = await fake.livros();
    final store = await ReadingStore.abrir();

    await tester.pumpWidget(
      MaterialApp(
        home: LeituraScreen(
          repository: fake,
          store: store,
          livros: livros,
          bookId: 'genesis',
          capitulo: 1,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modo púlpito'));
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsNothing);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
