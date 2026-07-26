import '../shared/result.dart';
import 'auth_models.dart';

/// Contrato da porta de autenticação (Stable Module Boundaries).
///
/// O domínio define O QUE a autenticação faz; a implementação (camada de dados,
/// via Supabase Edge Functions) define o COMO. O domínio não conhece Supabase,
/// Meta nem HTTP.
///
/// Framework Independence: contrato em Dart puro.
abstract interface class AuthGateway {
  /// Solicita o envio de um OTP para o número informado.
  ///
  /// A resposta é sempre uniforme (anti-enumeração): sucesso não revela se o
  /// número é membro. O envio efetivo ocorre server-side (token Meta protegido).
  Future<Result<OtpRequestOutcome, AuthFailure>> requestOtp(String phoneE164);

  /// Valida o código para o número e resolve a autenticação.
  ///
  /// Em sucesso, retorna [SessionEstablished] (uma identidade) ou
  /// [NeedsIdentitySelection] (WhatsApp compartilhado).
  Future<Result<VerificationOutcome, AuthFailure>> verifyOtp(
    String phoneE164,
    String code,
  );

  /// Conclui a autenticação após a pessoa escolher uma identidade
  /// (caso [NeedsIdentitySelection]). Estabelece a sessão para a identidade
  /// selecionada, desde que ela permaneça em estado que permita login.
  Future<Result<SessionEstablished, AuthFailure>> selectIdentity(
    String canonicalId,
  );
}
