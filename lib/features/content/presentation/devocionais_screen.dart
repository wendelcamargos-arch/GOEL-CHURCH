import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

/// Lista de devocionais (Slice 07) — redesign visual (preto e branco).
///
/// APENAS camada de apresentação: o contrato é preservado
/// (`DevocionaisScreen(repository:)`, abre [DevocionalDetailScreen] ao tocar).
/// Acessível a todas as idades: itens amplos, tipografia legível, contraste alto
/// e leitura confortável.
class DevocionaisScreen extends StatelessWidget {
  final DevotionalRepository repository;
  const DevocionaisScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devocionais')),
      body: SafeArea(
        child: FutureBuilder<List<Devotional>>(
          future: repository.list(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return const _EmptyState();
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: items.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    if (i == 0) return const _ListIntro();
                    final d = items[i - 1];
                    return _DevotionalCard(
                      devotional: d,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DevocionalDetailScreen(devotional: d),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ListIntro extends StatelessWidget {
  const _ListIntro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leituras para o seu dia',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Uma palavra para caminhar com Deus hoje.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DevotionalCard extends StatelessWidget {
  final Devotional devotional;
  final VoidCallback onTap;
  const _DevotionalCard({required this.devotional, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir devocional ${devotional.title}',
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
                        devotional.title,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _meta(devotional),
                        style: textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        devotional.body,
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
                  child: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detalhe de um devocional — leitura confortável (preto e branco).
class DevocionalDetailScreen extends StatelessWidget {
  final Devotional devotional;
  const DevocionalDetailScreen({super.key, required this.devotional});

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
                  devotional.title,
                  style: textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 18, color: scheme.onSurfaceVariant,),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _meta(devotional),
                        style: textTheme.labelLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(color: scheme.outlineVariant),
                const SizedBox(height: 20),
                Text(
                  devotional.body,
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
              child: Icon(Icons.menu_book_outlined,
                  size: 40, color: scheme.onPrimaryContainer,),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum devocional disponível.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Assim que novas leituras chegarem, elas aparecem aqui.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de meta: "Autor · 6 jan 2026" (ou só a data, sem autor).
String _meta(Devotional d) {
  final date = _fmtDate(d.publishedAt);
  final author = d.author?.trim();
  return (author == null || author.isEmpty) ? date : '$author · $date';
}

String _fmtDate(DateTime d) {
  const meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${d.day} ${meses[d.month - 1]} ${d.year}';
}
