// GOEL CHURCH · BIBLE ENGINE — Importador (roda 1x, offline, local).
//
// Converte a fonte Almeida 1911 (domínio público, digitalização JFAAL) para o
// formato do app: `manifest.json` + `livros/<id>.json` (1 arquivo por livro),
// VALIDANDO as contagens canônicas (66 livros / 1189 capítulos / 31102 vers.).
//
// Origem da fonte (baixar 1x para tool/source/jfaal_1911.json):
//   https://raw.githubusercontent.com/BibliaJFAAL/JFAAL/main/original/1911-JFAAtualizada.json
//
// Uso:
//   dart run tool/build_biblia.dart [source.json] [outDir]
//   (padrões: tool/source/jfaal_1911.json  e  assets/biblia)
import 'dart:convert';
import 'dart:io';

// Tabela canônica dos 66 livros (nr 1..66): [nr, id, nome, abrev, nºcaps, AT?].
const List<List<Object>> kCanon = [
  [1, 'genesis', 'Gênesis', 'Gn', 50, true],
  [2, 'exodo', 'Êxodo', 'Êx', 40, true],
  [3, 'levitico', 'Levítico', 'Lv', 27, true],
  [4, 'numeros', 'Números', 'Nm', 36, true],
  [5, 'deuteronomio', 'Deuteronômio', 'Dt', 34, true],
  [6, 'josue', 'Josué', 'Js', 24, true],
  [7, 'juizes', 'Juízes', 'Jz', 21, true],
  [8, 'rute', 'Rute', 'Rt', 4, true],
  [9, '1-samuel', '1 Samuel', '1Sm', 31, true],
  [10, '2-samuel', '2 Samuel', '2Sm', 24, true],
  [11, '1-reis', '1 Reis', '1Rs', 22, true],
  [12, '2-reis', '2 Reis', '2Rs', 25, true],
  [13, '1-cronicas', '1 Crônicas', '1Cr', 29, true],
  [14, '2-cronicas', '2 Crônicas', '2Cr', 36, true],
  [15, 'esdras', 'Esdras', 'Ed', 10, true],
  [16, 'neemias', 'Neemias', 'Ne', 13, true],
  [17, 'ester', 'Ester', 'Et', 10, true],
  [18, 'jo', 'Jó', 'Jó', 42, true],
  [19, 'salmos', 'Salmos', 'Sl', 150, true],
  [20, 'proverbios', 'Provérbios', 'Pv', 31, true],
  [21, 'eclesiastes', 'Eclesiastes', 'Ec', 12, true],
  [22, 'cantares', 'Cânticos dos Cânticos', 'Ct', 8, true],
  [23, 'isaias', 'Isaías', 'Is', 66, true],
  [24, 'jeremias', 'Jeremias', 'Jr', 52, true],
  [25, 'lamentacoes', 'Lamentações', 'Lm', 5, true],
  [26, 'ezequiel', 'Ezequiel', 'Ez', 48, true],
  [27, 'daniel', 'Daniel', 'Dn', 12, true],
  [28, 'oseias', 'Oseias', 'Os', 14, true],
  [29, 'joel', 'Joel', 'Jl', 3, true],
  [30, 'amos', 'Amós', 'Am', 9, true],
  [31, 'obadias', 'Obadias', 'Ob', 1, true],
  [32, 'jonas', 'Jonas', 'Jn', 4, true],
  [33, 'miqueias', 'Miqueias', 'Mq', 7, true],
  [34, 'naum', 'Naum', 'Na', 3, true],
  [35, 'habacuque', 'Habacuque', 'Hc', 3, true],
  [36, 'sofonias', 'Sofonias', 'Sf', 3, true],
  [37, 'ageu', 'Ageu', 'Ag', 2, true],
  [38, 'zacarias', 'Zacarias', 'Zc', 14, true],
  [39, 'malaquias', 'Malaquias', 'Ml', 4, true],
  [40, 'mateus', 'Mateus', 'Mt', 28, false],
  [41, 'marcos', 'Marcos', 'Mc', 16, false],
  [42, 'lucas', 'Lucas', 'Lc', 24, false],
  [43, 'joao', 'João', 'Jo', 21, false],
  [44, 'atos', 'Atos', 'At', 28, false],
  [45, 'romanos', 'Romanos', 'Rm', 16, false],
  [46, '1-corintios', '1 Coríntios', '1Co', 16, false],
  [47, '2-corintios', '2 Coríntios', '2Co', 13, false],
  [48, 'galatas', 'Gálatas', 'Gl', 6, false],
  [49, 'efesios', 'Efésios', 'Ef', 6, false],
  [50, 'filipenses', 'Filipenses', 'Fp', 4, false],
  [51, 'colossenses', 'Colossenses', 'Cl', 4, false],
  [52, '1-tessalonicenses', '1 Tessalonicenses', '1Ts', 5, false],
  [53, '2-tessalonicenses', '2 Tessalonicenses', '2Ts', 3, false],
  [54, '1-timoteo', '1 Timóteo', '1Tm', 6, false],
  [55, '2-timoteo', '2 Timóteo', '2Tm', 4, false],
  [56, 'tito', 'Tito', 'Tt', 3, false],
  [57, 'filemom', 'Filemom', 'Fm', 1, false],
  [58, 'hebreus', 'Hebreus', 'Hb', 13, false],
  [59, 'tiago', 'Tiago', 'Tg', 5, false],
  [60, '1-pedro', '1 Pedro', '1Pe', 5, false],
  [61, '2-pedro', '2 Pedro', '2Pe', 3, false],
  [62, '1-joao', '1 João', '1Jo', 5, false],
  [63, '2-joao', '2 João', '2Jo', 1, false],
  [64, '3-joao', '3 João', '3Jo', 1, false],
  [65, 'judas', 'Judas', 'Jd', 1, false],
  [66, 'apocalipse', 'Apocalipse', 'Ap', 22, false],
];

