import 'package:flutter/material.dart';

/// Um devocional temático (modelo de apresentação — sem domínio).
class ItemDevocional {
  final String titulo;
  final String corpo;
  final String? autor;
  const ItemDevocional(this.titulo, this.corpo, {this.autor});
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: itens.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
            padding: const EdgeInsets.all(18),
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
                  child: Icon(Icons.menu_book_outlined,
                      size: 28, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.titulo,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.corpo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
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
                const SizedBox(height: 20),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 20),
                Text(
                  item.corpo,
                  style: textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
