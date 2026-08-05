import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/reading_store.dart';
import 'compartilhar_screen.dart';

/// Leitor de capítulo — texto REAL (Almeida 1911), scroll contínuo, fonte, tema
/// do leitor, ações no versículo (favoritar, marca-texto, anotação,
/// compartilhar), Modo púlpito (fonte ampliada, sem AppBar) e Modo culto (tela
/// sempre ligada). Registra "continue lendo" e histórico.
class LeituraScreen extends StatefulWidget {
  final BibleRepository repository;
  final ReadingStore store;
  final List<BibleBookMeta> livros;
  final String bookId;
  final int capitulo;

  const LeituraScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.livros,
    required this.bookId,
    required this.capitulo,
  });

  @override
  State<LeituraScreen> createState() => _LeituraScreenState();
}

class _LeituraScreenState extends State<LeituraScreen> {
  final _scroll = ScrollController();
  final List<BibleChapter> _carregados = [];
  late final Map<String, BibleBookMeta> _metaById = {
    for (final b in widget.livros) b.id: b,
  };
  late final Set<String> _favs = widget.store.favoritos().toSet();
  late Map<String, String> _marcas = widget.store.marcas();

  // Chaves dos versículos do capítulo inicial — usadas por "Ir para versículo"
  // para rolar direto até o número escolhido (ex.: 30) sem precisar procurar.
  final Map<int, GlobalKey> _keysVersiculo = {};
  GlobalKey _keyVersiculo(int numero) =>
      _keysVersiculo.putIfAbsent(numero, GlobalKey.new);

  bool _carregando = true;
  bool _carregandoMais = false;
  bool _fim = false;
  bool _erro = false;

