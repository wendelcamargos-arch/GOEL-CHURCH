import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/busca_screen.dart';
import 'package:goel_church/features/biblia/presentation/capitulos_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_bible.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeBibleRepository();
    final livros = await fake.livros();
    final store = await ReadingStore.abrir();
    await tester.pumpWidget(
      MaterialApp(
        home: BuscaScreen(repository: fake, store: store, livros: livros),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Digita SEM confirmar — exercita a sugestão em tempo real.
  Future<void> digitar(WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.pumpAndSettle();
  }

  /// Digita e CONFIRMA — dispara também a busca por conteúdo.
  Future<void> confirmar(WidgetTester tester, String texto) async {
    await tester.enterText(find.byType(TextField), texto);
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();
  }

  group('busca por LIVRO (navegação)', () {
    testWidgets('1. "rom" sugere Romanos em tempo real, sem confirmar',
        (tester) async {
      await abrir(tester);
      await digitar(tester, 'rom');
      expect(find.text('LIVROS'), findsOneWidget);
      expect(find.text('Romanos'), findsOneWidget);
      expect(find.text('16 capítulos'), findsNothing); // fake tem 1 capítulo
      expect(find.text('1 capítulos'), findsOneWidget);
    });

    testWidgets('2 e 3. "roma" e "romanos" sugerem Romanos', (tester) async {
      await abrir(tester);
      await digitar(tester, 'roma');
      expect(find.text('Romanos'), findsOneWidget);

      await digitar(tester, 'romanos');
      expect(find.text('Romanos'), findsOneWidget);
    });

    testWidgets('4 e 5. busca é case- e accent-insensitive', (tester) async {
      await abrir(tester);
      await digitar(tester, 'ROMANOS');
      expect(find.text('Romanos'), findsOneWidget);

      await digitar(tester, 'joao');
      expect(find.text('João'), findsOneWidget);

      await digitar(tester, 'JOÃO');
      expect(find.text('João'), findsOneWidget);
    });

    testWidgets('tocar o livro abre a tela de capítulos', (tester) async {
      await abrir(tester);
      await digitar(tester, 'romanos');
      await tester.tap(find.text('Romanos'));
      await tester.pumpAndSettle();

      expect(find.byType(CapitulosScreen), findsOneWidget);
      expect(find.text('Escolha o capítulo'), findsOneWidget);
    });
  });

  group('prioridade LIVRO sobre texto (defeito corrigido)', () {
    testWidgets(
        '8. "romanos" mostra o LIVRO acima das ocorrências textuais de outros '
        'livros', (tester) async {
      await abrir(tester);
      await confirmar(tester, 'romanos');

      // O livro Romanos aparece...
      final livro = find.text('Romanos');
      expect(livro, findsOneWidget);

      // ...e a ocorrência textual em Atos ("virão os romanos") também, mas
      // ABAIXO — a navegação por livro tem prioridade.
      final ocorrencia = find.text('At 1:1');
      expect(ocorrencia, findsOneWidget);

      final yLivro = tester.getTopLeft(livro).dy;
      final yOcorrencia = tester.getTopLeft(ocorrencia).dy;
      expect(yLivro, lessThan(yOcorrencia),
          reason: 'o livro Romanos deve vir antes das ocorrências textuais',);

      // As seções deixam a hierarquia explícita.
      expect(find.text('LIVROS'), findsOneWidget);
      expect(find.textContaining('VERSÍCULOS'), findsOneWidget);
    });
  });

  group('busca por REFERÊNCIA e por CONTEÚDO continuam funcionando', () {
    testWidgets('6. "João 1:1" é reconhecido como referência', (tester) async {
      await abrir(tester);
      await digitar(tester, 'João 1:1');
      expect(find.text('Ir para João 1:1'), findsOneWidget);
    });

    testWidgets('referência de capítulo continua abrindo o trecho',
        (tester) async {
      await abrir(tester);
      await confirmar(tester, 'genesis 1');
      expect(find.text('Ir para Gênesis 1'), findsOneWidget);
    });

    testWidgets('7. "amor" continua retornando a busca textual',
        (tester) async {
      await abrir(tester);
      await confirmar(tester, 'amor');

      expect(find.text('LIVROS'), findsNothing); // nenhum livro se chama amor
      expect(find.text('Rm 1:2'), findsOneWidget);
      expect(find.textContaining('O amor de Deus'), findsWidgets);
    });

    testWidgets('21. busca por palavra comum segue listando ocorrências',
        (tester) async {
      await abrir(tester);
      await confirmar(tester, 'principio');
      expect(find.text('Gn 1:1'), findsOneWidget);
      expect(find.text('Jo 1:1'), findsOneWidget);
    });

    testWidgets('termo sem correspondência informa "Nada encontrado."',
        (tester) async {
      await abrir(tester);
      await confirmar(tester, 'zzzz');
      expect(find.text('Nada encontrado.'), findsOneWidget);
    });
  });
}
