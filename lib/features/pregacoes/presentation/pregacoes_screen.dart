import 'package:flutter/material.dart';

/// Uma pregação/publicação (modelo de apresentação — sem domínio).
class Pregacao {
  final String titulo;
  final String pregador;
  final DateTime quando;
  const Pregacao({
    required this.titulo,
    required this.pregador,
    required this.quando,
  });
}

/// Pregações — lista de mensagens da Goel Church (padrão preto e branco).
///
/// APENAS camada de apresentação. Os itens chegam por parâmetro, com uma lista
/// de EXEMPLO como padrão. [onAbrir] é opcional (abrir vídeo/link no futuro);
/// nulo → apenas informa que o vídeo chega em breve.
class PregacoesScreen extends StatelessWidget {
  /// Nulo → usa a lista de EXEMPLO. Uma lista vazia → estado vazio.
  final List<Pregacao>? pregacoes;
  final void Function(Pregacao)? onAbrir;

  const PregacoesScreen({super.key, this.pregacoes, this.onAbrir});

  static final _exemplo = <Pregacao>[
    Pregacao(
      titulo: 'A graça que transforma',
      pregador: 'Pr. João Batista',
      quando: DateTime(2026, 7, 20),
    ),
    Pregacao(
      titulo: 'Uma família para pertencer',
      pregador: 'Pra. Ana',
      quando: DateTime(2026, 7, 13),
    ),
    Pregacao(
      titulo: 'Fé que move montanhas',
      pregador: 'Pr. Paulo',
      quando: DateTime(2026, 7, 6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ordenados = [...(pregacoes ?? _exemplo)]
      ..sort((a, b) => b.quando.compareTo(a.quando)); // mais recentes primeiro

    return Scaffold(
      appBar: AppBar(title: const Text('Pregações')),
      body: SafeArea(
        child: ordenados.isEmpty
            ? const _EmptyState()
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: ordenados.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) return const _Intro();
                      final p = ordenados[i - 1];
                      return _PregacaoCard(
                        pregacao: p,
                        onTap: () => _abrir(context, p),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  void _abrir(BuildContext context, Pregacao p) {
    if (onAbrir != null) {
      onAbrir!(p);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('O vídeo estará disponível em breve.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mensagens para a sua semana',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Reveja as pregações e seja edificado onde estiver.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PregacaoCard extends StatelessWidget {
  final Pregacao pregacao;
  final VoidCallback onTap;
  const _PregacaoCard({required this.pregacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Assistir ${pregacao.titulo}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.play_arrow_rounded,
                      size: 32, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pregacao.titulo,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pregacao.pregador} · ${_fmtData(pregacao.quando)}',
                        style: textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_circle_outline,
                  size: 40, color: scheme.onPrimaryContainer,),
            ),
            const SizedBox(height: 20),
            Text(
              'As pregações chegam em breve.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtData(DateTime d) {
  const meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${d.day} ${meses[d.month - 1]} ${d.year}';
}
