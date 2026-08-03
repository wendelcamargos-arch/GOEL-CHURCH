import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Arquivo CENTRAL de links do WhatsApp da Goel Church (Sprint 4).
///
/// Objetivo: reunir num único lugar todos os grupos/conversas do WhatsApp
/// usados pelo app. Quando o Owner criar cada grupo, basta colar a URL aqui —
/// nenhuma outra tela precisa mudar.
///
/// Links de GRUPO: cole a URL completa (ex.: https://chat.whatsapp.com/XXXX).
/// Vazio ('') = ainda NÃO definido → o app avisa "em breve" com elegância,
/// sem quebrar a experiência.
class WhatsAppLinks {
  const WhatsAppLinks._();

  // --- Grupos (PENDENTES — TODO_OWNER: colar a URL oficial de cada grupo) ---

  /// TODO_OWNER: Adicionar link oficial do Grupo Testemunhos Goel.
  static const String testemunhos = '';

  /// TODO_OWNER: Adicionar link oficial do Grupo Pedido de Oração.
  static const String oracao = '';

  /// TODO_OWNER: Adicionar link oficial do Grupo Quero Ser Servo.
  static const String servo = '';

  /// TODO_OWNER: Adicionar link oficial do Grupo GC Senador Canedo.
  static const String gcSenadorCanedo = '';

  /// TODO_OWNER: Adicionar link oficial do Grupo GC Goiânia.
  static const String gcGoiania = '';

  /// TODO_OWNER: Adicionar link oficial do Grupo GC Jovens.
  static const String gcJovens = '';

  // --- Gabinete Pastoral (auditoria EU-07: os contatos JÁ EXISTEM) ---
  // Conversa direta (número internacional, só dígitos). Não são placeholders.

  /// Pastor Linniker — conversa direta (já existe).
  static const String pastorLinniker = '5562995422169';

  /// Pastora Wanessa — conversa direta (já existe).
  static const String pastoraWanessa = '5562993095993';

  /// `true` quando o link já foi definido pelo Owner (não é placeholder vazio).
  static bool definido(String link) => link.trim().isNotEmpty;
}

/// Abre um GRUPO do WhatsApp pela URL. Se o link ainda for um placeholder
/// vazio, avisa gentilmente (SnackBar) em vez de quebrar a experiência.
Future<void> abrirGrupoWhatsApp(
  BuildContext context,
  String link, {
  String aviso = 'O grupo do WhatsApp será disponibilizado em breve.',
}) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!WhatsAppLinks.definido(link)) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(aviso),
        behavior: SnackBarBehavior.floating,
      ),);
    return;
  }
  try {
    final ok = await launchUrl(
      Uri.parse(link.trim()),
      mode: LaunchMode.externalApplication,
    );
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

/// Abre uma CONVERSA direta (wa.me) a partir de um número + texto opcional.
/// Usado pelo Gabinete Pastoral (contatos que já existem).
Future<void> abrirConversaWhatsApp(
  BuildContext context,
  String numero, {
  String? texto,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final base = 'https://wa.me/${numero.trim()}';
  final uri = (texto == null || texto.trim().isEmpty)
      ? Uri.parse(base)
      : Uri.parse('$base?text=${Uri.encodeComponent(texto)}');
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
