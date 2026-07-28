import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goel_domain/goel_domain.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela do Versículo do dia (Slice 06) — redesign visual (preto e branco).
///
/// APENAS camada de apresentação: o contrato é preservado
/// (`VersiculoScreen(repository:, sourceLabel:)`). Leitura para todas as idades:
/// texto amplo, centrado, entrelinhas confortáveis e alto contraste. Traz a
/// data de hoje e as ações de compartilhar (no grupo) e copiar.
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
                child: Text(
                  'Não foi possível carregar agora.',
                  style: textTheme.titleMedium,
                ),
              );
            }
            return _VerseView(verse: snapshot.data!, sourceLabel: sourceLabel);
          },
        ),
      ),
    );
  }
}

class _VerseView extends StatelessWidget {
  final DailyVerse verse;
  final String? sourceLabel;

  const _VerseView({required this.verse, this.sourceLabel});

  /// Texto pronto para compartilhar/copiar.
  String get _compartilhavel =>
      '"${verse.text}"\n\n— ${verse.reference}\n\nGoel Church · Versículo do dia';

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
              _DataDeHoje(dia: DateTime.now()),
              const SizedBox(height: 24),
              Icon(
                Icons.format_quote,
                size: 56,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              _ReferencePill(reference: verse.reference),
              if (sourceLabel != null) ...[
                const SizedBox(height: 16),
                Text(
                  sourceLabel!,
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              // Ações em largura cheia (padrão de CTA do app), empilhadas para
              // caber com folga em qualquer largura de tela.
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _compartilhar(context),
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Compartilhar'),
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
        content: Text('Versículo copiado.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),);
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
