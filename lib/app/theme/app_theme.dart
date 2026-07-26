import 'package:flutter/material.dart';

/// Tema do aplicativo.
///
/// Acessibilidade é REQUISITO ARQUITETURAL (público idoso — premissa oficial):
/// tipografia ampliada, alvos de toque generosos, contraste elevado e densidade
/// visual confortável. Estas escolhas são qualitativas; qualquer valor fino de
/// parametrização é ajuste operacional posterior, sem impacto na decisão.
class AppTheme {
  const AppTheme._();

  /// Verde institucional (placeholder — identidade visual definitiva posterior).
  static const Color _seed = Color(0xFF1B5E20);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    // Tipografia ampliada para leitura confortável do público idoso.
    // O `fontSize` vive na GEOMETRIA (`englishLike`), não no tema de cor
    // (`black`/`white`). Mesclamos geometria + cor para garantir `fontSize`
    // em todos os estilos antes de aplicar o fator — aplicar sobre um tema
    // com `fontSize` nulo dispara assertion no Flutter.
    final typography = Typography.material2021(platform: TargetPlatform.android);
    final colored =
        brightness == Brightness.dark ? typography.white : typography.black;
    final scaledTextTheme =
        typography.englishLike.merge(colored).apply(fontSizeFactor: 1.15);

    return base.copyWith(
      textTheme: scaledTextTheme,
      visualDensity: VisualDensity.comfortable,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Alvo de toque amplo, tolerante a toque impreciso.
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
