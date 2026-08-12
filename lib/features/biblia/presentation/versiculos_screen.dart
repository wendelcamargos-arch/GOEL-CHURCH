import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/reading_store.dart';
import 'leitura_screen.dart';

/// Versículos de um capítulo — grade de números com células UNIFORMES, mesmo
/// padrão visual da grade de capítulos.
///
/// Fluxo oficial: **Livro → Capítulo → Versículo → Leitor**. Tocar um número
/// abre a leitura já posicionada naquele versículo.
///
/// A quantidade de células NUNCA é fixa no código: vem da fonte real
/// ([BibleBookMeta.versiculosDoCapitulo], alimentada por
/// `versiculosPorCapitulo` do manifest). Funciona para os 1.189 capítulos.
class VersiculosScreen extends StatelessWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  final BibleBookMeta livro;
  final int capitulo;

  const VersiculosScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
    required this.livro,
    required this.capitulo,
  });

  /// Quantidade REAL de versículos do capítulo (fonte: manifest).
  int get totalVersiculos => livro.versiculosDoCapitulo(capitulo);

  void _abrir(BuildContext context, {int? versiculo}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeituraScreen(
          repository: repository,
          store: store,
          livros: livros,
          bookId: livro.id,
          capitulo: capitulo,
          versiculoInicial: versiculo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final total = totalVersiculos;

    return Scaffold(
      appBar: AppBar(title: Text('${livro.nome} $capitulo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Escolha o versículo',
                          style: textTheme.titleMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _abrir(context),
                        icon: const Icon(Icons.menu_book_outlined, size: 18),
                        label: const Text('Ler o capítulo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: total == 0
                        ? Center(
                            child: Text(
                              'Capítulo sem versículos.',
                              style: textTheme.titleMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : GridView.builder(
                            // Grade responsiva: ~5 colunas no telefone, mais
                            // colunas quando há largura (tablet/paisagem).
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 84,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                            itemCount: total,
                            itemBuilder: (context, i) {
                              final numero = i + 1;
                              return _VersiculoCell(
                                numero: numero,
                                onTap: () =>
                                    _abrir(context, versiculo: numero),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersiculoCell extends StatelessWidget {
  final int numero;
  final VoidCallback onTap;
  const _VersiculoCell({required this.numero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Versículo $numero',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$numero',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
