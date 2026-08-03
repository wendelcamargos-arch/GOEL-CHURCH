import 'package:flutter/material.dart';

import '../../../core/whatsapp/whatsapp_links.dart';

/// Testemunho — formulário visual para o membro compartilhar o que Deus fez.
///
/// APENAS camada de apresentação/experiência: NÃO há envio real, backend nem
/// persistência. Ao "enviar", abre automaticamente o grupo Testemunhos Goel no
/// WhatsApp (via [WhatsAppLinks.testemunhos]) e mostra uma confirmação. Quando
/// existir o slice de dados, basta injetar um callback de envio.
/// Identidade preto e branco, acessível a todas as idades.
class TestemunhoScreen extends StatefulWidget {
  /// Ação de envio (futuro slice de dados). Nulo → apenas experiência visual.
  final Future<void> Function(
    String nome,
    String whatsapp,
    String titulo,
    String texto,
  )? onSubmit;

  const TestemunhoScreen({super.key, this.onSubmit});

  @override
  State<TestemunhoScreen> createState() => _TestemunhoScreenState();
}

class _TestemunhoScreenState extends State<TestemunhoScreen> {
  final _nameCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _tituloCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  bool _tried = false;
  bool _sending = false;
  bool _sent = false;

  bool get _nomeInvalid => _nameCtrl.text.trim().isEmpty;
  bool get _textInvalid => _textCtrl.text.trim().length < 10;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _whatsappCtrl.dispose();
    _tituloCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_nomeInvalid || _textInvalid) return;
    setState(() => _sending = true);
    // Envio real (quando existir) é opcional; a experiência funciona sem ele.
    await widget.onSubmit?.call(
      _nameCtrl.text.trim(),
      _whatsappCtrl.text.trim(),
      _tituloCtrl.text.trim(),
      _textCtrl.text.trim(),
    );
    if (!mounted) return;
    // Abre automaticamente o grupo Testemunhos Goel (placeholder por ora).
    await abrirGrupoWhatsApp(
      context,
      WhatsAppLinks.testemunhos,
      aviso: 'O grupo Testemunhos Goel será disponibilizado em breve.',
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  void _reset() {
    _nameCtrl.clear();
    _whatsappCtrl.clear();
    _tituloCtrl.clear();
    _textCtrl.clear();
    setState(() {
      _tried = false;
      _sent = false;
    });
  }

  Future<void> _entrarNoGrupo() async {
    await abrirGrupoWhatsApp(
      context,
      WhatsAppLinks.testemunhos,
      aviso: 'O grupo Testemunhos Goel será disponibilizado em breve.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Testemunho')),
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.record_voice_over_outlined,
              size: 32, color: scheme.onPrimaryContainer,),
        ),
        const SizedBox(height: 16),
        Text(
          'Compartilhe seu testemunho',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Conte o que Deus fez por você. Sua história pode encorajar alguém.',
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Seu nome',
            border: const OutlineInputBorder(),
            errorText:
                _tried && _nomeInvalid ? 'Informe o seu nome.' : null,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _whatsappCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'WhatsApp',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _tituloCtrl,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textCtrl,
          minLines: 5,
          maxLines: 10,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Seu testemunho',
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            errorText: _tried && _textInvalid
                ? 'Escreva um pouco mais para compartilhar (mín. 10 letras).'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ao enviar, você autoriza a Goel Church a compartilhar seu '
          'testemunho para edificar outras pessoas.',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Enviando…' : 'Enviar Testemunho'),
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
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 52, color: scheme.onPrimaryContainer,),
          ),
          const SizedBox(height: 24),
          Text(
            'Testemunho enviado!',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Obrigado por compartilhar o que Deus fez. Que a sua história '
            'abençoe muitas pessoas.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: _entrarNoGrupo,
            icon: const Icon(Icons.groups_outlined),
            label: const Text('Entrar no Grupo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: scheme.onSurface,
              side: BorderSide(color: scheme.outline),
            ),
            onPressed: _reset,
            child: const Text('Escrever outro'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
