import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/verse_voice.dart';
import '../data/verse_voice_factory.dart';

/// Frase-gatilho para multiplicar a Palavra — aparece ao tocar em
/// "Compartilhar" (e também ao final de cada áudio ouvido).
const String kGatilhoCompartilhar =
    'Compartilhe essa palavra poderosa para mais 7 pessoas serem abençoadas.';

/// Tela do Versículo do dia (Slice 06) — redesign visual (preto e branco).
///
/// APENAS camada de apresentação: o contrato é preservado
/// (`VersiculoScreen(repository:, sourceLabel:)`). Traz a logo da Goel e o áudio
/// da Palavra usando a VOZ DO PRÓPRIO APARELHO (Text-to-Speech nativo — grátis,
/// offline, em português) e, ao final da leitura, o gatilho de compartilhamento.
class VersiculoScreen extends StatelessWidget {
  final VerseRepository repository;

  /// Rótulo opcional de fonte/atribuição (ex.: "Almeida — domínio público").
  final String? sourceLabel;

  /// Preview: inicia já no estado "áudio concluído" para exibir o gatilho.
  final bool debugStartCompleted;

  const VersiculoScreen({
    super.key,
    required this.repository,
    this.sourceLabel,
    this.debugStartCompleted = false,
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
            return _VerseView(
              verse: snapshot.data!,
              sourceLabel: sourceLabel,
              debugStartCompleted: debugStartCompleted,
            );
          },
        ),
      ),
    );
  }
}

enum _AudioEstado { parado, carregando, tocando, concluido }

class _VerseView extends StatefulWidget {
  final DailyVerse verse;
  final String? sourceLabel;
  final bool debugStartCompleted;

  const _VerseView({
    required this.verse,
    required this.debugStartCompleted,
    this.sourceLabel,
  });

  @override
  State<_VerseView> createState() => _VerseViewState();
}

class _VerseViewState extends State<_VerseView> {
  // Voz da Palavra: por padrão a voz GRÁTIS do aparelho; se houver chave da
  // ElevenLabs configurada, a fábrica devolve a voz premium. A tela não muda.
  late final VerseVoice _voice;
  _AudioEstado _estado = _AudioEstado.parado;

  /// Texto pronto para compartilhar/copiar (com o gatilho ao final).
  String get _compartilhavel =>
      '"${widget.verse.text}"\n\n— ${widget.verse.reference}\n\n'
      '$kGatilhoCompartilhar\n\nGoel Church · Palavra do dia';

  @override
  void initState() {
    super.initState();
    _voice = createVerseVoice();
    _voice.onComplete = () {
      if (!mounted) return;
      setState(() => _estado = _AudioEstado.concluido);
      // Ao final da leitura, o gatilho de compartilhamento aparece.
      _abrirCompartilhar(context);
    };
    _voice.onCancel = () {
      if (mounted) setState(() => _estado = _AudioEstado.parado);
    };
    if (widget.debugStartCompleted) {
      _estado = _AudioEstado.concluido;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _abrirCompartilhar(context);
      });
    }
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _ouvir() async {
    if (_estado == _AudioEstado.tocando) {
      await _voice.stop();
      if (mounted) setState(() => _estado = _AudioEstado.parado);
      return;
    }
    setState(() => _estado = _AudioEstado.tocando);
    final texto = '${widget.verse.text}. ${widget.verse.reference}.';
    try {
      await _voice.speak(texto);
    } catch (_) {
      if (!mounted) return;
      setState(() => _estado = _AudioEstado.parado);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível ler a Palavra agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }

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
              Image.asset(
                'assets/brand/goel_logo.png',
                height: 56,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              _DataDeHoje(dia: DateTime.now()),
              const SizedBox(height: 22),
              Icon(Icons.format_quote, size: 48, color: scheme.onSurfaceVariant),
              const SizedBox(height: 10),
              Text(
                widget.verse.text,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              _ReferencePill(reference: widget.verse.reference),
              if (widget.sourceLabel != null) ...[
                const SizedBox(height: 14),
                Text(
                  widget.sourceLabel!,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 28),
              _BotaoOuvir(estado: _estado, onTap: _ouvir),
              const SizedBox(height: 24),
              // Na tela, apenas o botão de compartilhar. A frase-gatilho aparece
              // ao tocar nele (na folha de compartilhamento).
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _abrirCompartilhar(context),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartilhar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ao tocar em "Compartilhar", mostra a frase-gatilho e a ação de enviar.
  void _abrirCompartilhar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _CompartilharSheet(
        onEnviar: () {
          Navigator.of(sheetContext).pop();
          _compartilhar(context);
        },
        onCopiar: () {
          Navigator.of(sheetContext).pop();
          _copiar(context);
        },
      ),
    );
  }

  Future<void> _compartilhar(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(_compartilhavel)}',
    );
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('falha');
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o compartilhamento agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }

  void _copiar(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _compartilhavel));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Palavra copiada.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),);
  }
}

/// Botão redondo grande para ouvir a narração da Palavra.
class _BotaoOuvir extends StatelessWidget {
  final _AudioEstado estado;
  final VoidCallback onTap;
  const _BotaoOuvir({required this.estado, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icone, String rotulo) = switch (estado) {
      _AudioEstado.tocando => (Icons.pause_rounded, 'Tocando…'),
      _AudioEstado.carregando => (Icons.hourglass_top_rounded, 'Preparando…'),
      _AudioEstado.concluido => (Icons.replay_rounded, 'Ouvir de novo'),
      _AudioEstado.parado => (Icons.play_arrow_rounded, 'Ouvir a Palavra'),
    };

    return Column(
      children: [
        Semantics(
          button: true,
          label: rotulo,
          child: InkWell(
            onTap: estado == _AudioEstado.carregando ? null : onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
              ),
              child: estado == _AudioEstado.carregando
                  ? Padding(
                      padding: const EdgeInsets.all(26),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Icon(icone, size: 44, color: scheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          rotulo,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Folha aberta ao tocar em "Compartilhar": mostra a frase-gatilho e envia.
class _CompartilharSheet extends StatelessWidget {
  final VoidCallback onEnviar;
  final VoidCallback onCopiar;
  const _CompartilharSheet({required this.onEnviar, required this.onCopiar});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.volunteer_activism_outlined,
                size: 34, color: scheme.onSurface,),
            const SizedBox(height: 16),
            Text(
              kGatilhoCompartilhar,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEnviar,
                icon: const Icon(Icons.share_outlined),
                label: const Text('Compartilhar no WhatsApp'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: scheme.outline),
                ),
                onPressed: onCopiar,
                icon: const Icon(Icons.copy_outlined),
                label: const Text('Copiar texto'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Hoje · 28 de julho de 2026" — data por extenso, sem depender de intl.
class _DataDeHoje extends StatelessWidget {
  final DateTime dia;
  const _DataDeHoje({required this.dia});

  static const _meses = <String>[
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final texto = 'Hoje · ${dia.day} de ${_meses[dia.month - 1]} de ${dia.year}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.today_outlined, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            texto,
            style: textTheme.labelLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
