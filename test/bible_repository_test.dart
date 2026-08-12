import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/biblia/data/asset_bible_repository.dart';
import 'package:goel_domain/goel_domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = AssetBibleRepository();

  test('manifest tem 66 livros com metadados coerentes', () async {
    final livros = await repo.livros();
    expect(livros.length, 66);
    final salmos = livros.firstWhere((b) => b.id == 'salmos');
    expect(salmos.nome, 'Salmos');
    expect(salmos.totalCapitulos, 150);
    expect(salmos.versiculosDoCapitulo(119), 176); // capítulo mais longo
    expect(salmos.versiculosDoCapitulo(117), 2); // capítulo mais curto
    // ordem/testamento
    expect(livros.firstWhere((b) => b.id == 'genesis').testamento, 'AT');
    expect(livros.firstWhere((b) => b.id == 'apocalipse').testamento, 'NT');
  });

  test('carrega capítulo sob demanda com o texto real', () async {
    final joao3 = await repo.capitulo('joao', 3);
    expect(joao3.totalVersiculos, greaterThanOrEqualTo(16));
    expect(joao3.versiculos[15], contains('Deus amou o mundo')); // Jo 3:16
  });

  test('capítulo longo (Sl 119) traz 176 versículos — nunca "só 5"', () async {
    final sl119 = await repo.capitulo('salmos', 119);
    expect(sl119.totalVersiculos, 176);
  });

  test('capítulo curto (Sl 117) traz 2 versículos', () async {
    final sl117 = await repo.capitulo('salmos', 117);
    expect(sl117.totalVersiculos, 2);
  });

  test('resolve referências válidas e rejeita inválidas', () async {
    expect(
      await repo.resolverReferencia('João 3:16'),
      const VerseRef('joao', 3, 16),
    );
    expect(await repo.resolverReferencia('sl 23'), const VerseRef('salmos', 23));
    expect(
      await repo.resolverReferencia('1 Coríntios 13:4'),
      const VerseRef('1-corintios', 13, 4),
    );
    expect(await repo.resolverReferencia('xyz 9:9'), isNull);
    expect(await repo.resolverReferencia('joao 99:1'), isNull); // fora do range
  });

  test('busca por palavra encontra ocorrências reais', () async {
    final hits = await repo
        .buscarPalavra('unigenito', testamento: 'NT')
        .take(3)
        .toList();
    expect(hits, isNotEmpty);
    for (final h in hits) {
      expect(h.texto.toLowerCase(), contains('unig'));
    }
  });
}
