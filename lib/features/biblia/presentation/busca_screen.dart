import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/reading_store.dart';
import 'leitura_screen.dart';

/// Busca na Bíblia — por **referência** ("João 3:16", "sl 23") e por
/// **palavra** (resultados em stream, sob demanda). Tocar um resultado abre a
/// leitura naquele ponto.
class BuscaScreen extends StatefulWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;

  const BuscaScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
  });

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {
  final _controller = TextEditingController();
  StreamSubscription<SearchHit>? _sub;
  final List<SearchHit> _resultados = [];
  VerseRef? _refDireta;
  bool _buscando = false;
  bool _buscou = false;

  static const _limite = 300;

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final termo = _controller.text.trim();
    await _sub?.cancel();
    setState(() {
      _resultados.clear();
      _refDireta = null;
      _buscando = termo.isNotEmpty;
      _buscou = true;
    });
    if (termo.isEmpty) return;

    // Referência direta (se aplicável).
    final ref = await widget.repository.resolverReferencia(termo);
    if (!mounted) return;
    setState(() => _refDireta = ref);

    // Busca por palavra (stream).
    _sub = widget.repository.buscarPalavra(termo).listen(
      (hit) {
        if (!mounted) return;
        if (_resultados.length < _limite) {
          setState(() => _resultados.add(hit));
        } else {
          _sub?.cancel();
          setState(() => _buscando = false);
        }
      },
      onDone: () {
        if (mounted) setState(() => _buscando = false);
      },
      onError: (_) {
        if (mounted) setState(() => _buscando = false);
      },
    );
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

  String _nomeLivro(String bookId) =>
      widget.livros.firstWhere((b) => b.id == bookId).nome;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Palavra ou referência (ex.: graça, João 3:16)',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _buscar,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _resultadosView(textTheme, scheme)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultadosView(TextTheme textTheme, ColorScheme scheme) {
    if (!_buscou) {
      return _dica(textTheme, scheme);
    }
    final temRef = _refDireta != null;
    final total = _resultados.length + (temRef ? 1 : 0);
    if (!_buscando && total == 0) {
      return Center(
        child: Text('Nada encontrado.',
            style: textTheme.titleMedium
                ?.copyWith(color: scheme.onSurfaceVariant),),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (temRef) _refCard(_refDireta!, textTheme, scheme),
        if (_resultados.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Ocorrências${_buscando ? '…' : ' (${_resultados.length})'}',
              style: textTheme.labelLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        for (final h in _resultados) _hitTile(h, textTheme, scheme),
        if (_buscando)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _refCard(VerseRef ref, TextTheme textTheme, ColorScheme scheme) {
    final rotulo = ref.versiculo == null
        ? '${_nomeLivro(ref.bookId)} ${ref.capitulo}'
        : '${_nomeLivro(ref.bookId)} ${ref.capitulo}:${ref.versiculo}';
    return Card(
      color: scheme.primaryContainer,
      child: ListTile(
        leading: Icon(Icons.menu_book_outlined, color: scheme.onPrimaryContainer),
        title: Text('Ir para $rotulo',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),),
        trailing: Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
        onTap: () => _abrir(ref),
      ),
    );
  }

  Widget _hitTile(SearchHit h, TextTheme textTheme, ColorScheme scheme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(h.rotulo,
            style:
                textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),),
        subtitle: Text(h.texto, maxLines: 3, overflow: TextOverflow.ellipsis),
        onTap: () => _abrir(h.ref),
      ),
    );
  }

  Widget _dica(TextTheme textTheme, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          'Digite uma palavra para encontrar versículos, ou uma referência '
          'como "João 3:16" para abrir direto.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
