import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import 'leitura_screen.dart';

/// Capítulos de um livro — grade de números com células UNIFORMES.
class CapitulosScreen extends StatelessWidget {
  final BibleRepository repository;
  final List<BibleBookMeta> livros;
  final BibleBookMeta livro;

  const CapitulosScreen({
    super.key,
    required this.repository,
    required this.livros,
    required this.livro,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(livro.nome)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha o capítulo',
                    style: textTheme.titleMedium
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: livro.totalCapitulos,
                      itemBuilder: (context, i) {
                        final cap = i + 1;
                        return _CapituloCell(
                          numero: cap,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LeituraScreen(
                                repository: repository,
                                livros: livros,
                                bookId: livro.id,
                                capitulo: cap,
                              ),
                            ),
                          ),
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

class _CapituloCell extends StatelessWidget {
  final int numero;
  final VoidCallback onTap;
  const _CapituloCell({required this.numero, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Capítulo $numero',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '$numero',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
