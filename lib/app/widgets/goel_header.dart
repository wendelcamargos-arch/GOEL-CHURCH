import 'package:flutter/material.dart';

import '../theme/goel_typography.dart';

/// Cabeçalho oficial da identidade Goel (design system).
///
/// Renderiza SEMPRE, centralizado: **Logo → GOEL CHURCH → slogan**.
/// Nenhuma tela deve desenhar esse cabeçalho manualmente — todas usam
/// [GoelHeader]. Um [extra] opcional (ex.: saudação da Home) aparece abaixo do
/// slogan. Pensado para telas com o fundo global (fachada) — texto branco.
class GoelHeader extends StatelessWidget {
  /// Widget opcional abaixo do slogan (ex.: saudação "Olá, Fulano").
  final Widget? extra;

  /// Padding externo. Nulo → usa um padrão que respeita a status bar.
  final EdgeInsetsGeometry? padding;

  const GoelHeader({super.key, this.extra, this.padding});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(20, topInset + 16, 20, 8),
      // Largura total garante que o conjunto (Logo → GOEL CHURCH → slogan)
      // fique PERFEITAMENTE centralizado na tela (sem encolher e "puxar" para a
      // esquerda dentro de um Stack).
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          _logoMark(),
          const SizedBox(height: 10),
          const Text(
            'GOEL CHURCH',
            textAlign: TextAlign.center,
            style: GoelTypography.brand,
          ),
          const SizedBox(height: 8),
          Text(
            'Uma igreja para você frequentar\n'
            'e uma família para você pertencer.',
            textAlign: TextAlign.center,
            style: GoelTypography.slogan,
          ),
          if (extra != null) ...[
            const SizedBox(height: 14),
            extra!,
          ],
          ],
        ),
      ),
    );
  }

  Widget _logoMark() => Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.85),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/goel_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Colors.black,
              child: Icon(Icons.church_outlined, color: Colors.white, size: 44),
            ),
          ),
        ),
      );
}
