import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/planos.dart';
import '../data/reading_store.dart';
import 'plano_detalhe_screen.dart';

/// Lista dos planos de leitura (EU-05/EU-12): 30 dias, 90 dias, anual e o
/// Plano Goel Church.
class PlanosScreen extends StatefulWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;

  const PlanosScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
  });

  @override
  State<PlanosScreen> createState() => _PlanosScreenState();
}

class _PlanosScreenState extends State<PlanosScreen> {
  final _planos = PlanoRepository();
  late final Future<List<PlanoMeta>> _future = _planos.listar();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Planos de leitura')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: FutureBuilder<List<PlanoMeta>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final planos = snap.data ?? const [];
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: planos.length,
                  itemBuilder: (context, i) {
                    final p = planos[i];
                    final lidos = widget.store.diasLidos(p.id).length;
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(Icons.event_note_outlined,
                            size: 30, color: scheme.primary,),
                        title: Text(p.nome,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${p.descricao}\n${p.dias} dias · $lidos concluído(s)',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PlanoDetalheScreen(
                              repository: widget.repository,
                              store: widget.store,
                              livros: widget.livros,
                              planoId: p.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
