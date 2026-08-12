import 'package:flutter/widgets.dart';

/// Espaçamentos padronizados da identidade Goel (design system).
/// Uso: `GoelSpacing.lg`, `SizedBox(height: GoelSpacing.md)`, etc.
abstract final class GoelSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Margem horizontal padrão do conteúdo das telas.
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: 20);

  /// Padding padrão de conteúdo (compacto — evita rolagem desnecessária).
  static const EdgeInsets content = EdgeInsets.fromLTRB(20, 16, 20, 16);
}
