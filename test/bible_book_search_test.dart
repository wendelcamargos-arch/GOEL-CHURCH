import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:goel_domain/goel_domain.dart';

/// Busca por LIVRO (navegação) — Hotfix Bible Engine.
///
/// Usa o manifest REAL (os 66 livros), não um fake: é a mesma fonte que o app
/// carrega em produção. Assim, nenhum número aqui é inventado.
List<BibleBookMeta> _livrosReais() {
  final raw = File('assets/biblia/manifest.json').readAsStringSync();
  final data = jsonDecode(raw) as Map<String, dynamic>;
  return [
    for (final m in (data['livros'] as List).cast<Map<String, dynamic>>())
      BibleBookMeta(
        id: m['id'] as String,
        nome: m['nome'] as String,
        abrev: m['abrev'] as String,
        testamento: m['testamento'] as String,
        ordem: (m['ordem'] as num).toInt(),
        versiculosPorCapitulo: (m['versiculosPorCapitulo'] as List)
            .map((e) => (e as num).toInt())
            .toList(),
      ),
  ];
}

void main() {
  final livros = _livrosReais();
  final parser = ReferenceParser(livros);

  List<String> nomes(String termo) =>
      [for (final l in parser.buscarLivros(termo)) l.nome];

  group('busca por livro (navegação)', () {
    test('1. "rom" retorna Romanos', () {
      expect(nomes('rom').first, 'Romanos');
    });

    test('2. "roma" retorna Romanos', () {
      expect(nomes('roma').first, 'Romanos');
    });

    test('3. "romanos" retorna Romanos', () {
      expect(nomes('romanos').first, 'Romanos');
    });

    test('4. a busca é case-insensitive', () {
      for (final t in ['ROMANOS', 'Romanos', 'rOmAnOs', 'ROM']) {
        expect(nomes(t).first, 'Romanos', reason: 'termo "$t"');
      }
    });

    test('5. a busca é accent-insensitive', () {
      expect(nomes('joao').first, 'João');
      expect(nomes('João').first, 'João');
      expect(nomes('joão').first, 'João');
      expect(nomes('genesis').first, 'Gênesis');
      expect(nomes('exodo').first, 'Êxodo');
    });

    test('"joa" sugere João em tempo real (3 caracteres)', () {
      expect(nomes('joa').first, 'João');
    });

    test('aliases: "sal" e "slm" chegam a Salmos; "sl" é a abreviação', () {
      expect(nomes('sal').first, 'Salmos');
      expect(nomes('slm').first, 'Salmos');
      expect(nomes('sl').first, 'Salmos');
    });

    test('abreviação exata resolve o livro ("rm" → Romanos)', () {
      expect(nomes('rm').first, 'Romanos');
    });

    test('termo curto (< 3) não dispara busca por prefixo', () {
      // "ro" não é abreviação de nada e tem menos de 3 caracteres:
      // a tela continua aguardando o usuário digitar.
      expect(parser.buscarLivros('ro'), isEmpty);
    });

    test('termo parcial encontra a família ("samuel")', () {
      expect(nomes('samuel'), containsAll(<String>['1 Samuel', '2 Samuel']));
    });

    test('termo sem correspondência retorna vazio', () {
      expect(parser.buscarLivros('amor'), isEmpty);
      expect(parser.buscarLivros('zzzz'), isEmpty);
    });

    test('o livro encontrado carrega o total REAL de capítulos', () {
      final romanos = parser.buscarLivros('romanos').first;
      expect(romanos.totalCapitulos, 16); // 9. Romanos → 16 capítulos
    });
  });

  group('referência continua funcionando', () {
    test('6. "João 3:16" é reconhecido como referência', () {
      final ref = parser.resolve('João 3:16');
      expect(ref, isNotNull);
      expect(ref!.bookId, 'joao');
      expect(ref.capitulo, 3);
      expect(ref.versiculo, 16);
    });

    test('"Romanos 8" e "Romanos 8:28" resolvem', () {
      expect(parser.resolve('Romanos 8'), const VerseRef('romanos', 8));
      expect(parser.resolve('Romanos 8:28'), const VerseRef('romanos', 8, 28));
    });

    test('"Sl 23" resolve pela abreviação', () {
      expect(parser.resolve('Sl 23'), const VerseRef('salmos', 23));
    });

    test('referência inválida não resolve', () {
      expect(parser.resolve('Romanos 99'), isNull);
      expect(parser.resolve('Romanos 8:999'), isNull);
    });
  });

  group('15. nenhuma quantidade de versículos é hardcoded', () {
    test('a contagem vem do manifest (versiculosPorCapitulo)', () {
      BibleBookMeta livro(String id) => livros.firstWhere((l) => l.id == id);

      // 10. Romanos 8 → 39 versículos.
      expect(livro('romanos').versiculosDoCapitulo(8), 39);
      // 13. Salmos 119 → 176 versículos.
      expect(livro('salmos').versiculosDoCapitulo(119), 176);
      // 14. Salmos 117 → a quantidade real daquele capítulo.
      expect(livro('salmos').versiculosDoCapitulo(117), 2);
      // 12. João 3 → a quantidade real.
      expect(livro('joao').versiculosDoCapitulo(3), 36);
    });

    test('todos os 1.189 capítulos têm contagem própria e positiva', () {
      var capitulos = 0;
      var versiculos = 0;
      for (final l in livros) {
        for (var c = 1; c <= l.totalCapitulos; c++) {
          final n = l.versiculosDoCapitulo(c);
          expect(n, greaterThan(0), reason: '${l.nome} $c');
          capitulos++;
          versiculos += n;
        }
      }
      expect(livros.length, 66);
      expect(capitulos, 1189);
      expect(versiculos, 31102);
    });

    test('capítulo inexistente devolve 0 (sem estourar)', () {
      final romanos = livros.firstWhere((l) => l.id == 'romanos');
      expect(romanos.versiculosDoCapitulo(0), 0);
      expect(romanos.versiculosDoCapitulo(17), 0);
    });
  });
}
