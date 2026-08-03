import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

/// Leitor de capítulo — texto REAL (Almeida 1911), **scroll contínuo** (anexa o
/// próximo capítulo/livro ao rolar), ajuste de fonte e tema do leitor
/// (claro/escuro apenas aqui). Carrega sob demanda via [BibleRepository].
class LeituraScreen extends StatefulWidget {
  final BibleRepository repository;
  final List<BibleBookMeta> livros;
  final String bookId;
  final int capitulo;

  const LeituraScreen({
    super.key,
    required this.repository,
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

  bool _carregando = true;
  bool _carregandoMais = false;
  bool _fim = false;
  bool _erro = false;

  double _fonte = 19;
  bool _leitorClaro = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_aoRolar);
    _carregarInicial();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _carregarInicial() async {
    try {
      final cap = await widget.repository.capitulo(widget.bookId, widget.capitulo);
      if (!mounted) return;
      setState(() {
        _carregados.add(cap);
        _carregando = false;
      });
    } catch (_) {
      if (mounted) setState(() => _erro = true);
    }
  }

  void _aoRolar() {
    if (_carregandoMais || _fim) return;
    if (_scroll.position.pixels >=
        _scroll.position.maxScrollExtent - 600) {
      _carregarProximo();
    }
  }

  ({String bookId, int capitulo})? _proximo() {
    final ultimo = _carregados.last;
    final meta = _metaById[ultimo.bookId]!;
    if (ultimo.numero < meta.totalCapitulos) {
      return (bookId: ultimo.bookId, capitulo: ultimo.numero + 1);
    }
    // fim do livro → próximo livro (por ordem)
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
    } catch (_) {
      if (mounted) setState(() => _carregandoMais = false);
    }
  }

  void _mudarFonte(double delta) {
    setState(() => _fonte = (_fonte + delta).clamp(15, 32));
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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        title: Text(titulo),
        actions: [
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
        ],
      ),
      body: SafeArea(child: _corpo(fg, fgSuave)),
    );
  }

  Widget _corpo(Color fg, Color fgSuave) {
    if (_erro) {
      return Center(
        child: Text('Não foi possível abrir a leitura.',
            style: TextStyle(color: fg),),
      );
    }
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    // Lista plana: cabeçalho de cada capítulo + seus versículos + rodapé.
    final itens = <_Item>[];
    for (final cap in _carregados) {
      final nome = _metaById[cap.bookId]?.nome ?? cap.bookId;
      itens.add(_Item.cabecalho('$nome ${cap.numero}'));
      for (var i = 0; i < cap.versiculos.length; i++) {
        itens.add(_Item.versiculo(i + 1, cap.versiculos[i]));
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
          itemBuilder: (context, i) => _linha(itens[i], fg, fgSuave),
        ),
      ),
    );
  }

  Widget _linha(_Item item, Color fg, Color fgSuave) {
    switch (item.tipo) {
      case _Tipo.cabecalho:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 14),
          child: Text(
            item.titulo!,
            style: TextStyle(
              color: fg,
              fontSize: _fonte + 4,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      case _Tipo.versiculo:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: fg, fontSize: _fonte, height: 1.6),
              children: [
                TextSpan(
                  text: '${item.numero}  ',
                  style: TextStyle(
                    color: fgSuave,
                    fontSize: _fonte * 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: item.texto),
              ],
            ),
          ),
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
                  style: TextStyle(color: fgSuave, fontStyle: FontStyle.italic),),
            ),
          );
        }
        return const SizedBox(height: 40);
    }
  }
}

enum _Tipo { cabecalho, versiculo, rodape }

class _Item {
  final _Tipo tipo;
  final String? titulo;
  final int? numero;
  final String? texto;
  _Item._(this.tipo, {this.titulo, this.numero, this.texto});
  factory _Item.cabecalho(String t) => _Item._(_Tipo.cabecalho, titulo: t);
  factory _Item.versiculo(int n, String t) =>
      _Item._(_Tipo.versiculo, numero: n, texto: t);
  factory _Item.rodape() => _Item._(_Tipo.rodape);
}
