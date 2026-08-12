import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/asset_bible_repository.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/capitulos_screen.dart';
import 'package:goel_church/features/biblia/presentation/leitura_screen.dart';
import 'package:goel_church/features/biblia/presentation/versiculos_screen.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fluxo Livro → Capítulo → Versículo → Leitor.
///
/// Usa o repositório REAL (assets de produção): as quantidades verificadas aqui
/// são as do manifest, nunca valores fixos no código da tela.
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

  BibleBookMeta livro(String id) => livros.firstWhere((l) => l.id == id);

  /// Quantidade de células que a grade REALMENTE vai construir.
  int celulasDaGrade(WidgetTester tester) {
    final grid = tester.widget<GridView>(find.byType(GridView));
    final delegate = grid.childrenDelegate as SliverChildBuilderDelegate;
    return delegate.childCount!;
  }

  Future<void> janelaAlta(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> abrirVersiculos(
    WidgetTester tester,
    String bookId,
    int capitulo,
  ) async {
    await janelaAlta(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: VersiculosScreen(
          repository: repo,
          store: store,
          livros: livros,
          livro: livro(bookId),
          capitulo: capitulo,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('9. Romanos → capítulos mostra 16 capítulos', (tester) async {
    await janelaAlta(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CapitulosScreen(
          repository: repo,
          store: store,
          livros: livros,
          livro: livro('romanos'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Romanos'), findsOneWidget);
    expect(find.text('Escolha o capítulo'), findsOneWidget);
    expect(celulasDaGrade(tester), 16);
  });

  testWidgets('capítulo abre a grade de VERSÍCULOS (não o leitor direto)',
      (tester) async {
    await janelaAlta(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CapitulosScreen(
          repository: repo,
          store: store,
          livros: livros,
          livro: livro('romanos'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();

    expect(find.byType(VersiculosScreen), findsOneWidget);
    expect(find.byType(LeituraScreen), findsNothing);
    expect(find.text('Romanos 8'), findsOneWidget);
    expect(find.text('Escolha o versículo'), findsOneWidget);
  });

  testWidgets('10. Romanos 8 → grade mostra exatamente 39 versículos',
      (tester) async {
    await abrirVersiculos(tester, 'romanos', 8);
    expect(celulasDaGrade(tester), 39);
    expect(livro('romanos').versiculosDoCapitulo(8), 39);
  });

  testWidgets('11. selecionar Romanos 8:28 abre exatamente o versículo 28',
      (tester) async {
    await abrirVersiculos(tester, 'romanos', 8);

    await tester.tap(find.text('28'));
    await tester.pumpAndSettle();

    final leitor = tester.widget<LeituraScreen>(find.byType(LeituraScreen));
    expect(leitor.bookId, 'romanos');
    expect(leitor.capitulo, 8);
    expect(leitor.versiculoInicial, 28); // posicionado no versículo escolhido

    expect(find.text('Romanos 8'), findsWidgets);
    expect(
      find.textContaining('todas as coisas contribuem juntamente',
          findRichText: true,),
      findsOneWidget,
    );
  });

  testWidgets('12. João 3 usa a quantidade real (36)', (tester) async {
    await abrirVersiculos(tester, 'joao', 3);
    expect(celulasDaGrade(tester), 36);
    expect(livro('joao').versiculosDoCapitulo(3), 36);
  });

  testWidgets('13. Salmos 119 → 176 versículos', (tester) async {
    await abrirVersiculos(tester, 'salmos', 119);
    expect(celulasDaGrade(tester), 176);
  });

  testWidgets('14. Salmos 117 usa a quantidade real (2)', (tester) async {
    await abrirVersiculos(tester, 'salmos', 117);
    expect(celulasDaGrade(tester), 2);
  });

  testWidgets(
      '15. a quantidade NÃO é hardcoded: cada capítulo tem a sua própria',
      (tester) async {
    // Mesma tela, capítulos diferentes → contagens diferentes, todas vindas
    // do manifest.
    for (final caso in const [
      ('salmos', 119, 176),
      ('salmos', 117, 2),
      ('romanos', 8, 39),
      ('joao', 3, 36),
      ('genesis', 1, 31),
    ]) {
      final (bookId, cap, esperado) = caso;
      await abrirVersiculos(tester, bookId, cap);
      expect(celulasDaGrade(tester), esperado,
          reason: '$bookId $cap deve ter $esperado versículos',);
      expect(celulasDaGrade(tester), livro(bookId).versiculosDoCapitulo(cap));
    }
  });

  testWidgets('"Ler o capítulo" abre o leitor sem versículo destacado',
      (tester) async {
    await abrirVersiculos(tester, 'romanos', 8);

    await tester.tap(find.text('Ler o capítulo'));
    await tester.pumpAndSettle();

    final leitor = tester.widget<LeituraScreen>(find.byType(LeituraScreen));
    expect(leitor.capitulo, 8);
    expect(leitor.versiculoInicial, isNull);
  });
}
