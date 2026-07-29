import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um propósito entregue no Monte (modelo de apresentação — sem domínio).
class Proposito {
  final String titulo;
  final String descricao;
  const Proposito(this.titulo, this.descricao);
}

/// Propósitos no Monte — página da campanha (padrão preto e branco).
///
/// APENAS camada de apresentação: a pessoa ESCOLHE propósitos (e/ou escreve o
/// seu) e "firma" — abrindo o compartilhamento do compromisso. Sem envio nem
/// persistência (isso entra com o slice de dados); a lista de EXEMPLO pode ser
/// substituída pelo Owner.
class PropositosScreen extends StatefulWidget {
  final List<Proposito>? propositos;

  const PropositosScreen({super.key, this.propositos});

  static const _exemplo = <Proposito>[
    Proposito('Jejum e oração',
        'Sete dias buscando a Deus em jejum, com um horário separado para oração.',),
    Proposito('Reconciliação',
        'Restaurar um relacionamento e perdoar de coração.',),
    Proposito('Generosidade',
        'Abençoar uma família em necessidade ao longo do mês.',),
    Proposito('Palavra diária',
        'Ler a Bíblia todos os dias e registrar o que Deus falar.',),
  ];

  @override
  State<PropositosScreen> createState() => _PropositosScreenState();
}

class _PropositosScreenState extends State<PropositosScreen> {
  final Set<int> _selecionados = {};
  final TextEditingController _meu = TextEditingController();

  @override
  void dispose() {
    _meu.dispose();
    super.dispose();
  }

  List<Proposito> get _lista => widget.propositos ?? PropositosScreen._exemplo;

  bool get _temAlgo => _selecionados.isNotEmpty || _meu.text.trim().isNotEmpty;

  String get _compartilhavel {
    final buffer = StringBuffer('Subi ao Monte com propósito:\n');
    for (final i in _selecionados.toList()..sort()) {
      buffer.writeln('• ${_lista[i].titulo}');
    }
    if (_meu.text.trim().isNotEmpty) {
      buffer.writeln('• ${_meu.text.trim()}');
    }
    buffer.write('\nGoel Church');
    return buffer.toString();
  }

  void _firmar() {
    if (!_temAlgo) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Escolha ou escreva o seu propósito.'),
          behavior: SnackBarBehavior.floating,
        ),);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => _FirmadoSheet(
        texto: _compartilhavel,
        onCompartilhar: () {
          Navigator.of(sheetContext).pop();
          _compartilhar();
        },
        onCopiar: () {
          Navigator.of(sheetContext).pop();
          _copiar();
        },
      ),
    );
  }

  Future<void> _compartilhar() async {
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

  void _copiar() {
    Clipboard.setData(ClipboardData(text: _compartilhavel));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Propósito copiado.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propósitos no Monte')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                const _Intro(),
                const SizedBox(height: 12),
                for (var i = 0; i < _lista.length; i++) ...[
                  _PropositoCard(
                    numero: i + 1,
                    proposito: _lista[i],
                    selecionado: _selecionados.contains(i),
                    onTap: () => setState(() {
                      if (!_selecionados.remove(i)) _selecionados.add(i);
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                _MeuProposito(
                  controller: _meu,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _temAlgo ? _firmar : null,
                  icon: const Icon(Icons.flag_outlined),
                  label: const Text('Firmar meu propósito'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.landscape_outlined,
                size: 32, color: scheme.onPrimaryContainer,),
          ),
          const SizedBox(height: 16),
          Text(
            'Suba ao Monte com um alvo no coração. Marque os seus propósitos '
            '(ou escreva o seu) e firme o compromisso — Deus honra quem O busca.',
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropositoCard extends StatelessWidget {
  final int numero;
  final Proposito proposito;
  final bool selecionado;
  final VoidCallback onTap;
  const _PropositoCard({
    required this.numero,
    required this.proposito,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selecionado,
      label: 'Propósito: ${proposito.titulo}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selecionado ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$numero',
                    style: textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposito.titulo,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proposito.descricao,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selecionado
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selecionado ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeuProposito extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _MeuProposito({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      minLines: 2,
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Escreva o seu próprio propósito (opcional)',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Folha de confirmação ao firmar: mostra o compromisso e permite compartilhar.
class _FirmadoSheet extends StatelessWidget {
  final String texto;
  final VoidCallback onCompartilhar;
  final VoidCallback onCopiar;
  const _FirmadoSheet({
    required this.texto,
    required this.onCompartilhar,
    required this.onCopiar,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.flag_rounded, size: 34, color: scheme.onSurface),
            const SizedBox(height: 12),
            Text(
              'Propósito firmado!',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Permaneça firme. Compartilhe e convide alguém a subir com você.',
              textAlign: TextAlign.center,
              style:
                  textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                texto,
                style: textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCompartilhar,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Compartilhar no WhatsApp'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: scheme.onSurface,
                side: BorderSide(color: scheme.outline),
              ),
              onPressed: onCopiar,
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Copiar texto'),
            ),
          ],
        ),
      ),
    );
  }
}
