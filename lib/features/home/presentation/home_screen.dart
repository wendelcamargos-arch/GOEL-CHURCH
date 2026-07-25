import 'package:flutter/material.dart';

/// Home (Slice 05) — tela inicial após login/cadastro.
///
/// Navegação por JORNADAS reconhecíveis pelo público, com alvos amplos e
/// linguagem simples (acessibilidade ao idoso é requisito arquitetural).
/// Os conteúdos (Versículo, Devocional) entram nos Slices 06/07; aqui ficam os
/// pontos de entrada.
class HomeScreen extends StatelessWidget {
  final String? memberName;

  /// Destinos das jornadas, injetados pela composição raiz conforme os slices
  /// vão existindo. Nulo → placeholder "Em breve".
  final WidgetBuilder? versiculoBuilder;
  final WidgetBuilder? devocionalBuilder;

  const HomeScreen({
    super.key,
    this.memberName,
    this.versiculoBuilder,
    this.devocionalBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final greeting = (memberName == null || memberName!.trim().isEmpty)
        ? 'Bem-vindo(a) à Goel Church'
        : 'Olá, ${memberName!.split(' ').first}';

    return Scaffold(
      appBar: AppBar(title: const Text('Goel Church')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(greeting, style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Uma igreja para você frequentar e uma família para você '
              'pertencer.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _HomeCard(
              icon: Icons.auto_stories_outlined,
              title: 'Versículo do dia',
              subtitle: 'Uma palavra para hoje',
              onTap: () => _go(context, 'Versículo do dia', versiculoBuilder),
            ),
            const SizedBox(height: 16),
            _HomeCard(
              icon: Icons.menu_book_outlined,
              title: 'Devocionais',
              subtitle: 'Leituras para o seu dia',
              onTap: () => _go(context, 'Devocionais', devocionalBuilder),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String title, WidgetBuilder? builder) {
    final WidgetBuilder destination;
    if (builder != null) {
      destination = builder;
    } else {
      destination = (_) => _ComingSoonScreen(title: title);
    }
    Navigator.of(context).push(MaterialPageRoute(builder: destination));
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleLarge),
                    Text(subtitle, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder até o conteúdo do slice correspondente (06/07) existir.
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Em breve.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
