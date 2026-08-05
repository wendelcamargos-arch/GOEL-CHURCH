import 'package:flutter/material.dart';

import '../../../core/whatsapp/whatsapp_group_submission.dart';
import '../../../core/whatsapp/whatsapp_links.dart';

/// Quero ser Servo — inscrição para servir em um ministério.
///
/// Padrão único (hotfix): ao enviar, a mensagem é COPIADA e o grupo oficial
/// Quero Ser Servo é aberto diretamente (o usuário cola e envia). O WhatsApp
/// não permite pré-preencher o campo de um grupo — sem envio automático.
class ServoScreen extends StatefulWidget {
  final Future<void> Function(String nome, String contato, List<String> areas)?
      onSubmit;

  /// Serviço injetável (testes). Nulo → usa o padrão real.
  final WhatsAppGroupSubmissionService? service;

  const ServoScreen({super.key, this.onSubmit, this.service});

  @override
  State<ServoScreen> createState() => _ServoScreenState();
}

class _ServoScreenState extends State<ServoScreen> {
  // Lista sugerida.
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

  WhatsAppGroupSubmissionService get _service =>
      widget.service ?? const WhatsAppGroupSubmissionService();

  bool get _nomeInvalid => _nome.text.trim().isEmpty;
  bool get _contatoInvalid => _contato.text.trim().isEmpty;
  bool get _areaInvalid => _selecionadas.isEmpty;
  bool get _invalid => _nomeInvalid || _contatoInvalid || _areaInvalid;

  @override
  void dispose() {
    _nome.dispose();
    _contato.dispose();
    super.dispose();
  }

  /// Grupo oficial da(s) área(s). Hoje há um único grupo (centralizado em
  /// [WhatsAppLinks.servo]). Se no futuro cada área tiver grupo próprio, mapear
  /// aqui num mapa tipado — sem hardcode na tela.
  String get _linkGrupo => WhatsAppLinks.servo;

  String _listar(List<String> itens) {
    if (itens.length <= 1) return itens.join();
    return '${itens.sublist(0, itens.length - 1).join(', ')} e ${itens.last}';
  }

  /// Mensagem final EXATA (EU-04).
  String montarMensagem() {
    final nome = _nome.text.trim();
    final contato = _contato.text.trim();
    final areas = _selecionadas.toList();
    final areasStr = areas.join(', ');
    final frase = areas.length == 1
        ? 'Quero servir na equipe de ${areas.first}.'
        : 'Quero servir nas equipes de ${_listar(areas)}.';
    return 'QUERO SER SERVO — GOEL CHURCH\n\n'
        'Nome: $nome\n'
        'WhatsApp: $contato\n'
        'Área de interesse: $areasStr\n\n'
        '$frase';
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
    setState(() => _sending = false);
    await _service.preparar(
      context,
      mensagem: montarMensagem(),
      linkGrupo: _linkGrupo,
      avisoGrupoIndisponivel:
          'O grupo Quero Ser Servo será disponibilizado em breve.',
    );
    if (!mounted) return;
    setState(() => _sent = true);
  }

  Future<void> _entrarNoGrupo() async {
    await abrirGrupoWhatsApp(
      context,
      _linkGrupo,
      aviso: 'O grupo Quero Ser Servo será disponibilizado em breve.',
    );
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
            errorText: _tried && _nomeInvalid ? 'Informe o seu nome.' : null,
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
            labelText: 'WhatsApp',
            border: const OutlineInputBorder(),
            errorText:
                _tried && _contatoInvalid ? 'Informe o seu WhatsApp.' : null,
          ),
        ),
        const SizedBox(height: 20),
        Text('Áreas de interesse',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),),
        const SizedBox(height: 4),
        if (_tried && _areaInvalid)
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
        const SizedBox(height: 16),
        Text(
          'Ao enviar, copiamos a sua mensagem e abrimos o grupo Quero Ser Servo. '
          'É só colar (segurar no campo → Colar) e tocar em Enviar.',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _sending ? null : _submit,
          icon: _sending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),)
              : const Icon(Icons.send_outlined),
          label: Text(_sending ? 'Preparando…' : 'Enviar inscrição'),
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
            child: Icon(Icons.assignment_turned_in_outlined,
                size: 52, color: scheme.onPrimaryContainer,),
          ),
          const SizedBox(height: 24),
          Text('Preparamos sua mensagem',
              textAlign: TextAlign.center,
              style:
                  textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),),
          const SizedBox(height: 8),
          Text(
            'Sua mensagem foi copiada. No grupo Quero Ser Servo, cole (segurar no '
            'campo → Colar) e toque em Enviar. Nossa equipe vai falar com você.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge
                ?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
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
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }
}
