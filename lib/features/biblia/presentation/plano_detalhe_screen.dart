import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/planos.dart';
import '../data/reading_store.dart';
import 'leitura_screen.dart';

/// Detalhe de um plano — dias, leituras e progresso (marcar como lido). Toca
/// numa leitura para abrir a Bíblia naquele capítulo.
class PlanoDetalheScreen extends StatefulWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  final String planoId;

  const PlanoDetalheScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
    required this.planoId,
  });

  @override
  State<PlanoDetalheScreen> createState() => _PlanoDetalheScreenState();
}

class _PlanoDetalheScreenState extends State<PlanoDetalheScreen> {
  final _planos = PlanoRepository();
  late final Future<Plano> _future = _planos.carregar(widget.planoId);
  late final Map<String, String> _nomes = {
    for (final b in widget.livros) b.id: b.nome,
  };

  String _rotuloDia(List<VerseRef> refs) {
    final partes = <String>[];
    var i = 0;
    while (i < refs.length) {
      final b = refs[i].bookId;
      final inicio = refs[i].capitulo;
      var fim = inicio;
      var j = i + 1;
      while (j < refs.length &&
          refs[j].bookId == b &&
          refs[j].capitulo == fim + 1) {
        fim = refs[j].capitulo;
        j++;
      }
      final nome = _nomes[b] ?? b;
      partes.add(fim > inicio ? '$nome $inicio–$fim' : '$nome $inicio');
      i = j;
    }
    return partes.join(' · ');
  }

  void _abrir(VerseRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeituraScreen(
          repository: widget.repository,
          store: widget.store,
          livros: widget.livros,
          bookId: ref.bookId,
          capitulo: ref.capitulo,
        ),
      ),
    );
  }

  Future<void> _alternarDia(int dia) async {
    await widget.store.alternarDia(widget.planoId, dia);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Plano de leitura')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: FutureBuilder<Plano>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final plano = snap.data!;
                final lidos = widget.store.diasLidos(widget.planoId);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: plano.totalDias + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plano.nome,
                                style: textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),),
                            const SizedBox(height: 4),
                            Text(
                              '${plano.descricao}\n'
                              '${lidos.length}/${plano.totalDias} dias concluídos',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }
                    final dia = i; // 1-based
                    final refs = plano.dias[dia - 1];
                    final lido = lidos.contains(dia);
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Checkbox(
                          value: lido,
                          onChanged: (_) => _alternarDia(dia),
                        ),
                        title: Text('Dia $dia',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              decoration:
                                  lido ? TextDecoration.lineThrough : null,
                            ),),
                        subtitle: Text(_rotuloDia(refs)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: refs.isEmpty ? null : () => _abrir(refs.first),
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
