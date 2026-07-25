import 'package:flutter/foundation.dart';
import 'package:goel_domain/goel_domain.dart';

/// Fases do fluxo de login.
enum LoginPhase { phone, otp, selectIdentity, authenticated }

/// Orquestra o fluxo de login (camada de aplicação móvel).
///
/// Coordena a jornada e traduz falhas de domínio em mensagens compreensíveis
/// ao público idoso. Não contém regra de domínio nem detalhe de infraestrutura.
class LoginFlow extends ChangeNotifier {
  final AuthGateway _gateway;

  LoginFlow(this._gateway);

  LoginPhase phase = LoginPhase.phone;
  bool loading = false;
  String? message;
  String phoneE164 = '';
  List<IdentitySummary> selectable = const [];

  Future<void> submitPhone(String phone) async {
    phoneE164 = phone.trim();
    await _run(() async {
      final r = await _gateway.requestOtp(phoneE164);
      return r.fold((_) {
        phase = LoginPhase.otp;
        // Mensagem uniforme: não revela se o número é membro.
        message = 'Se este número estiver cadastrado, enviamos um código pelo '
            'WhatsApp.';
        return true;
      }, (f) {
        message = _failureText(f);
        return false;
      });
    });
  }

  Future<void> submitCode(String code) async {
    await _run(() async {
      final r = await _gateway.verifyOtp(phoneE164, code.trim());
      return r.fold((outcome) {
        switch (outcome) {
          case SessionEstablished():
            phase = LoginPhase.authenticated;
            message = null;
          case NeedsIdentitySelection(:final selectableIdentities):
            selectable = selectableIdentities;
            phase = LoginPhase.selectIdentity;
            message = 'Este WhatsApp tem mais de uma conta. Escolha a sua.';
        }
        return true;
      }, (f) {
        message = _failureText(f);
        return false;
      });
    });
  }

  Future<void> chooseIdentity(String canonicalId) async {
    await _run(() async {
      final r = await _gateway.selectIdentity(canonicalId);
      return r.fold((_) {
        phase = LoginPhase.authenticated;
        message = null;
        return true;
      }, (f) {
        message = _failureText(f);
        return false;
      });
    });
  }

  Future<void> _run(Future<bool> Function() action) async {
    loading = true;
    message = null;
    notifyListeners();
    try {
      await action();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  String _failureText(AuthFailure f) => switch (f) {
        AuthFailure.invalidCode => 'Código incorreto. Tente novamente.',
        AuthFailure.codeExpired =>
          'O código expirou. Peça um novo código pelo WhatsApp.',
        // Escalonamento REVERSÍVEL (A2.1B): nunca "bloqueado para sempre".
        AuthFailure.tooManyAttempts =>
          'Muitas tentativas. Aguarde um momento e tente de novo.',
        AuthFailure.channelUnavailable =>
          'Não foi possível conectar agora. Tente novamente em instantes.',
        AuthFailure.unknown => 'Algo deu errado. Tente novamente.',
      };
}
