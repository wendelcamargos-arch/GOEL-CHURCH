import 'package:flutter/material.dart';

/// Tema do aplicativo — identidade **preto e branco** (monocromática).
///
/// Decisão do Owner: fundo preto, conteúdo branco, sem verde em lugar nenhum.
/// Alinha a Goel Church ao visual limpo das referências. A cor de destaque é o
/// próprio branco (primary), o que mantém contraste alto tanto sobre as telas
/// escuras quanto sobre as fotos institucionais (fachada) usadas nos heróis.
///
/// Acessibilidade continua como REQUISITO (público de todas as idades):
/// tipografia ampliada, alvos amplos, densidade confortável e contraste elevado.
class AppTheme {
  const AppTheme._();

  /// Paleta neutra (escala de cinza) — construída à mão para garantir ZERO
  /// matiz (nada de verde/azul residual que o gerador tonal introduziria).
  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF2A2A2A),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFFD6D6D6),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF262626),
    onSecondaryContainer: Color(0xFFF2F2F2),
    tertiary: Color(0xFFBDBDBD),
    onTertiary: Color(0xFF000000),
    tertiaryContainer: Color(0xFF262626),
    onTertiaryContainer: Color(0xFFF2F2F2),
    error: Color(0xFFFF7A7A),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF4A1616),
    onErrorContainer: Color(0xFFFFD9D9),
    surface: Color(0xFF000000),
    onSurface: Color(0xFFF2F2F2),
    onSurfaceVariant: Color(0xFFB5B5B5),
    outline: Color(0xFF6E6E6E),
    outlineVariant: Color(0xFF303030),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF1A1A1A),
    surfaceContainer: Color(0xFF1F1F1F),
    surfaceContainerHigh: Color(0xFF262626),
    surfaceContainerHighest: Color(0xFF2E2E2E),
    inverseSurface: Color(0xFFF2F2F2),
    onInverseSurface: Color(0xFF000000),
    inversePrimary: Color(0xFF000000),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF000000),
  );

  // O app é integralmente preto e branco: light() e dark() retornam a mesma
  // identidade, e a raiz fixa `themeMode: dark`. Manter os dois nomes evita
  // qualquer regressão em quem já os referencia.
  static ThemeData light() => _base();
  static ThemeData dark() => _base();

  static ThemeData _base() {
    final base = ThemeData(colorScheme: _scheme, useMaterial3: true);

    // Tipografia ampliada para leitura confortável. O `fontSize` vive na
    // GEOMETRIA (`englishLike`); mesclamos geometria + cor antes de aplicar o
    // fator (aplicar sobre `fontSize` nulo dispara assertion no Flutter).
    final typography = Typography.material2021(platform: TargetPlatform.android);
    final scaledTextTheme =
        typography.englishLike.merge(typography.white).apply(fontSizeFactor: 1.15);

    return base.copyWith(
      scaffoldBackgroundColor: _scheme.surface,
      textTheme: scaledTextTheme,
      visualDensity: VisualDensity.comfortable,
      // Botão primário: branco com texto preto (sursurge sobre as fotos escuras
      // dos heróis com contraste máximo). Alvo de toque amplo.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          backgroundColor: _scheme.primary,
          foregroundColor: _scheme.onPrimary,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
