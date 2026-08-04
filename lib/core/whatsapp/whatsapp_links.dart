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

  // --- Grupos (links OFICIAIS aprovados pelo Owner — Sprint 4) ---

  /// Grupo Testemunhos Goel.
  static const String testemunhos =
      'https://chat.whatsapp.com/J1qJpFjnRV29K3zCdp7LED';

  /// Grupo Pedido de Oração.
  static const String oracao =
      'https://chat.whatsapp.com/LZgJuWetXAC2kRsiR0xdxk';

  /// Grupo Quero Ser Servo.
  static const String servo =
      'https://chat.whatsapp.com/JJtwcQrVHgN51HRAPfnDVm';

  /// Grupo GC Senador Canedo.
  static const String gcSenadorCanedo =
      'https://chat.whatsapp.com/D5NEt48OACd0X5OMzuqinS';

  /// Grupo GC Goiânia.
  static const String gcGoiania =
      'https://chat.whatsapp.com/LwH4cQFhpZ48FqP8UAfjbT';

  /// Grupo GC Jovens.
  static const String gcJovens =
      'https://chat.whatsapp.com/L5r4H2PPageCMoOx9YtiiN';

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

/// Abre o WhatsApp com uma MENSAGEM já pronta (pré-preenchida).
///
/// LIMITAÇÃO OFICIAL DO WHATSAPP (importante — não afirmamos suporte que não
/// existe): a plataforma NÃO permite postar/enviar automaticamente uma mensagem
/// em um GRUPO por link. Os links de convite (`chat.whatsapp.com/...`) apenas
/// ENTRAM no grupo, e o esquema `wa.me` só pré-preenche texto para uma CONVERSA.
/// Por isso:
///   • Com [numero] (um telefone/contato oficial): abre a conversa com o texto
///     pronto — envio direto suportado, é só tocar em enviar.
///   • Sem [numero]: abre o WhatsApp com o texto pronto e o próprio usuário
///     escolhe o destino (um contato OU um grupo) e envia — a alternativa
///     oficial mais próxima de "mandar para o grupo".
Future<void> abrirWhatsAppComMensagem(
  BuildContext context,
  String mensagem, {
  String? numero,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final texto = Uri.encodeComponent(mensagem);
  final destino = (numero != null && numero.trim().isNotEmpty)
      ? 'https://wa.me/${numero.trim()}?text=$texto'
      : 'https://wa.me/?text=$texto';
  try {
    final ok = await launchUrl(
      Uri.parse(destino),
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
