import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/reading_store.dart';
import 'leitura_screen.dart';

/// Histórico de leitura (EU-06) — capítulos abertos recentemente.
class HistoricoScreen extends StatelessWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;

  const HistoricoScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final nomes = {for (final b in livros) b.id: b.nome};
    final itens = store.historico();

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: itens.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'Seu histórico de leitura aparecerá aqui.',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: itens.length,
                    itemBuilder: (context, i) {
                      final p = itens[i].split(':');
                      final bookId = p[0];
                      final cap = int.tryParse(p.length > 1 ? p[1] : '') ?? 1;
                      final nome = nomes[bookId] ?? bookId;
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          leading: Icon(Icons.history,
                              color: scheme.onSurfaceVariant,),
                          title: Text('$nome $cap',
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LeituraScreen(
                                repository: repository,
                                store: store,
                                livros: livros,
                                bookId: bookId,
                                capitulo: cap,
                              ),
                            ),
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
