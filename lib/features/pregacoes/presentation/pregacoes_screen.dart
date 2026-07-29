import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uma pregação/publicação (modelo de apresentação — sem domínio).
class Pregacao {
  final String titulo;
  final String pregador;
  final DateTime quando;

  /// Tema/resumo curto da mensagem (opcional).
  final String? tema;

  /// Link do vídeo (YouTube etc.). Quando presente, "Assistir" abre o link;
  /// quando nulo, a tela avisa de forma honesta que o vídeo chega em breve.
  final String? videoUrl;

  const Pregacao({
    required this.titulo,
    required this.pregador,
    required this.quando,
    this.tema,
    this.videoUrl,
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
      tema: 'O poder da graça para recomeçar.',
    ),
    Pregacao(
      titulo: 'Uma família para pertencer',
      pregador: 'Pra. Ana',
      quando: DateTime(2026, 7, 13),
      tema: 'Você foi criado para pertencer ao corpo de Cristo.',
    ),
    Pregacao(
      titulo: 'Fé que move montanhas',
      pregador: 'Pr. Paulo',
      quando: DateTime(2026, 7, 6),
      tema: 'Uma fé que age diante do impossível.',
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
                        onCompartilhar: () => _compartilhar(context, p),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context, Pregacao p) async {
    if (onAbrir != null) {
      onAbrir!(p);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    // Se houver vídeo, abre o link; senão, avisa de forma honesta.
    if (p.videoUrl != null) {
      try {
        final ok = await launchUrl(
          Uri.parse(p.videoUrl!),
          mode: LaunchMode.externalApplication,
        );
        if (ok) return;
      } catch (_) {
        // cai no aviso abaixo
      }
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('O vídeo estará disponível em breve.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  Future<void> _compartilhar(BuildContext context, Pregacao p) async {
    final linha = p.tema != null ? '\n${p.tema}' : '';
    final link = p.videoUrl != null ? '\n\nAssista: ${p.videoUrl}' : '';
    final texto = 'Pregação: ${p.titulo}\n'
        '${p.pregador} · ${_fmtData(p.quando)}$linha$link\n\nGoel Church';
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(texto)}');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('falha');
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o compartilhamento agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
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
  final VoidCallback onCompartilhar;
  const _PregacaoCard({
    required this.pregacao,
    required this.onTap,
    required this.onCompartilhar,
  });

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      if (pregacao.tema != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          pregacao.tema!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Compartilhar ${pregacao.titulo}',
                  onPressed: onCompartilhar,
                ),
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
