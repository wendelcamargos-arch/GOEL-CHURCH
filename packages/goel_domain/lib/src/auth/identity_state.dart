/// Estados do ciclo de vida da identidade.
///
/// CANÔNICO em GOEL-ARCH-P2A-02B-A1 (§2.X). Este enum apenas REFERENCIA o
/// modelo; não o redefine. A autoridade sobre o estado pertence ao domínio
/// Comunidade e Membros (server-side); aqui só o representamos.
enum IdentityState {
  /// Pré-registrada pela igreja (enrollment controlado); ainda não ativada.
  preRegistered,

  /// Ativa — pode autenticar normalmente.
  active,

  /// Temporariamente suspensa — não autentica; invalida sessões correntes.
  suspended,

  /// Encerrada — não autentica; invalida sessões correntes.
  ended;

  /// Elegível para login/seleção.
  ///
  /// Inclui [preRegistered] porque a PRIMEIRA validação de OTP a ativa
  /// (A1: Pré-registrada → Ativa). Exclui [suspended] e [ended], que nunca
  /// são selecionáveis nem sobrevivem a uma sessão (Restrição Persistente nº 2).
  bool get canAuthenticate =>
      this == IdentityState.active || this == IdentityState.preRegistered;

  /// A primeira validação de OTP transiciona esta identidade para [active].
  bool get activatesOnFirstOtp => this == IdentityState.preRegistered;
}
