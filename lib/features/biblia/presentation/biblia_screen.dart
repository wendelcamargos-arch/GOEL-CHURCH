import 'package:flutter/material.dart';

import '../data/biblia_livros.dart';
import 'capitulos_screen.dart';

/// Aba "Bíblia" — lista TODOS os 66 livros (tiles uniformes), agrupados por
/// Testamento. Tocar um livro abre os capítulos; o capítulo abre a leitura.
///
/// APENAS camada de apresentação: livros e nº de capítulos são reais; o TEXTO
/// dos versículos chega com o conjunto de dados (Almeida — domínio público).
/// É uma ABA (sem AppBar): traz o cabeçalho no corpo.
class BibliaScreen extends StatelessWidget {
  const BibliaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final at = kLivrosBiblia.where((l) => l.antigoTestamento).toList();
    final nt = kLivrosBiblia.where((l) => !l.antigoTestamento).toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 32),
          children: [
            Text(
              'Bíblia',
              style:
                  textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'A Palavra de Deus, sempre à mão.',
              style:
                  textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Buscar na Bíblia',
              child: InkWell(
                onTap: () => _emBreve(context, 'A busca chega em breve.'),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Text(
                        'Buscar livro, capítulo ou versículo',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SecaoTitulo(texto: 'Antigo Testamento'),
            const SizedBox(height: 8),
            for (final l in at) _LivroTile(livro: l),
            const SizedBox(height: 20),
            const _SecaoTitulo(texto: 'Novo Testamento'),
            const SizedBox(height: 8),
            for (final l in nt) _LivroTile(livro: l),
          ],
        ),
      ),
    );
  }

  void _emBreve(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _SecaoTitulo extends StatelessWidget {
  final String texto;
  const _SecaoTitulo({required this.texto});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      texto,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

/// Tile uniforme de um livro (mesma altura para todos).
class _LivroTile extends StatelessWidget {
  final LivroBiblia livro;
  const _LivroTile({required this.livro});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: 'Abrir ${livro.nome}',
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CapitulosScreen(livro: livro)),
            ),
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 22, color: scheme.onSurfaceVariant,),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        livro.nome,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${livro.capitulos} cap.',
                      style: textTheme.labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
