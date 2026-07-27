import 'package:flutter/material.dart';

/// Aba "Bíblia" — porta de entrada para a leitura (padrão preto e branco).
///
/// APENAS camada de apresentação: cabeçalho, busca visual (sem ação real) e
/// atalhos de livros. A leitura completa chega com o slice de conteúdo; por ora
/// os toques avisam "em breve". É uma ABA (sem AppBar): cabeçalho no corpo.
class BibliaScreen extends StatelessWidget {
  const BibliaScreen({super.key});

  static const _livros = <String>[
    'Gênesis',
    'Salmos',
    'Provérbios',
    'Isaías',
    'Mateus',
    'João',
    'Atos',
    'Romanos',
    'Filipenses',
    'Tiago',
    '1 João',
    'Apocalipse',
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 32),
          children: [
            Text(
              'Bíblia',
              style: textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'A Palavra de Deus, sempre à mão.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            // Busca visual (placeholder — sem ação por enquanto).
            Semantics(
              button: true,
              label: 'Buscar na Bíblia',
              child: InkWell(
                onTap: () => _aviso(context),
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
            Text(
              'Livros',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final livro in _livros)
                  _LivroChip(nome: livro, onTap: () => _aviso(context)),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'A Bíblia completa para leitura chega em breve.',
              style:
                  textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  void _aviso(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('A leitura da Bíblia chega em breve.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _LivroChip extends StatelessWidget {
  final String nome;
  final VoidCallback onTap;
  const _LivroChip({required this.nome, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir $nome',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 18, color: scheme.onSurface),
              const SizedBox(width: 8),
              Text(
                nome,
                style:
                    textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
