/// Perfil do membro (domínio Comunidade e Membros).
///
/// A [birthDate] é DADO DE PERFIL — nunca fator de autenticação (A1). Sua
/// finalidade é alimentar a AUTOMAÇÃO DE ANIVERSÁRIO: no dia do aniversário,
/// o sistema envia automaticamente uma mensagem ao membro pelo WhatsApp, sem
/// intervenção humana. Por isso o envio depende de [whatsappOptIn] (base para
/// comunicação — consentimento; validação jurídica final no Pacote 3).
class MemberProfile {
  final String fullName;
  final DateTime birthDate;

  /// Consentimento para receber comunicações no WhatsApp (ex.: aniversário).
  final bool whatsappOptIn;

  const MemberProfile({
    required this.fullName,
    required this.birthDate,
    required this.whatsappOptIn,
  });
}

/// Regras puras de validação do cadastro (Framework Independence).
class ProfileValidation {
  const ProfileValidation._();

  static bool isValidName(String name) => name.trim().length >= 2;

  /// A data de nascimento precisa existir e ser anterior a [now].
  static bool isValidBirthDate(DateTime birthDate, DateTime now) =>
      birthDate.isBefore(now);

  static bool isComplete(String name, DateTime? birthDate, DateTime now) =>
      isValidName(name) &&
      birthDate != null &&
      isValidBirthDate(birthDate, now);
}
