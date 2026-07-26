/// Configuração de ambiente injetada em tempo de build via `--dart-define`.
///
/// Segredos NUNCA são versionados: a URL e a chave anônima do Supabase entram
/// pelo build, não pelo código. A chave usada no cliente é a `anon key`
/// (pública por natureza); credenciais privilegiadas ficam server-side
/// (Edge Functions), conforme o Modelo de Confiança (P2A-02B-A1).
class AppEnv {
  final String supabaseUrl;
  final String supabaseAnonKey;

  /// Modo de PREVIEW VISUAL (`--dart-define=UI_PREVIEW=true`): abre a inspeção
  /// da interface sem Supabase, WhatsApp, OTP, backend nem persistência. Não faz
  /// parte do fluxo normal; `false` por padrão (produção inalterada).
  final bool uiPreview;

  const AppEnv({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.uiPreview = false,
  });

  /// Lê os valores fornecidos por `--dart-define` no build.
  factory AppEnv.fromEnvironment() => const AppEnv(
        supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
        supabaseAnonKey: String.fromEnvironment('SUPABASE_ANON_KEY'),
        uiPreview: bool.fromEnvironment('UI_PREVIEW'),
      );

  /// Verdadeiro apenas quando ambos os valores foram fornecidos.
  bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
