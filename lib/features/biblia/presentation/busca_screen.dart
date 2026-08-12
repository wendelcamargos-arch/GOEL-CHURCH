import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../data/reading_store.dart';
import 'capitulos_screen.dart';
import 'leitura_screen.dart';

/// Busca na Bíblia, em três camadas com prioridade explícita:
///
/// 1. **Referência** ("João 3:16", "Romanos 8") → abre direto o trecho;
/// 2. **Livro** ("rom", "roma", "Romanos") → navegação por livro, sugerida em
///    tempo real a partir de 3 caracteres;
/// 3. **Conteúdo** — ocorrências da palavra nos 31.102 versículos (sob
///    demanda, ao confirmar a busca).
///
/// A correspondência de LIVRO tem prioridade visual sobre as ocorrências
/// textuais: digitar "Romanos" mostra o livro Romanos no topo, e não apenas
/// versículos de João/Atos que citam "romanos".
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
  late final ReferenceParser _parser = ReferenceParser(widget.livros);

  StreamSubscription<SearchHit>? _sub;
  final List<SearchHit> _resultados = [];
  List<BibleBookMeta> _livrosEncontrados = const [];
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

  /// Em tempo real, a cada tecla: sugere LIVROS e resolve REFERÊNCIA. As duas
  /// operações são em memória (66 livros) — não tocam nos arquivos dos livros.
  void _aoDigitar(String termo) {
    final t = termo.trim();
    setState(() {
      _livrosEncontrados = _parser.buscarLivros(t);
      _refDireta = _parser.resolve(t);
      _buscou = t.isNotEmpty;
      if (t.isEmpty) {
        _resultados.clear();
        _buscando = false;
      }
    });
    if (t.isEmpty) _sub?.cancel();
  }

  /// Busca por CONTEÚDO (varre os versículos) — só ao confirmar, por ser a
  /// operação cara.
  Future<void> _buscar() async {
    final termo = _controller.text.trim();
    await _sub?.cancel();
    setState(() {
      _resultados.clear();
      _livrosEncontrados = _parser.buscarLivros(termo);
      _refDireta = _parser.resolve(termo);
      _buscando = termo.isNotEmpty;
      _buscou = true;
    });
    if (termo.isEmpty) return;

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

  void _abrirLeitura(VerseRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LeituraScreen(
          repository: widget.repository,
          store: widget.store,
          livros: widget.livros,
          bookId: ref.bookId,
          capitulo: ref.capitulo,
          versiculoInicial: ref.versiculo,
        ),
      ),
    );
  }

  void _abrirLivro(BibleBookMeta livro) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CapitulosScreen(
          repository: widget.repository,
          store: widget.store,
          livros: widget.livros,
          livro: livro,
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
                    onChanged: _aoDigitar,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Livro, referência ou palavra',
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
    if (!_buscou) return _dica(textTheme, scheme);

    final temRef = _refDireta != null;
    final total =
        _resultados.length + _livrosEncontrados.length + (temRef ? 1 : 0);
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
        // 1) Referência exata — a intenção mais específica.
        if (temRef) _refCard(_refDireta!, textTheme, scheme),
        // 2) LIVROS — prioridade sobre as ocorrências textuais.
        if (_livrosEncontrados.isNotEmpty) ...[
          _secao('Livros', textTheme, scheme),
          for (final l in _livrosEncontrados) _livroTile(l, textTheme, scheme),
        ],
        // 3) VERSÍCULOS — busca por conteúdo.
        if (_resultados.isNotEmpty)
          _secao(
            'Versículos${_buscando ? '…' : ' (${_resultados.length})'}',
            textTheme,
            scheme,
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

  Widget _secao(String texto, TextTheme textTheme, ColorScheme scheme) =>
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6, left: 4),
        child: Text(
          texto.toUpperCase(),
          style: textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _livroTile(
      BibleBookMeta livro, TextTheme textTheme, ColorScheme scheme,) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
        title: Text(
          livro.nome,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${livro.totalCapitulos} capítulos'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _abrirLivro(livro),
      ),
    );
  }

  Widget _refCard(VerseRef ref, TextTheme textTheme, ColorScheme scheme) {
    final rotulo = ref.versiculo == null
        ? '${_nomeLivro(ref.bookId)} ${ref.capitulo}'
        : '${_nomeLivro(ref.bookId)} ${ref.capitulo}:${ref.versiculo}';
    return Card(
      color: scheme.primaryContainer,
      child: ListTile(
        leading:
            Icon(Icons.menu_book_outlined, color: scheme.onPrimaryContainer),
        title: Text('Ir para $rotulo',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),),
        trailing: Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
        onTap: () => _abrirLeitura(ref),
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
        onTap: () => _abrirLeitura(h.ref),
      ),
    );
  }

  Widget _dica(TextTheme textTheme, ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          'Digite o nome de um livro (ex.: "Romanos"), uma referência '
          '("João 3:16") ou uma palavra para encontrar versículos.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
