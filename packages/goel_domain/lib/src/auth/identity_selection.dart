import 'identity_summary.dart';

/// Regras puras da etapa de seleção de identidade (A1 §5).
///
/// Framework Independence: lógica de domínio testável, sem UI nem I/O.
class IdentitySelection {
  const IdentitySelection._();

  /// Filtra, de todas as identidades vinculadas a uma credencial, apenas as
  /// SELECIONÁVEIS — as que estão em estado que permite login. Identidades
  /// Suspensas/Encerradas nunca são oferecidas, mesmo com OTP válido.
  static List<IdentitySummary> selectable(List<IdentitySummary> all) =>
      all.where((i) => i.isSelectable).toList(growable: false);

  /// Verdadeiro quando a etapa de seleção é necessária (mais de uma identidade
  /// selecionável para a mesma credencial — WhatsApp compartilhado).
  static bool isSelectionNeeded(List<IdentitySummary> all) =>
      selectable(all).length > 1;
}
