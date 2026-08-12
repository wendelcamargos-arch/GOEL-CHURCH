import 'package:flutter/material.dart';

/// Tipografia padronizada da identidade Goel (design system).
/// Helpers finos sobre o `TextTheme` do tema, para uso consistente nas telas.
abstract final class GoelTypography {
  /// Título de seção/tela (conteúdo).
  static TextStyle? sectionTitle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium
      ?.copyWith(fontWeight: FontWeight.w700);

  /// Título de card.
  static TextStyle? cardTitle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium
      ?.copyWith(fontWeight: FontWeight.w600);

  /// Subtítulo/descrição secundária.
  static TextStyle? subtitle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: scheme.onSurfaceVariant);
  }

  /// Nome da marca no cabeçalho ("GOEL CHURCH").
  static const TextStyle brand = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  /// Slogan institucional (itálico, leve transparência).
  static TextStyle slogan = TextStyle(
    color: Colors.white.withValues(alpha: 0.80),
    fontSize: 14,
    height: 1.3,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
  );
}
