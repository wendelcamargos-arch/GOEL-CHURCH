import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gabinete Pastoral — falar com o pastor (agendar conversa / aconselhamento).
///
/// APENAS camada de apresentação: sem envio real nem persistência. Ao enviar,
/// mostra confirmação. Há também um atalho para falar direto no WhatsApp
/// (número por parâmetro — placeholder). Injete [onSubmit]/[whatsapp] reais
/// quando houver o slice de dados.
class GabineteScreen extends StatefulWidget {
  final Future<void> Function(String nome, String assunto, String mensagem)?
      onSubmit;

  /// Número do gabinete/secretaria no formato internacional (só dígitos).
  final String whatsapp;

  const GabineteScreen({super.key, this.onSubmit, this.whatsapp = '5500000000000'});

  @override
  State<GabineteScreen> createState() => _GabineteScreenState();
}

class _GabineteScreenState extends State<GabineteScreen> {
  final _nome = TextEditingController();
  final _assunto = TextEditingController();
  final _msg = TextEditingController();
  bool _tried = false;
  bool _sending = false;
  bool _sent = false;

  bool get _invalid => _msg.text.trim().length < 5;

  @override
  void dispose() {
    _nome.dispose();
    _assunto.dispose();
    _msg.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_invalid) return;
    setState(() => _sending = true);
    await widget.onSubmit
        ?.call(_nome.text.trim(), _assunto.text.trim(), _msg.text.trim());
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  Future<void> _whatsapp() async {
    final uri = Uri.parse('https://wa.me/${widget.whatsapp}');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('falha');
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gabinete Pastoral')),
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
          child: Icon(Icons.support_agent,
              size: 32, color: scheme.onPrimaryContainer,),
        ),
        const SizedBox(height: 16),
        Text('Fale com o pastor',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),),
        const SizedBox(height: 8),
        Text(
          'Precisa conversar, aconselhar-se ou agendar um horário? Envie sua '
          'mensagem — o gabinete vai te retornar.',
          style: textTheme.bodyLarge
              ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nome,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Seu nome (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _assunto,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Assunto (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _msg,
          minLines: 4,
          maxLines: 8,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Sua mensagem',
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            errorText: _tried && _invalid ? 'Escreva a sua mensagem.' : null,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),)
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Enviando…' : 'Enviar mensagem'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _whatsapp,
          icon: const Icon(Icons.chat_outlined),
          label: const Text('Falar no WhatsApp'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
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
          Text('Mensagem enviada!',
              textAlign: TextAlign.center,
              style:
                  textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),),
          const SizedBox(height: 8),
          Text(
            'O gabinete pastoral vai te responder em breve. Deus abençoe.',
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
