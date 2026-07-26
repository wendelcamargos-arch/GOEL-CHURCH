import 'package:flutter/material.dart';

/// Um item de mídia (modelo de apresentação — sem domínio).
class MidiaItem {
  final String titulo;
  final bool video;
  const MidiaItem(this.titulo, {this.video = false});
}

/// Fotos e vídeos — galeria de momentos (padrão preto e branco).
///
/// APENAS camada de apresentação. Os itens chegam por parâmetro, com exemplos
/// como padrão. Ao tocar, informa que o álbum chega em breve (sem player nem
/// rede). Quando houver o slice de dados/armazenamento, injete os reais.
class GaleriaScreen extends StatelessWidget {
  final List<MidiaItem>? itens;

  const GaleriaScreen({super.key, this.itens});

  static const _exemplo = <MidiaItem>[
    MidiaItem('Culto de Domingo', video: true),
    MidiaItem('Batismos 2026'),
    MidiaItem('Encontro de Jovens'),
    MidiaItem('Ação Social'),
    MidiaItem('Louvor ao vivo', video: true),
    MidiaItem('Retiro da Família'),
  ];

  @override
  Widget build(BuildContext context) {
    final lista = itens ?? _exemplo;
    return Scaffold(
      appBar: AppBar(title: const Text('Fotos e vídeos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                const _Intro(),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (final m in lista)
                      _MidiaTile(
                        item: m,
                        onTap: () => _aviso(context),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _aviso(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('O álbum estará disponível em breve.'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Momentos da nossa família',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Reviva os encontros e celebrações da Goel Church.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _MidiaTile extends StatelessWidget {
  final MidiaItem item;
  final VoidCallback onTap;
  const _MidiaTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir ${item.titulo}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  item.video ? Icons.play_circle_outline : Icons.image_outlined,
                  size: 40,
                  color: scheme.onSurface,
                ),
                Text(
                  item.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
