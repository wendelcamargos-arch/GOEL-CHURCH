import 'identity_state.dart';

/// Referência mínima a uma identidade, usada na etapa de seleção de identidade.
///
/// Identifica a pessoa pelo IDENTIFICADOR CANÔNICO (A1 §2.X.2) — nunca pelo
/// número de WhatsApp. O número é credencial, não identidade.
class IdentitySummary {
  /// Identificador canônico, estável por todo o ciclo de vida (A1 §2.X.2).
  final String canonicalId;

  /// Nome de exibição para a pessoa escolher qual identidade usar.
  final String displayName;

  /// Estado atual (A1 §2.X).
  final IdentityState state;

  const IdentitySummary({
    required this.canonicalId,
    required this.displayName,
    required this.state,
  });

  bool get isSelectable => state.canAuthenticate;
}
