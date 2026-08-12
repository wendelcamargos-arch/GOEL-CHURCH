import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/asset_bible_repository.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/compartilhar_screen.dart';
import 'package:goel_church/features/biblia/presentation/leitura_screen.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// REGRESSÃO do Bible Engine após o hotfix (fluxo Livro → Capítulo →
/// Versículo → Leitor). Nada do leitor pode ter sido perdido.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = AssetBibleRepository();
  late List<BibleBookMeta> livros;
  late ReadingStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    livros = await repo.livros();
    store = await ReadingStore.abrir();
  });

  Future<void> abrirLeitor(
    WidgetTester tester, {
    int? versiculoInicial,
    Size janela = const Size(1000, 1600),
  }) async {
    tester.view.physicalSize = janela;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LeituraScreen(
          repository: repo,
          store: store,
          livros: livros,
          bookId: 'romanos',
          capitulo: 8,
          versiculoInicial: versiculoInicial,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Abre a folha de ações tocando no primeiro versículo visível.
  Future<void> abrirAcoesDoPrimeiroVersiculo(WidgetTester tester) async {
    await tester.tap(
      find.textContaining('nenhuma condemnação', findRichText: true),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('o leitor abre o capítulo com o texto real', (tester) async {
    await abrirLeitor(tester);
    expect(find.text('Romanos 8'), findsWidgets);
    expect(
      find.textContaining('nenhuma condemnação', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('16. favoritos continuam funcionando', (tester) async {
    await abrirLeitor(tester);
    await abrirAcoesDoPrimeiroVersiculo(tester);

    expect(find.text('Favoritar'), findsOneWidget);
    await tester.tap(find.text('Favoritar'));
    await tester.pumpAndSettle();

    expect(store.favoritos(), contains('romanos:8:1'));
  });

  testWidgets('17. marca-texto continua funcionando', (tester) async {
    await abrirLeitor(tester);
    await abrirAcoesDoPrimeiroVersiculo(tester);

    expect(find.text('Marca-texto:'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Marca-texto amarelo'));
    await tester.pumpAndSettle();

    expect(store.marcas()['romanos:8:1'], 'amarelo');
  });

  testWidgets('18. anotações continuam funcionando', (tester) async {
    await abrirLeitor(tester);
    await abrirAcoesDoPrimeiroVersiculo(tester);

    expect(find.text('Adicionar anotação'), findsOneWidget);
    await tester.tap(find.text('Adicionar anotação'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Minha anotação');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(store.anotacao('romanos:8:1'), 'Minha anotação');
  });

  testWidgets('19. compartilhar continua funcionando', (tester) async {
    await abrirLeitor(tester);
    await abrirAcoesDoPrimeiroVersiculo(tester);

    expect(find.text('Compartilhar'), findsOneWidget);
    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();

    expect(find.byType(CompartilharVersiculoScreen), findsOneWidget);
  });

  testWidgets('20. scroll contínuo continua carregando o próximo capítulo',
      (tester) async {
    await abrirLeitor(tester);
    expect(find.text('Romanos 9'), findsNothing);

    // Rola até o fim do capítulo 8 — o leitor emenda o capítulo seguinte.
    for (var i = 0; i < 12; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -1200));
      await tester.pumpAndSettle();
      if (find.text('Romanos 9').evaluate().isNotEmpty) break;
    }
    expect(find.text('Romanos 9'), findsOneWidget);
  });

  testWidgets('"Continue lendo" segue sendo registrado', (tester) async {
    await abrirLeitor(tester);
    final ultima = store.ultimaLeitura();
    expect(ultima?.bookId, 'romanos');
    expect(ultima?.capitulo, 8);
  });

  testWidgets('fonte, tema e modos do leitor continuam disponíveis',
      (tester) async {
    await abrirLeitor(tester);
    expect(find.byIcon(Icons.text_decrease), findsOneWidget);
    expect(find.byIcon(Icons.text_increase), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.apps), findsOneWidget); // Ir para versículo

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Modo púlpito'), findsOneWidget);
    expect(find.text('Modo culto (tela ligada)'), findsOneWidget);
  });

  group('abertura posicionada no versículo (Parte D)', () {
    testWidgets('Romanos 8:28 abre com a leitura rolada até o versículo 28',
        (tester) async {
      await abrirLeitor(tester, versiculoInicial: 28);

      final scroll = tester
          .widget<Scrollable>(find.byType(Scrollable).first)
          .controller;
      expect(scroll?.offset ?? 0, greaterThan(0),
          reason: 'a leitura deve ter rolado até o versículo escolhido',);

      expect(
        find.textContaining('todas as coisas contribuem juntamente',
            findRichText: true,),
        findsOneWidget,
      );
    });

    testWidgets('sem versículo escolhido, abre no início do capítulo',
        (tester) async {
      await abrirLeitor(tester);
      final scroll = tester
          .widget<Scrollable>(find.byType(Scrollable).first)
          .controller;
      expect(scroll?.offset ?? 0, 0);
    });
  });
}
