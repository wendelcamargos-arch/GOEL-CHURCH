import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import 'verse_share_card.dart';

/// Compartilhar um versículo (EU-04) — TEXTO, IMAGEM ou IMAGEM + QR Code, com a
/// identidade Goel Church. A imagem é capturada do [VerseShareCard].
class CompartilharVersiculoScreen extends StatefulWidget {
  final String texto;
  final String referencia; // ex.: "João 3:16"

  const CompartilharVersiculoScreen({
    super.key,
    required this.texto,
    required this.referencia,
  });

  @override
  State<CompartilharVersiculoScreen> createState() =>
      _CompartilharVersiculoScreenState();
}

class _CompartilharVersiculoScreenState
    extends State<CompartilharVersiculoScreen> {
  final _cardKey = GlobalKey();
  bool _comQr = false;
  bool _ocupado = false;

  Future<void> _compartilharTexto() async {
    await Share.share(
      '"${widget.texto}"\n\n— ${widget.referencia}\n\nGoel Church',
    );
  }

  Future<void> _compartilharImagem() async {
    setState(() => _ocupado = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary =
          _cardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw Exception('sem imagem');
      final file = File('${Directory.systemTemp.path}/versiculo-goel.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.referencia} — Goel Church',
      );
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível gerar a imagem agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhar versículo')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RepaintBoundary(
                    key: _cardKey,
                    child: VerseShareCard(
                      texto: widget.texto,
                      referencia: widget.referencia,
                      comQr: _comQr,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _comQr,
                    onChanged: (v) => setState(() => _comQr = v),
                    title: const Text('Incluir QR Code'),
                    subtitle: const Text('Adiciona o QR da Goel Church à imagem'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _ocupado ? null : _compartilharImagem,
                    icon: _ocupado
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.image_outlined),
                    label: Text(_comQr
                        ? 'Compartilhar imagem + QR'
                        : 'Compartilhar imagem',),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: _compartilharTexto,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Compartilhar texto'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
