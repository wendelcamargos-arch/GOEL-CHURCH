import 'package:flutter/material.dart';

import '../../../core/whatsapp/whatsapp_links.dart';

/// Quero ser Servo — inscrição para servir em um ministério.
///
/// APENAS camada de apresentação: sem envio real nem persistência. Ao enviar,
/// abre automaticamente o grupo Quero Ser Servo no WhatsApp (via
/// [WhatsAppLinks.servo]) e mostra confirmação. Injete [onSubmit] quando houver
/// o slice de dados.
class ServoScreen extends StatefulWidget {
  final Future<void> Function(String nome, String contato, List<String> areas)?
      onSubmit;

  const ServoScreen({super.key, this.onSubmit});

  @override
  State<ServoScreen> createState() => _ServoScreenState();
}

class _ServoScreenState extends State<ServoScreen> {
  // Lista sugerida (Sprint 4 — EU-04).
  static const _areas = <String>[
    'Recepção', 'Louvor', 'Infantil', 'Mídia', 'Intercessão',
    'Limpeza', 'Evangelismo', 'Administração', 'Outro',
  ];

  final _nome = TextEditingController();
  final _contato = TextEditingController();
  final _selecionadas = <String>{};
  bool _tried = false;
  bool _sending = false;
  bool _sent = false;

  bool get _invalid =>
      _nome.text.trim().isEmpty ||
      _contato.text.trim().isEmpty ||
      _selecionadas.isEmpty;

  @override
  void dispose() {
    _nome.dispose();
    _contato.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_invalid) return;
    setState(() => _sending = true);
    await widget.onSubmit?.call(
      _nome.text.trim(),
      _contato.text.trim(),
      _selecionadas.toList(),
    );
    if (!mounted) return;
    // Abre automaticamente o grupo Quero Ser Servo (placeholder por ora).
    await abrirGrupoWhatsApp(
      context,
      WhatsAppLinks.servo,
      aviso: 'O grupo Quero Ser Servo será disponibilizado em breve.',
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quero ser Servo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: _sent ? _successView(context) : _formView(context),
          ),
        ),
      ),
    );
  }

  Widget _formView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          width: 64,
          height: 64,
          decoration:
              BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
          child: Icon(Icons.handshake_outlined,
              size: 32, color: scheme.onPrimaryContainer,),
        ),
        const SizedBox(height: 16),
        Text('Quero servir',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),),
        const SizedBox(height: 8),
        Text(
          'Deus te chamou para servir. Escolha as áreas do seu coração e nossa '
          'equipe vai falar com você.',
          style: textTheme.bodyLarge
              ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nome,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Seu nome',
            border: const OutlineInputBorder(),
            errorText: _tried && _nome.text.trim().isEmpty
                ? 'Informe o seu nome.'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _contato,
          keyboardType: TextInputType.phone,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'WhatsApp / contato',
            border: const OutlineInputBorder(),
            errorText: _tried && _contato.text.trim().isEmpty
                ? 'Informe um contato.'
                : null,
          ),
        ),
        const SizedBox(height: 20),
        Text('Áreas de interesse',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),),
        const SizedBox(height: 4),
        if (_tried && _selecionadas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('Escolha ao menos uma área.',
                style: textTheme.bodySmall?.copyWith(color: scheme.error),),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in _areas)
              FilterChip(
                label: Text(a),
                selected: _selecionadas.contains(a),
                onSelected: (v) => setState(() {
                  if (v) {
                    _selecionadas.add(a);
                  } else {
                    _selecionadas.remove(a);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),)
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Enviando…' : 'Enviar inscrição'),
        ),
      ],
    );
  }

  Widget _successView(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
                color: scheme.primaryContainer, shape: BoxShape.circle,),
            child: Icon(Icons.check_rounded,
                size: 52, color: scheme.onPrimaryContainer,),
          ),
          const SizedBox(height: 24),
          Text('Inscrição enviada!',
              textAlign: TextAlign.center,
              style:
                  textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),),
          const SizedBox(height: 8),
          Text(
            'Que alegria pelo seu "sim"! Vamos conhecer o seu perfil e te chamar '
            'para uma conversa. Depois disso, você entra na equipe.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge
                ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
