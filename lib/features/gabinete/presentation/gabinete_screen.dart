import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gabinete Pastoral — a pessoa escolhe com quem falar (Pastor ou Pastora) e a
/// mensagem vai DIRETO para o WhatsApp do escolhido, já com nome + telefone +
/// texto, para o pastor(a) retornar o contato.
///
/// Camada de apresentação: os números chegam por parâmetro (placeholders). Não
/// há backend — o encaminhamento é pelo deep link do WhatsApp.
class GabineteScreen extends StatefulWidget {
  /// WhatsApp no formato internacional, só dígitos (ex.: 5599999999999).
  final String whatsappPastor;
  final String whatsappPastora;

  const GabineteScreen({
    super.key,
    this.whatsappPastor = '5562995422169', // Pastor Linniker
    this.whatsappPastora = '5562993095993', // Pastora Wanessa
  });

  @override
  State<GabineteScreen> createState() => _GabineteScreenState();
}

class _GabineteScreenState extends State<GabineteScreen> {
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _msg = TextEditingController();
  int? _destino; // 0 = Pastor Linniker, 1 = Pastora Wanessa
  bool _tried = false;

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _msg.dispose();
    super.dispose();
  }

  bool get _valido =>
      _destino != null &&
      _nome.text.trim().isNotEmpty &&
      _telefone.text.trim().isNotEmpty &&
      _msg.text.trim().length >= 5;

  Future<void> _enviar() async {
    setState(() => _tried = true);
    if (!_valido) return;
    final numero =
        _destino == 0 ? widget.whatsappPastor : widget.whatsappPastora;
    final texto = 'Olá! Meu nome é ${_nome.text.trim()}.\n'
        'Telefone: ${_telefone.text.trim()}.\n\n'
        '${_msg.text.trim()}';
    final uri = Uri.parse('https://wa.me/$numero?text=${Uri.encodeComponent(texto)}');
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
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gabinete Pastoral')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text('Fale com o pastor(a)',
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),),
                const SizedBox(height: 8),
                Text(
                  'Escolha com quem você quer falar. A sua mensagem chega direto '
                  'no WhatsApp, com o seu nome e telefone para o retorno.',
                  style: textTheme.bodyLarge
                      ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
                ),
                const SizedBox(height: 20),
                _PastorCard(
                  nome: 'Pastor Linniker',
                  selecionado: _destino == 0,
                  onTap: () => setState(() => _destino = 0),
                ),
                const SizedBox(height: 12),
                _PastorCard(
                  nome: 'Pastora Wanessa',
                  selecionado: _destino == 1,
                  onTap: () => setState(() => _destino = 1),
                ),
                if (_tried && _destino == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Escolha com quem falar.',
                        style: textTheme.bodySmall?.copyWith(color: scheme.error),),
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
                  controller: _telefone,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) {
                    if (_tried) setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Seu telefone (WhatsApp)',
                    border: const OutlineInputBorder(),
                    errorText: _tried && _telefone.text.trim().isEmpty
                        ? 'Informe o seu telefone.'
                        : null,
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
                    errorText: _tried && _msg.text.trim().length < 5
                        ? 'Escreva a sua mensagem.'
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _enviar,
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Enviar no WhatsApp'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PastorCard extends StatelessWidget {
  final String nome;
  final bool selecionado;
  final VoidCallback onTap;
  const _PastorCard({
    required this.nome,
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
      label: 'Falar com $nome',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selecionado ? scheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: scheme.primaryContainer, shape: BoxShape.circle,),
                child: Icon(Icons.person_outline,
                    size: 26, color: scheme.onPrimaryContainer,),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(nome,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),),
              ),
              Icon(
                selecionado
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selecionado ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
