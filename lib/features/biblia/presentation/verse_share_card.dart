import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Link padrão do QR nos cards de versículo (identidade Goel Church).
const String kGoelShareLink = 'https://www.instagram.com/goelchurch_';

/// Card do versículo com a identidade Goel Church — usado tanto para pré-visualizar
/// quanto para gerar a IMAGEM compartilhável (com ou sem QR Code).
class VerseShareCard extends StatelessWidget {
  final String texto;
  final String referencia; // ex.: "João 3:16"
  final bool comQr;
  final String qrData;

  const VerseShareCard({
    super.key,
    required this.texto,
    required this.referencia,
    this.comQr = false,
    this.qrData = kGoelShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      constraints: const BoxConstraints(minHeight: 420),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF121212), Color(0xFF000000)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Marca
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/brand/goel_logo.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.church_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'GOEL CHURCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Icon(Icons.format_quote, color: Colors.white38, size: 40),
            const SizedBox(height: 12),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                referencia,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (comQr) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QrImageView(
                  data: qrData,
                  size: 92,
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Siga a Goel Church',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ] else
              const Text(
                'Almeida 1911 · Domínio Público',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