  double _fonte = 19;
  bool _leitorClaro = false;
  bool _pulpito = false;
  bool _culto = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_aoRolar);
    _carregarInicial();
  }

  @override
  void dispose() {
    _scroll.dispose();
    if (_culto) _setWakelock(false);
    super.dispose();
  }

  Future<void> _setWakelock(bool on) async {
    try {
      on ? await WakelockPlus.enable() : await WakelockPlus.disable();
    } catch (_) {/* plataforma sem suporte / testes */}
  }

  Future<void> _registrar(BibleChapter cap) async {
    await widget.store.salvarUltimaLeitura(cap.bookId, cap.numero);
    await widget.store.registrarHistorico(cap.bookId, cap.numero);
  }

  Future<void> _carregarInicial() async {
    try {
      final cap =
          await widget.repository.capitulo(widget.bookId, widget.capitulo);
      if (!mounted) return;
      setState(() {
        _carregados.add(cap);
        _carregando = false;
      });
      await _registrar(cap);
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    }
  }

  void _aoRolar() {
    if (_carregandoMais || _fim) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 600) {
      _carregarProximo();
    }
  }

  ({String bookId, int capitulo})? _proximo() {
    final ultimo = _carregados.last;
    final meta = _metaById[ultimo.bookId]!;
    if (ultimo.numero < meta.totalCapitulos) {
      return (bookId: ultimo.bookId, capitulo: ultimo.numero + 1);
    }
    final proximos =
        widget.livros.where((b) => b.ordem == meta.ordem + 1).toList();
    if (proximos.isEmpty) return null;
    return (bookId: proximos.first.id, capitulo: 1);
  }

  Future<void> _carregarProximo() async {
    final prox = _proximo();
    if (prox == null) {
      setState(() => _fim = true);
      return;
    }
    setState(() => _carregandoMais = true);
    try {
      final cap = await widget.repository.capitulo(prox.bookId, prox.capitulo);
      if (!mounted) return;
      setState(() {
        _carregados.add(cap);
        _carregandoMais = false;
      });
      await _registrar(cap);
    } catch (_) {
      if (mounted) setState(() => _carregandoMais = false);
    }
  }

  void _mudarFonte(double delta) =>
      setState(() => _fonte = (_fonte + delta).clamp(15, 40));

  void _toggleCulto() {
    setState(() => _culto = !_culto);
    _setWakelock(_culto);
  }

  static Color? _corMarca(String? nome) => switch (nome) {
        'amarelo' => const Color(0x55FFEB3B),
        'verde' => const Color(0x554CAF50),
        'azul' => const Color(0x552196F3),
        'rosa' => const Color(0x55E91E63),
        _ => null,
      };

  /// Abre a grade de "quadradinhos" com os números dos versículos do capítulo
  /// inicial. Tocar em um número rola a leitura direto até ele.
  Future<void> _abrirGradeVersiculos() async {
    if (_carregados.isEmpty) return;
    final total = _carregados.first.versiculos.length;
    final nome = _metaById[widget.bookId]?.nome ?? widget.bookId;
    final escolhido = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        final textTheme = Theme.of(sheetCtx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Ir para o versículo · $nome ${widget.capitulo}',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: total,
                    itemBuilder: (_, i) {
                      final numero = i + 1;
                      return Material(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.of(sheetCtx).pop(numero),
                          child: Center(
                            child: Text(
                              '$numero',
                              style: textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (escolhido != null) await _irParaVersiculo(escolhido);
  }

  /// Rola a leitura até deixar o versículo [numero] visível no topo. Como a
  /// lista é preguiçosa, volta ao início do capítulo e desce em passos até o
  /// item existir, então garante que ele fique visível.
  Future<void> _irParaVersiculo(int numero) async {
    Future<bool> garantirVisivel() async {
      final ctx = _keysVersiculo[numero]?.currentContext;
      if (ctx == null) return false;
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.08,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return true;
    }

    if (await garantirVisivel()) return;
    if (!_scroll.hasClients) return;

    // Ainda não construído: o capítulo inicial fica no começo da lista.
    _scroll.jumpTo(0);
    await Future<void>.delayed(const Duration(milliseconds: 16));
    for (var i = 0; i < 60; i++) {
      if (!mounted || !_scroll.hasClients) return;
      if (await garantirVisivel()) return;
      final pos = _scroll.position;
      final destino = (pos.pixels + pos.viewportDimension * 0.85)
          .clamp(0.0, pos.maxScrollExtent);
      if (destino <= pos.pixels) break;
      await _scroll.animateTo(
        destino,
        duration: const Duration(milliseconds: 40),
        curve: Curves.linear,
      );
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
    await garantirVisivel();
  }

  Future<void> _acoesVersiculo(VerseRef ref, String texto) async {
    final nome = _metaById[ref.bookId]?.nome ?? ref.bookId;
    final rotulo = '$nome ${ref.capitulo}:${ref.versiculo}';
    final favorito = _favs.contains(ref.chave);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(rotulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),),
              subtitle:
                  Text(texto, maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Marca-texto:'),
                  const SizedBox(width: 8),
                  for (final c in const ['amarelo', 'verde', 'azul', 'rosa'])
                    _Swatch(
                      cor: _corMarca(c)!,
                      selecionado: _marcas[ref.chave] == c,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        _marcar(ref, c);
                      },
                    ),
                  IconButton(
                    tooltip: 'Remover marca',
                    icon: const Icon(Icons.format_color_reset),
                    onPressed: () {
                      Navigator.of(sheetCtx).pop();
                      _marcar(ref, null);
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(favorito ? Icons.star : Icons.star_border),
              title: Text(favorito ? 'Remover dos favoritos' : 'Favoritar'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _alternarFavorito(ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(widget.store.anotacao(ref.chave) == null
                  ? 'Adicionar anotação'
                  : 'Editar anotação',),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                _anotar(ref, rotulo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.of(sheetCtx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompartilharVersiculoScreen(
                      texto: texto,
                      referencia: rotulo,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _alternarFavorito(VerseRef ref) async {
    final agora = await widget.store.alternarFavorito(ref.chave);
    if (!mounted) return;
    setState(() {
      if (agora) {
        _favs.add(ref.chave);
      } else {
        _favs.remove(ref.chave);
      }
    });
  }

  Future<void> _marcar(VerseRef ref, String? cor) async {
    await widget.store.marcarVersiculo(ref.chave, cor);
    if (mounted) setState(() => _marcas = widget.store.marcas());
  }

  Future<void> _anotar(VerseRef ref, String rotulo) async {
    final ctrl =
        TextEditingController(text: widget.store.anotacao(ref.chave) ?? '');
    final salvar = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text('Anotação — $rotulo'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Escreva sua anotação…',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (salvar ?? false) {
      await widget.store.salvarAnotacao(ref.chave, ctrl.text);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = _leitorClaro ? const Color(0xFFFAF7F0) : const Color(0xFF0E0E0E);
    final fg = _leitorClaro ? const Color(0xFF1A1A1A) : Colors.white;
    final fgSuave = _leitorClaro ? const Color(0xFF6B6B6B) : Colors.white60;

    final metaInicial = _metaById[widget.bookId];
    final titulo = metaInicial == null
        ? 'Bíblia'
        : '${metaInicial.nome} ${widget.capitulo}';

    // Modo púlpito: tela limpa, sem AppBar, fonte ampliada.
    if (_pulpito) {
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Stack(
            children: [
              _corpo(fg, fgSuave, fonte: _fonte + 8, comAcoes: false),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black45,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Sair do modo púlpito',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _pulpito = false),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        title: Text(titulo),
        actions: [
          IconButton(
            tooltip: 'Ir para versículo',
            onPressed: _abrirGradeVersiculos,
            icon: const Icon(Icons.apps),
          ),
          IconButton(
            tooltip: 'Diminuir fonte',
            onPressed: () => _mudarFonte(-2),
            icon: const Icon(Icons.text_decrease),
          ),
          IconButton(
            tooltip: 'Aumentar fonte',
            onPressed: () => _mudarFonte(2),
            icon: const Icon(Icons.text_increase),
          ),
          IconButton(
            tooltip: _leitorClaro ? 'Tema escuro' : 'Tema claro',
            onPressed: () => setState(() => _leitorClaro = !_leitorClaro),
            icon: Icon(_leitorClaro ? Icons.dark_mode : Icons.light_mode),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'pulpito') setState(() => _pulpito = true);
              if (v == 'culto') _toggleCulto();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'pulpito',
                child: ListTile(
                  leading: Icon(Icons.campaign_outlined),
                  title: Text('Modo púlpito'),
                ),
              ),
              CheckedPopupMenuItem(
                value: 'culto',
                checked: _culto,
                child: const Text('Modo culto (tela ligada)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(child: _corpo(fg, fgSuave, fonte: _fonte, comAcoes: true)),
    );
  }

  Widget _corpo(Color fg, Color fgSuave,
      {required double fonte, required bool comAcoes,}) {
    if (_erro) {
      return Center(
        child: Text('Não foi possível abrir a leitura.',
            style: TextStyle(color: fg),),
      );
    }
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    final itens = <_Item>[];
    for (final cap in _carregados) {
      final nome = _metaById[cap.bookId]?.nome ?? cap.bookId;
      itens.add(_Item.cabecalho('$nome ${cap.numero}'));
      for (var i = 0; i < cap.versiculos.length; i++) {
        itens.add(_Item.versiculo(
          VerseRef(cap.bookId, cap.numero, i + 1),
          i + 1,
          cap.versiculos[i],
        ),);
      }
    }
    itens.add(_Item.rodape());

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          itemCount: itens.length,
          itemBuilder: (context, i) =>
              _linha(itens[i], fg, fgSuave, fonte, comAcoes),
        ),
      ),
    );
  }

  Widget _linha(
      _Item item, Color fg, Color fgSuave, double fonte, bool comAcoes,) {
    switch (item.tipo) {
      case _Tipo.cabecalho:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 14),
          child: Text(
            item.titulo!,
            style: TextStyle(
              color: fg,
              fontSize: fonte + 4,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _Tipo.versiculo:
        final ref = item.ref!;
        final favorito = _favs.contains(ref.chave);
        final cor = _corMarca(_marcas[ref.chave]);
        final temNota = widget.store.anotacao(ref.chave) != null;
        final conteudo = Container(
          decoration: cor == null
              ? null
              : BoxDecoration(
                  color: cor, borderRadius: BorderRadius.circular(6),),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: fg, fontSize: fonte, height: 1.6),
              children: [
                TextSpan(
                  text: '${item.numero}  ',
                  style: TextStyle(
                    color: fgSuave,
                    fontSize: fonte * 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: item.texto),
                if (favorito)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.star,
                          size: fonte * 0.8, color: Colors.amber,),
                    ),
                  ),
                if (temNota)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.edit_note,
                          size: fonte * 0.9, color: fgSuave,),
                    ),
                  ),
              ],
            ),
          ),
        );
        // Só o capítulo inicial ganha chave (é o alvo de "Ir para versículo");
        // os demais capítulos repetem a numeração e não precisam de âncora.
        final ehCapituloInicial =
            ref.bookId == widget.bookId && ref.capitulo == widget.capitulo;
        final chave = ehCapituloInicial ? _keyVersiculo(item.numero!) : null;
        if (!comAcoes) return KeyedSubtree(key: chave, child: conteudo);
        return InkWell(
          key: chave,
          onTap: () => _acoesVersiculo(ref, item.texto!),
          child: conteudo,
        );
      case _Tipo.rodape:
        if (_carregandoMais) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_fim) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Fim da Bíblia.',
                  style:
                      TextStyle(color: fgSuave, fontStyle: FontStyle.italic),),
            ),
          );
        }
        return const SizedBox(height: 40);
    }
  }
}

class _Swatch extends StatelessWidget {
  final Color cor;
  final bool selecionado;
  final VoidCallback onTap;
  const _Swatch(
      {required this.cor, required this.selecionado, required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 1),
            shape: BoxShape.circle,
            border: Border.all(
              color: selecionado ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

enum _Tipo { cabecalho, versiculo, rodape }

class _Item {
  final _Tipo tipo;
  final String? titulo;
  final int? numero;
  final String? texto;
  final VerseRef? ref;
  _Item._(this.tipo, {this.titulo, this.numero, this.texto, this.ref});
  factory _Item.cabecalho(String t) => _Item._(_Tipo.cabecalho, titulo: t);
  factory _Item.versiculo(VerseRef ref, int n, String t) =>
      _Item._(_Tipo.versiculo, ref: ref, numero: n, texto: t);
  factory _Item.rodape() => _Item._(_Tipo.rodape);
}
