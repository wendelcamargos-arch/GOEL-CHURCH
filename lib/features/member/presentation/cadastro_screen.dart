import 'package:flutter/material.dart';

import '../application/cadastro_flow.dart';

/// Tela de cadastro do membro (Slice 04). Acessível ao público idoso.
///
/// A data de nascimento é apresentada como dado de perfil que habilita a
/// mensagem AUTOMÁTICA de aniversário no WhatsApp — nunca como senha/login.
class CadastroScreen extends StatefulWidget {
  final CadastroFlow flow;

  /// Tela para onde seguir após concluir o cadastro (Slice 05: Home).
  final WidgetBuilder? postCadastroBuilder;

  const CadastroScreen({
    super.key,
    required this.flow,
    this.postCadastroBuilder,
  });

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _nameCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _optIn = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 40),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
      helpText: 'Sua data de nascimento',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.flow,
      builder: (context, _) {
        final flow = widget.flow;
        return Scaffold(
          appBar: AppBar(title: const Text('Seu cadastro')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: flow.done ? _done() : _form(flow),
            ),
          ),
        );
      },
    );
  }

  Widget _form(CadastroFlow flow) => ListView(
        children: [
          Text('Complete seu cadastro',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Seu nome completo'),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.cake_outlined),
            label: Text(
              _birthDate == null
                  ? 'Escolher data de nascimento'
                  : 'Nascimento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: _optIn,
            onChanged: (v) => setState(() => _optIn = v),
            title: const Text('Receber mensagens no WhatsApp'),
            subtitle: const Text(
              'Inclui a saudação automática no seu aniversário.',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: flow.loading
                ? null
                : () => flow.submit(
                      fullName: _nameCtrl.text,
                      birthDate: _birthDate,
                      whatsappOptIn: _optIn,
                    ),
            child: flow.loading
                ? const CircularProgressIndicator()
                : const Text('Salvar'),
          ),
          if (flow.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(flow.message!,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
        ],
      );

  Widget _done() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64),
            const SizedBox(height: 16),
            Text('Cadastro concluído!',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            if (widget.postCadastroBuilder != null)
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: widget.postCadastroBuilder!),
                ),
                child: const Text('Ir para o início'),
              ),
          ],
        ),
      );
}
