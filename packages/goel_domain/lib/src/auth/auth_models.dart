import 'identity_summary.dart';

/// Resultado de solicitar um OTP.
///
/// UNIFORME por design (controle C4/C5 — anti-enumeração): a resposta é a mesma
/// exista ou não o número no cadastro. O cliente nunca sabe se o número é
/// membro; apenas que, se elegível, o código foi enviado.
class OtpRequestOutcome {
  const OtpRequestOutcome.uniform();
}

/// Resultado de validar um OTP.
sealed class VerificationOutcome {
  const VerificationOutcome();
}

/// Sucesso com uma única identidade — sessão pode ser estabelecida.
final class SessionEstablished extends VerificationOutcome {
  final IdentitySummary identity;
  const SessionEstablished(this.identity);
}

/// A credencial autentica mais de uma identidade (WhatsApp compartilhado, A1
/// §4). A pessoa precisa selecionar qual identidade usar. Apenas identidades
/// selecionáveis (estado que permite login) são oferecidas.
final class NeedsIdentitySelection extends VerificationOutcome {
  final List<IdentitySummary> selectableIdentities;
  const NeedsIdentitySelection(this.selectableIdentities);
}

/// Falhas possíveis do fluxo de autenticação.
///
/// INVARIANTE IDOSO-SEGURO (A2.1B): [tooManyAttempts] representa um
/// escalonamento REVERSÍVEL (cooldown), nunca bloqueio permanente. O acesso
/// permanece sempre recuperável.
enum AuthFailure {
  invalidCode,
  codeExpired,
  tooManyAttempts,
  channelUnavailable,
  unknown,
}
