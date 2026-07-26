import 'package:flutter/material.dart';

/// Estado "Em breve" reutilizável — usado pelas abas ainda sem conteúdo e como
/// destino de fallback de atalhos. APENAS apresentação; nada de domínio aqui.
///
/// Mantém o tom acolhedor da Goel Church: em vez de uma tela vazia fria, uma
/// mensagem calorosa de que o recurso está a caminho.
class ComingSoonView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const ComingSoonView({
    super.key,
    required this.icon,
    required this.title,
    this.message = 'Estamos preparando este espaço com carinho.\nEm breve por aqui.',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tela "Em breve" completa (com AppBar) para navegação empilhada a partir de
/// atalhos que ainda não têm destino real.
class ComingSoonScreen extends StatelessWidget {
  final IconData icon;
  final String title;

  const ComingSoonScreen({super.key, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ComingSoonView(icon: icon, title: title),
    );
  }
}
