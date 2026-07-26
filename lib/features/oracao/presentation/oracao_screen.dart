import 'package:flutter/material.dart';

/// Oração — formulário visual para o membro enviar um pedido de oração.
///
/// APENAS camada de apresentação/experiência: NÃO há envio real, backend nem
/// persistência. Ao "enviar", mostra uma confirmação acolhedora. Quando existir
/// o slice de dados, injete o callback [onSubmit] — a tela já está pronta.
/// Identidade preto e branco, acessível a todas as idades.
class OracaoScreen extends StatefulWidget {
  /// Ação de envio (futuro slice de dados). Nulo → apenas experiência visual.
  /// Recebe (nome, pedido, sigilo).
  final Future<void> Function(String nome, String pedido, bool sigilo)? onSubmit;

  const OracaoScreen({super.key, this.onSubmit});

  @override
  State<OracaoScreen> createState() => _OracaoScreenState();
}

class _OracaoScreenState extends State<OracaoScreen> {
  final _nameCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  bool _sigilo = true;
  bool _tried = false;
  bool _sending = false;
  bool _sent = false;

  bool get _textInvalid => _textCtrl.text.trim().length < 3;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _tried = true);
    if (_textInvalid) return;
    setState(() => _sending = true);
    await widget.onSubmit
        ?.call(_nameCtrl.text.trim(), _textCtrl.text.trim(), _sigilo);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
    });
  }

  void _reset() {
    _nameCtrl.clear();
    _textCtrl.clear();
    setState(() {
      _sigilo = true;
      _tried = false;
      _sent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oração')),
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
          child: Icon(Icons.volunteer_activism_outlined,
              size: 32, color: scheme.onPrimaryContainer,),
        ),
        const SizedBox(height: 16),
        Text(
          'Peça uma oração',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Estamos com você. Compartilhe seu pedido e a nossa equipe vai '
          'orar por você.',
          style: textTheme.bodyLarge?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Seu nome (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _textCtrl,
          minLines: 4,
          maxLines: 10,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {
            if (_tried) setState(() {});
          },
          decoration: InputDecoration(
            labelText: 'Seu pedido de oração',
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
            errorText:
                _tried && _textInvalid ? 'Escreva o seu pedido.' : null,
          ),
        ),
        const SizedBox(height: 8),
        _SigiloTile(
          value: _sigilo,
          onChanged: (v) => setState(() => _sigilo = v),
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
          label: Text(_sending ? 'Enviando…' : 'Enviar pedido'),
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
            'Recebemos o seu pedido',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'A nossa equipe vai orar por você. Você não está sozinho(a).',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _reset,
            child: const Text('Fazer outro pedido'),
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

/// Alternância "manter em sigilo" — apenas a equipe de oração vê o pedido.
class _SigiloTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SigiloTile({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Switch(value: value, onChanged: onChanged),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Manter em sigilo (apenas a equipe de oração verá).',
                style: textTheme.bodyMedium
                    ?.copyWith(color: scheme.onSurface, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
