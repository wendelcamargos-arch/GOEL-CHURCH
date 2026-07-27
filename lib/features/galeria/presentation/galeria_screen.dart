import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um álbum de fotos/vídeos hospedado no Google Drive.
class AlbumDrive {
  final String titulo;
  final String descricao;
  final bool video;

  /// Link da pasta/álbum no Google Drive (o Owner injeta os reais).
  final String driveUrl;

  const AlbumDrive({
    required this.titulo,
    required this.descricao,
    required this.driveUrl,
    this.video = false,
  });
}

/// Fotos e vídeos — álbuns no Google Drive.
///
/// As mídias ficam no Google Drive: cada álbum abre a pasta correspondente no
/// app/navegador, onde a pessoa visualiza e baixa direto do Drive. Camada de
/// apresentação: os álbuns chegam por parâmetro (com exemplos como padrão);
/// o Owner substitui pelos links reais das pastas.
class GaleriaScreen extends StatelessWidget {
  final List<AlbumDrive>? albuns;

  /// Injeção opcional para abrir o link (testes). Nulo → usa url_launcher.
  final Future<void> Function(String url)? onAbrir;

  const GaleriaScreen({super.key, this.albuns, this.onAbrir});

  static const _exemplo = <AlbumDrive>[
    AlbumDrive(
      titulo: 'Cultos de Domingo',
      descricao: 'Fotos e vídeos das celebrações',
      driveUrl: 'https://drive.google.com/',
      video: true,
    ),
    AlbumDrive(
      titulo: 'Batismos 2026',
      descricao: 'Momentos de decisão e fé',
      driveUrl: 'https://drive.google.com/',
    ),
    AlbumDrive(
      titulo: 'Encontro de Jovens',
      descricao: 'Álbum do último encontro',
      driveUrl: 'https://drive.google.com/',
    ),
    AlbumDrive(
      titulo: 'Ação Social',
      descricao: 'Servindo a nossa cidade',
      driveUrl: 'https://drive.google.com/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = albuns ?? _exemplo;

    return Scaffold(
      appBar: AppBar(title: const Text('Fotos e vídeos')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_outlined, size: 20, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Os álbuns ficam no Google Drive. Toque para ver e '
                        'baixar as fotos e vídeos.',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (final a in lista) ...[
                  _AlbumCard(album: a, onTap: () => _abrir(context, a.driveUrl)),
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

class _AlbumCard extends StatelessWidget {
  final AlbumDrive album;
  final VoidCallback onTap;
  const _AlbumCard({required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir ${album.titulo} no Google Drive',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    album.video
                        ? Icons.video_library_outlined
                        : Icons.photo_library_outlined,
                    size: 28,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.titulo,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album.descricao,
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
