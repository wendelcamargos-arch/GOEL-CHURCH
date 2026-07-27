import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../application/cadastro_flow.dart';

/// Tela de cadastro do membro (Slice 04). Acessível ao público de todas as
/// idades. Continuidade visual com a Splash/Login (fachada + overlay + logo).
///
/// APENAS camada de apresentação/experiência — regra de negócio e persistência
/// vivem em [CadastroFlow]/domínio. A data de nascimento é DADO DE PERFIL cuja
/// única finalidade é a mensagem AUTOMÁTICA de aniversário (transparência
/// LGPD), nunca senha/login. O consentimento é EXPLÍCITO (começa desmarcado).
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

class _CadastroScreenState extends State<CadastroScreen>
    with SingleTickerProviderStateMixin {
  static const _bgAsset = 'assets/brand/church_facade.jpg';
  static const _logoAsset = 'assets/brand/goel_logo.png';

  final _nameCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _optIn = false; // consentimento explícito (LGPD)
  bool _tried = false;

  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _entry.dispose();
    super.dispose();
  }

  bool get _nameInvalid => _tried && _nameCtrl.text.trim().length < 2;
  bool get _dateInvalid => _tried && _birthDate == null;

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

  void _submit(CadastroFlow flow) {
    setState(() => _tried = true);
    flow.submit(
      fullName: _nameCtrl.text,
      birthDate: _birthDate,
      whatsappOptIn: _optIn,
    );
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
              Image.asset(
                _bgAsset,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.1),
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFF14210F)),
              ),
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: const ColoredBox(color: Color(0xB8000000)), // ~72%
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
                            child: flow.done ? _doneStep() : _formStep(flow),
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

  // --- Formulário -----------------------------------------------------------

  Widget _formStep(CadastroFlow flow) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _brandMark()),
          const SizedBox(height: 24),
          _title('Quase lá!'),
          const SizedBox(height: 10),
          _subtitle('Complete seu cadastro para participar.'),
          const SizedBox(height: 28),

          // Nome
          _label('Nome completo'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            enabled: !flow.loading,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            onChanged: (_) => _tried ? setState(() {}) : null,
            decoration: _fieldDecoration(
              hint: 'Ex.: Maria Aparecida da Silva',
              error: _nameInvalid ? 'Informe seu nome completo.' : null,
            ),
          ),
          const SizedBox(height: 20),

          // Data de nascimento
          _label('Data de nascimento'),
          const SizedBox(height: 8),
          _DateField(
            date: _birthDate,
            invalid: _dateInvalid,
            enabled: !flow.loading,
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cake_outlined,
                  size: 16, color: Colors.white.withValues(alpha: 0.75),),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Usamos sua data apenas para te enviar uma mensagem de '
                  'feliz aniversário.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Consentimento (explícito)
          _ConsentTile(
            value: _optIn,
            enabled: !flow.loading,
            onChanged: (v) => setState(() => _optIn = v),
          ),
          const SizedBox(height: 24),

          FilledButton(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),),
            onPressed: flow.loading ? null : () => _submit(flow),
            child: flow.loading
                ? const _BtnSpinner()
                : const Text('Concluir cadastro',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600,),),
          ),
          _messageBanner(flow),
        ],
      );

  // --- Sucesso --------------------------------------------------------------

  Widget _doneStep() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 72),
          const SizedBox(height: 20),
          _title('Cadastro concluído!'),
          const SizedBox(height: 10),
          _subtitle('Que bom ter você na Goel Church.'),
          const SizedBox(height: 28),
          if (widget.postCadastroBuilder != null)
            FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: widget.postCadastroBuilder!),
              ),
              child: const Text('Ir para o início',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
            ),
        ],
      );

  // --- Peças reutilizadas ---------------------------------------------------

  Widget _brandMark() => Semantics(
        label: 'Goel Church',
        image: true,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.85), width: 1.5,),
          ),
          child: ClipOval(
            child: Image.asset(
              _logoAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Colors.black,
                child:
                    Icon(Icons.church_outlined, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      );

  Widget _title(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700,),
      );

  Widget _subtitle(String t) => Text(
        t,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 16,
            height: 1.4,),
      );

  Widget _label(String t) => Text(
        t,
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,),
      );

  Widget _messageBanner(CadastroFlow flow) {
    if (flow.message == null) return const SizedBox(height: 8);
    final offline = flow.message!.toLowerCase().contains('salvar agora');
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
                  color: Colors.white.withValues(alpha: 0.95), fontSize: 15,),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint, String? error}) {
    const white70 = Color(0xB3FFFFFF);
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: white70),
      errorText: error,
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

/// Campo tocável que abre o seletor de data (visual coerente com os inputs).
class _DateField extends StatelessWidget {
  final DateTime? date;
  final bool invalid;
  final bool enabled;
  final VoidCallback onTap;
  const _DateField({
    required this.date,
    required this.invalid,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = date == null
        ? 'Escolher data'
        : '${date!.day.toString().padLeft(2, '0')}/'
            '${date!.month.toString().padLeft(2, '0')}/${date!.year}';
    return Semantics(
      button: true,
      label: 'Data de nascimento: $label',
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: invalid
                  ? const Color(0xFFFFB4A9)
                  : Colors.white.withValues(alpha: 0.70),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: date == null
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month_outlined, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha de consentimento (toda tocável, estado claro para leitor de tela).
class _ConsentTile extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  const _ConsentTile({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'Receber mensagens da igreja no WhatsApp, como a de aniversário',
      child: Material(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Switch(
                  value: value,
                  onChanged: enabled ? onChanged : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quero receber mensagens da igreja no WhatsApp '
                    '(ex.: feliz aniversário).',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
