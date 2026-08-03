import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../pregacoes/presentation/pregacoes_screen.dart';

/// Aba "Palavras" — hub de pregações e publicações (padrão preto e branco).
///
/// APENAS camada de apresentação. Conteúdo por parâmetro, com exemplos. Ao
/// tocar, abre o material da publicação (pasta no Google Drive) no app do
/// sistema; se o link ainda não existir, avisa de forma honesta. É uma ABA
/// (sem AppBar): traz o próprio cabeçalho no corpo, como Início/Contribua.
class PalavrasScreen extends StatelessWidget {
  final List<Pregacao>? itens;

  /// Injeção opcional para abrir o link (testes). Nulo → usa url_launcher.
  final Future<void> Function(String url)? onAbrir;

  const PalavrasScreen({super.key, this.itens, this.onAbrir});

  static final _exemplo = <Pregacao>[
    Pregacao(
      titulo: 'A graça que transforma',
      pregador: 'Pr. João Batista',
      quando: DateTime(2026, 7, 20),
      videoUrl:
          'https://drive.google.com/drive/folders/1Blva_m4CvUVMznpYxmHLnYNMXf5o6qEU?usp=sharing',
    ),
    Pregacao(
      titulo: 'Uma família para pertencer',
      pregador: 'Pra. Ana',
      quando: DateTime(2026, 7, 13),
      videoUrl:
          'https://drive.google.com/drive/folders/1b-ss_QoPYWt0IhfsJmWrDqOE2A94mj7U?usp=sharing',
    ),
    Pregacao(
      titulo: 'Fé que move montanhas',
      pregador: 'Pr. Paulo',
      quando: DateTime(2026, 7, 6),
      videoUrl:
          'https://drive.google.com/drive/folders/1eNAbVXauLql90fPjRvStF2xyaZLBWJa0?usp=sharing',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = [...(itens ?? _exemplo)]
      ..sort((a, b) => b.quando.compareTo(a.quando));

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 32),
          children: [
            Text(
              'Palavras',
              style:
                  textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Pregações e publicações da Goel Church.',
              style:
                  textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _DestaqueCard(
              pregacao: lista.first,
              onTap: () => _abrir(context, lista.first),
            ),
            const SizedBox(height: 24),
            Text(
              'Mais recentes',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            for (final p in lista.skip(1)) ...[
              _PregacaoTile(pregacao: p, onTap: () => _abrir(context, p)),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  /// Abre o material da publicação (pasta no Google Drive) no app do sistema.
  /// Sem link → aviso honesto de que o conteúdo chega em breve.
  Future<void> _abrir(BuildContext context, Pregacao p) async {
    final messenger = ScaffoldMessenger.of(context);
    final url = p.videoUrl;
    if (url == null) {
      _aviso(messenger);
      return;
    }
    try {
      if (onAbrir != null) {
        await onAbrir!(url);
      } else {
        final ok =
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (!ok) throw Exception('falha');
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o link agora.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _aviso(ScaffoldMessengerState messenger) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('O conteúdo estará disponível em breve.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }
}

/// Card grande de destaque (última mensagem).
class _DestaqueCard extends StatelessWidget {
  final Pregacao pregacao;
  final VoidCallback onTap;
  const _DestaqueCard({required this.pregacao, required this.onTap});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: DecoratedBox(
                  decoration:
                      BoxDecoration(color: scheme.surfaceContainerHighest),
                  child: Icon(Icons.play_circle_outline,
                      size: 64, color: scheme.onSurface,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pregacao.titulo,
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pregacao.pregador,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PregacaoTile extends StatelessWidget {
  final Pregacao pregacao;
  final VoidCallback onTap;
  const _PregacaoTile({required this.pregacao, required this.onTap});

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
                  child: Text(
                    pregacao.titulo,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
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
