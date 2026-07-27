import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um link de rede/comunidade da Goel Church.
class RedeLink {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final String url;
  const RedeLink({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.url,
  });
}

/// Redes Sociais — entrar nos grupos e seguir a Goel Church.
///
/// Camada de apresentação: os links chegam por parâmetro (com placeholders).
/// Tocar abre o WhatsApp/Instagram no app do sistema. O Owner troca pelos
/// links reais.
class RedesScreen extends StatelessWidget {
  final List<RedeLink>? links;

  /// Injeção opcional para abrir o link (testes). Nulo → usa url_launcher.
  final Future<void> Function(String url)? onAbrir;

  const RedesScreen({super.key, this.links, this.onAbrir});

  static const _exemplo = <RedeLink>[
    RedeLink(
      titulo: 'Grupo de Boas-vindas',
      subtitulo: 'Entre no nosso grupo do WhatsApp',
      icon: Icons.chat_bubble_outline,
      url: 'https://chat.whatsapp.com/',
    ),
    RedeLink(
      titulo: 'Instagram',
      subtitulo: '@goelchurch',
      icon: Icons.camera_alt_outlined,
      url: 'https://instagram.com/',
    ),
    RedeLink(
      titulo: 'Canal no WhatsApp',
      subtitulo: 'Receba os avisos oficiais',
      icon: Icons.campaign_outlined,
      url: 'https://whatsapp.com/channel/',
    ),
    RedeLink(
      titulo: 'YouTube',
      subtitulo: 'Assista às nossas transmissões',
      icon: Icons.smart_display_outlined,
      url: 'https://youtube.com/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = links ?? _exemplo;

    return Scaffold(
      appBar: AppBar(title: const Text('Redes Sociais')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text(
                  'Faça parte da nossa comunidade',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Entre nos grupos e acompanhe a Goel Church nas redes.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final l in lista) ...[
                  _RedeCard(link: l, onTap: () => _abrir(context, l.url)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrir(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (onAbrir != null) {
        await onAbrir!(url);
      } else {
        final ok =
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (!ok) throw Exception('falha');
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o link agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }
}

class _RedeCard extends StatelessWidget {
  final RedeLink link;
  final VoidCallback onTap;
  const _RedeCard({required this.link, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir ${link.titulo}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(link.icon,
                      size: 28, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.titulo,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        link.subtitulo,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.open_in_new, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