void main(List<String> args) {
  final sourcePath = args.isNotEmpty ? args[0] : 'tool/source/jfaal_1911.json';
  final outDir = args.length > 1 ? args[1] : 'assets/biblia';

  final srcFile = File(sourcePath);
  if (!srcFile.existsSync()) {
    stderr.writeln('ERRO: fonte não encontrada em "$sourcePath".');
    stderr.writeln('Baixe de: https://raw.githubusercontent.com/BibliaJFAAL/'
        'JFAAL/main/original/1911-JFAAtualizada.json');
    exit(1);
  }

  final src = jsonDecode(srcFile.readAsStringSync()) as Map<String, dynamic>;
  final books = (src['books'] as List).cast<Map<String, dynamic>>();
  if (books.length != 66) {
    stderr.writeln('ERRO: esperados 66 livros, a fonte tem ${books.length}.');
    exit(1);
  }

  Directory('$outDir/livros').createSync(recursive: true);
  final manifestLivros = <Map<String, dynamic>>[];
  final problemas = <String>[];
  var totalCap = 0;
  var totalVer = 0;

  for (final canon in kCanon) {
    final nr = canon[0] as int;
    final id = canon[1] as String;
    final nome = canon[2] as String;
    final abrev = canon[3] as String;
    final capCanon = canon[4] as int;
    final at = canon[5] as bool;

    final book = books.firstWhere(
      (b) => (b['nr'] as num).toInt() == nr,
      orElse: () => throw StateError('Livro nr=$nr ($nome) ausente na fonte.'),
    );
    final chapters = (book['chapters'] as List).cast<Map<String, dynamic>>();
    if (chapters.length != capCanon) {
      problemas.add('$nome: ${chapters.length} capítulos != canônico $capCanon');
    }

    final capitulos = <List<String>>[];
    final versiculosPorCapitulo = <int>[];
    for (final ch in chapters) {
      final verses = (ch['verses'] as List).cast<Map<String, dynamic>>()
        ..sort(
          (a, b) =>
              (a['verse'] as num).toInt().compareTo((b['verse'] as num).toInt()),
        );
      final textos = [for (final v in verses) (v['text'] as String).trim()];
      capitulos.add(textos);
      versiculosPorCapitulo.add(textos.length);
      totalVer += textos.length;
    }
    totalCap += capitulos.length;

    File('$outDir/livros/$id.json').writeAsStringSync(jsonEncode({
      'id': id,
      'nome': nome,
      'abrev': abrev,
      'capitulos': capitulos,
    }),);

    manifestLivros.add({
      'id': id,
      'nome': nome,
      'abrev': abrev,
      'testamento': at ? 'AT' : 'NT',
      'ordem': nr,
      'versiculosPorCapitulo': versiculosPorCapitulo,
    });
  }

  File('$outDir/manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'traducao': 'Almeida 1911 — Domínio Público',
      'fonte': 'João Ferreira de Almeida (1911) · digitalização JFAAL',
      'versao': 1,
      'livros': manifestLivros,
    }),
  );

  stdout.writeln('=== IMPORTAÇÃO BÍBLIA (Almeida 1911 — Domínio Público) ===');
  stdout.writeln('Livros:     ${manifestLivros.length}\t(esperado 66)');
  stdout.writeln('Capítulos:  $totalCap\t(esperado 1189)');
  stdout.writeln('Versículos: $totalVer\t(esperado 31102)');
  if (problemas.isNotEmpty) {
    stderr.writeln('\nDIVERGÊNCIAS:');
    problemas.forEach(stderr.writeln);
    exit(1);
  }
  if (manifestLivros.length != 66 || totalCap != 1189 || totalVer != 31102) {
    stderr.writeln('\nERRO: contagens não batem com o cânon. Abortado.');
    exit(1);
  }
  stdout.writeln('\nOK — contagens canônicas confirmadas. Assets em "$outDir".');
}
