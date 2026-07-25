import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

/// Lista de devocionais (Slice 07). Acessível ao idoso: itens amplos, título
/// legível. Abre o detalhe ao tocar.
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
              return Center(
                child: Text('Nenhum devocional disponível.',
                    style: Theme.of(context).textTheme.titleMedium),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DevotionalCard(
                devotional: items[i],
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DevocionalDetailScreen(devotional: items[i]),
                  ),
                ),
              ),
            );
          },
        ),
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
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(devotional.title, style: textTheme.titleLarge),
        subtitle: devotional.author == null
            ? null
            : Text(devotional.author!, style: textTheme.bodyMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Detalhe de um devocional.
class DevocionalDetailScreen extends StatelessWidget {
  final Devotional devotional;
  const DevocionalDetailScreen({super.key, required this.devotional});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Devocional')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(devotional.title, style: textTheme.headlineSmall),
            if (devotional.author != null) ...[
              const SizedBox(height: 4),
              Text(devotional.author!, style: textTheme.labelLarge),
            ],
            const SizedBox(height: 20),
            Text(devotional.body, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
