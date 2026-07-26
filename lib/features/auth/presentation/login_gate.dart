import 'package:flutter/material.dart';

import '../application/login_flow.dart';

/// Entrada do app no Slice 03: conduz o login por WhatsApp OTP.
///
/// Após autenticar, exibe um placeholder NEUTRO (não é a Home — Slice 05).
/// Acessibilidade (público idoso): textos amplos, botões altos, passos curtos.
class LoginGate extends StatefulWidget {
  final LoginFlow flow;

  /// Tela para onde seguir após autenticar (Slice 04: cadastro). Nulo em testes.
  final WidgetBuilder? postLoginBuilder;

  const LoginGate({super.key, required this.flow, this.postLoginBuilder});

  @override
  State<LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<LoginGate> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.flow,
      builder: (context, _) {
        final flow = widget.flow;
        return Scaffold(
          appBar: AppBar(title: const Text('Goel Church')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: switch (flow.phase) {
                LoginPhase.phone => _phoneStep(flow),
                LoginPhase.otp => _otpStep(flow),
                LoginPhase.selectIdentity => _selectStep(flow),
                LoginPhase.authenticated => _authenticated(flow),
              },
            ),
          ),
        );
      },
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(t, style: Theme.of(context).textTheme.headlineSmall),
      );

  Widget _message(LoginFlow flow) => flow.message == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(flow.message!, style: Theme.of(context).textTheme.bodyLarge),
        );

  Widget _phoneStep(LoginFlow flow) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Entrar com o WhatsApp'),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Seu número de WhatsApp',
              hintText: '+55 11 99999-9999',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: flow.loading
                ? null
                : () => flow.submitPhone(_phoneCtrl.text),
            child: flow.loading
                ? const CircularProgressIndicator()
                : const Text('Enviar código'),
          ),
          _message(flow),
        ],
      );

  Widget _otpStep(LoginFlow flow) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Digite o código'),
          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Código recebido'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed:
                flow.loading ? null : () => flow.submitCode(_codeCtrl.text),
            child: flow.loading
                ? const CircularProgressIndicator()
                : const Text('Confirmar'),
          ),
          _message(flow),
        ],
      );

  Widget _selectStep(LoginFlow flow) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title('Escolha a sua conta'),
          for (final id in flow.selectable)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: flow.loading
                    ? null
                    : () => flow.chooseIdentity(id.canonicalId),
                child: Text(id.displayName),
              ),
            ),
          _message(flow),
        ],
      );

  Widget _authenticated(LoginFlow flow) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 64),
            const SizedBox(height: 16),
            Text(
              'Você entrou na Goel Church.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            if (widget.postLoginBuilder != null)
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: widget.postLoginBuilder!),
                ),
                child: const Text('Continuar para o cadastro'),
              )
            else
              Text(
                'Slice 03 concluído.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
      );
}
