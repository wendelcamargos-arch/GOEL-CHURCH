import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'whatsapp_links.dart';

/// Serviço ÚNICO e reutilizável para levar uma mensagem a um GRUPO oficial do
/// WhatsApp — padrão único de Testemunho, Pedido de Oração e Quero Ser Servo
/// (hotfix).
///
/// LIMITAÇÃO OFICIAL DO WHATSAPP: a plataforma **não** permite pré-preencher o
/// campo de um grupo nem enviar automaticamente. Por isso o padrão é:
///   1. Copiar a mensagem final para a área de transferência.
///   2. Mostrar orientação clara (colar e enviar) **antes** de abrir o WhatsApp.
///   3. Abrir **diretamente** o link do grupo (`chat.whatsapp.com/...`).
///   4. Em falha ao abrir, a mensagem **permanece copiada**.
///   5. Oferecer **"Copiar novamente"**.
///
/// NÃO usa `wa.me/?text=` e NÃO declara que a mensagem foi enviada (o envio
/// depende do usuário no WhatsApp).
class WhatsAppGroupSubmissionService {
  const WhatsAppGroupSubmissionService();

  /// Copia [mensagem], exibe a orientação e abre o grupo [linkGrupo] quando o
  /// usuário confirmar. Retorna quando a orientação é fechada.
  Future<void> preparar(
    BuildContext context, {
    required String mensagem,
    required String linkGrupo,
    String avisoGrupoIndisponivel =
        'O grupo do WhatsApp será disponibilizado em breve.',
  }) async {
    // 1. Copia a mensagem completa ANTES de qualquer navegação.
    await Clipboard.setData(ClipboardData(text: mensagem));
    if (!context.mounted) return;

    // 2. Orientação clara + ações (Abrir grupo / Copiar novamente / Cancelar).
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final textTheme = Theme.of(sheetCtx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mensagem copiada!',
                  style:
                      textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'No WhatsApp:\n'
                  '1. Toque no campo de mensagem.\n'
                  '2. Cole o conteúdo.\n'
                  '3. Toque em Enviar.',
                  style: textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 20),
                // 3. Abre diretamente o grupo oficial.
                FilledButton.icon(
                  icon: const Icon(Icons.groups_outlined),
                  label: const Text('Abrir grupo'),
                  onPressed: () async {
                    Navigator.of(sheetCtx).pop();
                    await abrirGrupoWhatsApp(
                      context,
                      linkGrupo,
                      aviso: avisoGrupoIndisponivel,
                    );
                  },
                ),
                const SizedBox(height: 10),
                // 5. Copiar novamente (mensagem nunca se perde).
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copiar novamente'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: mensagem));
                    if (!sheetCtx.mounted) return;
                    ScaffoldMessenger.of(sheetCtx)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                        content: Text('Mensagem copiada novamente.'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),);
                  },
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => Navigator.of(sheetCtx).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
