import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um devocional temático (modelo de apresentação — sem domínio).
class ItemDevocional {
  final String titulo;
  final String corpo;
  final String? autor;

  /// Referência bíblica que ancora o devocional (ex.: "1 Coríntios 16:13").
  final String? referencia;

  const ItemDevocional(
    this.titulo,
    this.corpo, {
    this.autor,
    this.referencia,
  });
}

/// Devocional temático (ex.: Homens, Mulheres) — lista + detalhe (padrão P&B).
///
/// APENAS camada de apresentação, autocontida: recebe o título da tela, um
/// texto de introdução e a lista de itens (com exemplos definidos na
/// composição). Reaproveitada por diferentes trilhas devocionais.
class DevocionalTematicoScreen extends StatelessWidget {
  final String appBarTitle;
  final String introTitulo;
  final String introSubtitulo;
  final List<ItemDevocional> itens;

  const DevocionalTematicoScreen({
    super.key,
    required this.appBarTitle,
    required this.introTitulo,
    required this.introSubtitulo,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: itens.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _Intro(titulo: introTitulo, subtitulo: introSubtitulo);
                }
                final item = itens[i - 1];
                return _ItemCard(
                  item: item,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _DetalheScreen(item: item),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  const _Intro({required this.titulo, required this.subtitulo});

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
            titulo,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemDevocional item;
  final VoidCallback onTap;
  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir ${item.titulo}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book_outlined,
                      size: 24, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.corpo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      if (item.referencia != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.auto_stories_outlined,
                                size: 15, color: scheme.onSurfaceVariant,),
                            const SizedBox(width: 6),
                            Text(
                              item.referencia!,
                              style: textTheme.labelMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 14),
                  child:
                      Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetalheScreen extends StatelessWidget {
  final ItemDevocional item;
  const _DetalheScreen({required this.item});

  String get _compartilhavel {
    final ref = item.referencia != null ? '\n\n${item.referencia}' : '';
    return '${item.titulo}\n\n${item.corpo}$ref\n\nGoel Church';
  }

  Future<void> _compartilhar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_compartilhavel)}',
    );
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Devocional')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              children: [
                Text(
                  item.titulo,
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                ),
                if (item.autor != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.autor!,
                    style: textTheme.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
                if (item.referencia != null) ...[
                  const SizedBox(height: 14),
                  _ReferenciaPill(referencia: item.referencia!),
                ],
                const SizedBox(height: 20),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 20),
                Text(
                  item.corpo,
                  style: textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 18),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _compartilhar(context),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Referência bíblica em "pílula" com ícone (identidade P&B).
class _ReferenciaPill extends StatelessWidget {
  final String referencia;
  const _ReferenciaPill({required this.referencia});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_stories_outlined, size: 18, color: scheme.onSurface),
            const SizedBox(width: 8),
            Text(
              referencia,
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
