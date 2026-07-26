import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

/// Tela do Versículo do dia (Slice 06) — redesign visual (preto e branco).
///
/// APENAS camada de apresentação: o contrato é preservado
/// (`VersiculoScreen(repository:, sourceLabel:)`). Leitura para todas as idades:
/// texto amplo, centrado, entrelinhas confortáveis e alto contraste.
class VersiculoScreen extends StatelessWidget {
  final VerseRepository repository;

  /// Rótulo opcional de fonte/atribuição (ex.: "Almeida — domínio público").
  final String? sourceLabel;

  const VersiculoScreen({
    super.key,
    required this.repository,
    this.sourceLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Versículo do dia')),
      body: SafeArea(
        child: FutureBuilder<DailyVerse>(
          future: repository.verseForToday(DateTime.now()),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text(
                  'Não foi possível carregar agora.',
                  style: textTheme.titleMedium,
                ),
              );
            }
            return _VerseView(verse: snapshot.data!, sourceLabel: sourceLabel);
          },
        ),
      ),
    );
  }
}

class _VerseView extends StatelessWidget {
  final DailyVerse verse;
  final String? sourceLabel;

  const _VerseView({required this.verse, this.sourceLabel});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.format_quote,
                size: 56,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _ReferencePill(reference: verse.reference),
              if (sourceLabel != null) ...[
                const SizedBox(height: 16),
                Text(
                  sourceLabel!,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Referência do versículo em uma "pílula" com ícone (identidade P&B).
class _ReferencePill extends StatelessWidget {
  final String reference;
  const _ReferencePill({required this.reference});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined, size: 20, color: scheme.onSurface),
          const SizedBox(width: 8),
          Text(
            reference,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
