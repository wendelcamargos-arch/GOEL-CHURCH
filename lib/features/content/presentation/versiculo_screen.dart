import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

/// Tela do Versículo do dia (Slice 06). Acessível ao idoso: texto amplo,
/// centrado, alto contraste (do tema).
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
                child: Text('Não foi possível carregar agora.',
                    style: textTheme.titleMedium,),
              );
            }
            final verse = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '"${verse.text}"',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Text(verse.reference, style: textTheme.titleMedium),
                    if (sourceLabel != null) ...[
                      const SizedBox(height: 8),
                      Text(sourceLabel!, style: textTheme.labelSmall),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
