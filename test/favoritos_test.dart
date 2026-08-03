import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/reading_store.dart';
import 'package:goel_church/features/biblia/presentation/favoritos_screen.dart';
import 'package:goel_church/features/biblia/presentation/leitura_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_bible.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ReadingStore alterna e persiste favoritos', () async {
    final store = await ReadingStore.abrir();
    expect(store.isFavorito('joao:3:16'), isFalse);
    expect(await store.alternarFavorito('joao:3:16'), isTrue);
    expect(store.isFavorito('joao:3:16'), isTrue);
    expect(await store.alternarFavorito('joao:3:16'), isFalse);
    expect(store.isFavorito('joao:3:16'), isFalse);
  });

  testWidgets('favoritar um versículo no leitor persiste e aparece na lista',
      (tester) async {
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

    // Toca no 1º versículo → abre ações → Favoritar.
    await tester.tap(
      find.textContaining('No principio creou', findRichText: true),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritar'));
    await tester.pumpAndSettle();

    expect(store.isFavorito('genesis:1:1'), isTrue);

    // A tela de favoritos lista o versículo.
    await tester.pumpWidget(
      MaterialApp(
        home: FavoritosScreen(repository: fake, store: store, livros: livros),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gênesis 1:1'), findsOneWidget);
  });
}
