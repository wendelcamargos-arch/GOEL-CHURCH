import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fotos e vídeos — as mídias ficam no Google Drive.
///
/// O link padrão é o da PASTA GERAL, que contém duas subpastas: "Fotos" e
/// "Vídeos". A pessoa escolhe uma pasta e vê/baixa tudo direto do Drive.
///
/// Se um dia houver os links DIRETOS de cada subpasta, basta passar [fotosUrl]
/// e/ou [videosUrl] — os cartões passam a abrir a pasta certa direto. Enquanto
/// não houver, ambos abrem a pasta geral (onde as duas pastas aparecem).
class GaleriaScreen extends StatelessWidget {
  /// Pasta geral no Google Drive (contém as pastas Fotos e Vídeos).
  final String pastaGeralUrl;

  /// Links diretos (opcionais) de cada subpasta.
  final String? fotosUrl;
  final String? videosUrl;

  /// Injeção opcional para abrir o link (testes). Nulo → usa url_launcher.
  final Future<void> Function(String url)? onAbrir;

  const GaleriaScreen({
    super.key,
    this.pastaGeralUrl =
        'https://drive.google.com/drive/folders/1BsRKnvIXsRAKJZat1_Yor4UJiHo4gU3k?usp=drive_link',
    this.fotosUrl,
    this.videosUrl,
    this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Fotos e vídeos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_outlined,
                        size: 20, color: scheme.onSurfaceVariant,),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'As nossas fotos e vídeos ficam no Google Drive. '
                        'Escolha uma pasta — você vê e baixa tudo direto do Drive.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _PastaCard(
                  titulo: 'Fotos',
                  descricao: 'Os melhores momentos em imagens',
                  icon: Icons.photo_library_outlined,
                  onTap: () => _abrir(context, fotosUrl ?? pastaGeralUrl),
                ),
                const SizedBox(height: 12),
                _PastaCard(
                  titulo: 'Vídeos',
                  descricao: 'Cultos, eventos e testemunhos em vídeo',
                  icon: Icons.video_library_outlined,
                  onTap: () => _abrir(context, videosUrl ?? pastaGeralUrl),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _abrir(context, pastaGeralUrl),
                    icon: const Icon(Icons.folder_open_outlined),
                    label: const Text('Abrir a pasta geral no Drive'),
                  ),
                ),
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
        final ok = await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('não foi possível abrir');
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o Google Drive agora.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

class _PastaCard extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icon;
  final VoidCallback onTap;
  const _PastaCard({
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir $titulo no Google Drive',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        descricao,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.open_in_new,
                              size: 16, color: scheme.onSurfaceVariant,),
                          const SizedBox(width: 6),
                          Text(
                            'Abrir no Google Drive',
                            style: textTheme.labelMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
