import 'package:flutter/foundation.dart';
import 'package:goel_domain/goel_domain.dart';

/// Orquestra o cadastro do membro (completar perfil após o login).
class CadastroFlow extends ChangeNotifier {
  final MemberProfileGateway _gateway;
  final DateTime Function() _now;

  CadastroFlow(this._gateway, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  bool loading = false;
  bool done = false;
  String? message;

  Future<void> submit({
    required String fullName,
    required DateTime? birthDate,
    required bool whatsappOptIn,
  }) async {
    if (!ProfileValidation.isComplete(fullName, birthDate, _now())) {
      message = 'Informe seu nome e uma data de nascimento válida.';
      notifyListeners();
      return;
    }

    loading = true;
    message = null;
    notifyListeners();

    final r = await _gateway.save(MemberProfile(
      fullName: fullName.trim(),
      birthDate: birthDate!,
      whatsappOptIn: whatsappOptIn,
    ));

    r.fold((_) {
      done = true;
    }, (e) {
      message = switch (e) {
        ProfileError.unauthenticated => 'Sua sessão expirou. Entre novamente.',
        ProfileError.invalid => 'Dados inválidos. Confira e tente de novo.',
        ProfileError.unavailable =>
          'Não foi possível salvar agora. Tente novamente.',
      };
    });

    loading = false;
    notifyListeners();
  }
}
