import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/login_flow.dart';

/// Entrada do app (Slice 03): login por código de acesso (WhatsApp OTP).
///
/// APENAS camada de apresentação/experiência — o fluxo, contratos e a
/// autenticação vivem em [LoginFlow]/domínio e não são alterados aqui.
/// Continuidade visual com a Splash: mesma fachada, overlay e logotipo.
/// Acessibilidade (público de todas as idades): passos curtos, alvos amplos,
/// tipografia grande, foco automático e leitor de tela.
class LoginGate extends StatefulWidget {
  final LoginFlow flow;

  /// Tela para onde seguir após autenticar (Slice 04: cadastro). Nulo em testes.
  final WidgetBuilder? postLoginBuilder;

  const LoginGate({super.key, required this.flow, this.postLoginBuilder});

  @override
  State<LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<LoginGate>
    with SingleTickerProviderStateMixin {
  static const _bgAsset = 'assets/brand/church_facade.jpg';
  static const _logoAsset = 'assets/brand/goel_logo.png';
  static const _otpLength = 6;

  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();

  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  LoginPhase _lastPhase = LoginPhase.phone;
  int _resendIn = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _lastPhase = widget.flow.phase;
    widget.flow.addListener(_onFlowChanged);
  }

  void _onFlowChanged() {
    // Ao entrar na etapa do código: foca o campo e inicia o contador de reenvio.
    if (widget.flow.phase == LoginPhase.otp && _lastPhase != LoginPhase.otp) {
      _otpCtrl.clear();
      _startResendCountdown();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _otpFocus.requestFocus();
      });
    }
    _lastPhase = widget.flow.phase;
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendIn = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn = _resendIn > 0 ? _resendIn - 1 : 0);
      if (_resendIn == 0) t.cancel();
    });
  }

  @override
  void dispose() {
    widget.flow.removeListener(_onFlowChanged);
    _resendTimer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    _entry.dispose();
    super.dispose();
  }

  void _submitPhone(LoginFlow flow) {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;
    flow.submitPhone('+55$digits');
  }

  void _onOtpChanged(LoginFlow flow, String value) {
    setState(() {});
    if (value.length == _otpLength && !flow.loading) {
      flow.submitCode(value); // confirmação automática ao completar 6 dígitos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: widget.flow,
        builder: (context, _) {
          final flow = widget.flow;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Continuidade com a Splash: fachada + overlay + blur.
              Image.asset(
                _bgAsset,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.1),
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF14210F)),
              ),
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: const ColoredBox(color: Color(0xB3000000)), // ~70%
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: _entry,
                  child: LayoutBuilder(
                    builder: (context, c) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24,),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: c.maxHeight),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) => FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.04),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: _stepFor(flow),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stepFor(LoginFlow flow) => switch (flow.phase) {
        LoginPhase.phone => _phoneStep(flow),
        LoginPhase.otp => _otpStep(flow),
        LoginPhase.selectIdentity => _selectStep(flow),
        LoginPhase.authenticated => _authenticatedStep(flow),
      };

  // --- Marca (continuidade visual) -----------------------------------------

  Widget _brandMark() => Semantics(
        label: 'Goel Church',
        image: true,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.85),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              _logoAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black,
                child: Icon(Icons.church_outlined,
                    color: Colors.white, size: 44,),
              ),
            ),
          ),
        ),
      );

  Widget _title(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
        ),
      );

  Widget _subtitle(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 16,
          height: 1.4,
        ),
      );

  Widget _messageBanner(LoginFlow flow) {
    if (flow.message == null) return const SizedBox(height: 8);
    final offline = flow.message!.toLowerCase().contains('conectar');
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(offline ? Icons.wifi_off_rounded : Icons.info_outline,
              color: Colors.white, size: 20,),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              flow.message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle get _primaryStyle =>
      FilledButton.styleFrom(minimumSize: const Size.fromHeight(56));

  // Texto do botão como filho (herda a família de fonte do tema).
  Widget _btnLabel(String t) => Text(
        t,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );

  // --- Passo 1: número ------------------------------------------------------

  Widget _phoneStep(LoginFlow flow) => Column(
        key: const ValueKey('phone'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _brandMark()),
          const SizedBox(height: 28),
          _title('Entrar'),
          const SizedBox(height: 10),
          _subtitle('Informe seu número para receber um código de acesso.'),
          const SizedBox(height: 28),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !flow.loading,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: _fieldDecoration(
              label: 'Número',
              hint: '(11) 9 9999-9999',
              prefix: '+55 ',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: _primaryStyle,
            onPressed: flow.loading ? null : () => _submitPhone(flow),
            child: flow.loading
                ? const _BtnSpinner()
                : _btnLabel('Receber código'),
          ),
          _messageBanner(flow),
        ],
      );

  // --- Passo 2: código (6 caixas, controlador único) ------------------------

  Widget _otpStep(LoginFlow flow) => Column(
        key: const ValueKey('otp'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _brandMark()),
          const SizedBox(height: 28),
          _title('Digite o código'),
          const SizedBox(height: 10),
          _subtitle('Enviamos um código de 6 dígitos para\n'
              '+55 ${_phoneCtrl.text}.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: flow.loading
                ? null
                : () {
                    _otpCtrl.clear();
                    flow.submitPhone(''); // volta ao passo do número
                  },
            child: const Text('Trocar número',
                style: TextStyle(color: Colors.white),),
          ),
          const SizedBox(height: 12),
          _OtpBoxes(
            controller: _otpCtrl,
            focusNode: _otpFocus,
            length: _otpLength,
            enabled: !flow.loading,
            onChanged: (v) => _onOtpChanged(flow, v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: _primaryStyle,
            onPressed: (flow.loading || _otpCtrl.text.length < _otpLength)
                ? null
                : () => flow.submitCode(_otpCtrl.text),
            child:
                flow.loading ? const _BtnSpinner() : _btnLabel('Confirmar'),
          ),
          const SizedBox(height: 12),
          Center(
            child: _resendIn > 0
                ? Text(
                    'Reenviar código em 00:${_resendIn.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),),
                  )
                : TextButton(
                    onPressed: flow.loading
                        ? null
                        : () {
                            _startResendCountdown();
                            _submitPhone(flow);
                          },
                    child: const Text('Reenviar código',
                        style: TextStyle(color: Colors.white),),
                  ),
          ),
          _messageBanner(flow),
        ],
      );

  // --- Passo 3: escolher identidade (WhatsApp compartilhado) ----------------

  Widget _selectStep(LoginFlow flow) => Column(
        key: const ValueKey('select'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _brandMark()),
          const SizedBox(height: 28),
          _title('Escolha a sua conta'),
          const SizedBox(height: 10),
          _subtitle('Este número tem mais de uma conta.'),
          const SizedBox(height: 24),
          for (final id in flow.selectable)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 6,),
                  title: Text(id.displayName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,),),
                  // Cargo/função não faz parte do contrato de domínio atual;
                  // exibimos apenas o nome (pronto para subtítulo se o domínio
                  // passar a fornecer função no futuro).
                  trailing:
                      const Icon(Icons.chevron_right, color: Colors.white),
                  onTap: flow.loading
                      ? null
                      : () => flow.chooseIdentity(id.canonicalId),
                ),
              ),
            ),
          _messageBanner(flow),
        ],
      );

  // --- Sucesso --------------------------------------------------------------

  Widget _authenticatedStep(LoginFlow flow) => Column(
        key: const ValueKey('ok'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 72),
          const SizedBox(height: 20),
          _title('Tudo certo!'),
          const SizedBox(height: 10),
          _subtitle('Você entrou na Goel Church.'),
          const SizedBox(height: 28),
          if (widget.postLoginBuilder != null)
            FilledButton(
              style: _primaryStyle,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: widget.postLoginBuilder!),
              ),
              child: _btnLabel('Continuar'),
            ),
        ],
      );

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
    String? prefix,
  }) {
    const white70 = Color(0xB3FFFFFF);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      prefixStyle: const TextStyle(color: Colors.white, fontSize: 20),
      labelStyle: const TextStyle(color: white70),
      hintStyle: const TextStyle(color: white70),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }
}

/// Spinner branco compacto para dentro dos botões primários.
class _BtnSpinner extends StatelessWidget {
  const _BtnSpinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
}

/// Seis caixas visuais para o OTP com UM único controlador interno.
///
/// Um campo real (transparente) captura a digitação; as caixas apenas refletem
/// o texto. O foco "avança" visualmente conforme os dígitos entram, e a
/// confirmação automática é disparada pelo callback do controlador ([onChanged]).
class _OtpBoxes extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    return Semantics(
      label: 'Código de $length dígitos',
      textField: true,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Campo real (funcional, praticamente invisível) por baixo.
          Positioned.fill(
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: enabled,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                onChanged: onChanged,
              ),
            ),
          ),
          // Caixas visíveis; o toque passa pelo IgnorePointer para o campo real.
          IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _box(
                      digit: i < text.length ? text[i] : '',
                      active: i == text.length,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required String digit, required bool active}) => Container(
        width: 46,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                active ? Colors.white : Colors.white.withValues(alpha: 0.45),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
