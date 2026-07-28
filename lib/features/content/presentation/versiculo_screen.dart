import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/verse_audio_source.dart';

/// Frase-gatilho para multiplicar a Palavra — aparece para quem ouve (ao final
/// do áudio) e também para quem prefere ler (sempre disponível).
const String kGatilhoCompartilhar =
    'Envie essa mensagem poderosa para 7 pessoas que serão abençoadas.';

/// Tela do Versículo do dia (Slice 06) — redesign visual (preto e branco).
///
/// APENAS camada de apresentação: o contrato é preservado
/// (`VersiculoScreen(repository:, sourceLabel:)`, agora com `audioSource`
/// opcional). Traz a logo da Goel, o áudio da Palavra (voz ElevenLabs, quando
/// configurada) e, ao final da reprodução, o gatilho de compartilhamento.
class VersiculoScreen extends StatelessWidget {
  final VerseRepository repository;

  /// Rótulo opcional de fonte/atribuição (ex.: "Almeida — domínio público").
  final String? sourceLabel;

  /// Fonte do áudio da Palavra (voz ElevenLabs). Sem ela, a tela mostra o
  /// estado honesto "áudio em breve".
  final VerseAudioSource audioSource;

  /// Preview: inicia já no estado "áudio concluído" para exibir o gatilho.
  final bool debugStartCompleted;

  const VersiculoScreen({
    super.key,
    required this.repository,
    this.sourceLabel,
    this.audioSource = const UnavailableVerseAudioSource(),
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
              audioSource: audioSource,
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
  final VerseAudioSource audioSource;
  final bool debugStartCompleted;

  const _VerseView({
    required this.verse,
    required this.audioSource,
    required this.debugStartCompleted,
    this.sourceLabel,
  });

  @override
  State<_VerseView> createState() => _VerseViewState();
}

class _VerseViewState extends State<_VerseView> {
  late final AudioPlayer _player;
  _AudioEstado _estado = _AudioEstado.parado;

  /// Texto pronto para compartilhar/copiar (com o gatilho ao final).
  String get _compartilhavel =>
      '"${widget.verse.text}"\n\n— ${widget.verse.reference}\n\n'
      '$kGatilhoCompartilhar\n\nGoel Church · Palavra do dia';

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _estado = _AudioEstado.concluido);
    });
    if (widget.debugStartCompleted) _estado = _AudioEstado.concluido;
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _ouvir() async {
    if (_estado == _AudioEstado.tocando) {
      await _player.pause();
      setState(() => _estado = _AudioEstado.parado);
      return;
    }
    setState(() => _estado = _AudioEstado.carregando);
    final fonte = await widget.audioSource.audioFor(widget.verse);
    if (!mounted) return;
    if (fonte == null) {
      // Honesto: a voz (ElevenLabs) ainda não foi configurada.
      setState(() => _estado = _AudioEstado.parado);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text(
            'A voz da Palavra (ElevenLabs) entra assim que for configurada.',
          ),
          behavior: SnackBarBehavior.floating,
        ),);
      return;
    }
    try {
      await _player.play(
        fonte.startsWith('http') ? UrlSource(fonte) : AssetSource(fonte),
      );
      if (mounted) setState(() => _estado = _AudioEstado.tocando);
    } catch (_) {
      if (!mounted) return;
      setState(() => _estado = _AudioEstado.parado);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível tocar o áudio agora.'),
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
              // Sempre disponível: quem prefere LER também compartilha a Palavra
              // (e o mesmo card fecha a experiência de quem OUVE, ao final).
              _GatilhoCard(onCompartilhar: () => _compartilhar(context)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: scheme.onSurface,
                    side: BorderSide(color: scheme.outline),
                  ),
                  onPressed: () => _copiar(context),
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar'),
                ),
              ),
            ],
          ),
        ),
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
        const SizedBox(height: 2),
        Text(
          'Voz ElevenLabs · narração acolhedora',
          style: textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Card exibido ao final do áudio: gatilho para compartilhar com 7 pessoas.
class _GatilhoCard extends StatelessWidget {
  final VoidCallback onCompartilhar;
  const _GatilhoCard({required this.onCompartilhar});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_outlined,
              size: 30, color: scheme.onSurface,),
          const SizedBox(height: 12),
          Text(
            kGatilhoCompartilhar,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCompartilhar,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartilhar com 7 pessoas'),
            ),
          ),
        ],
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
