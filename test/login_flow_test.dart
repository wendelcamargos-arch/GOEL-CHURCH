import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/app/goel_app.dart';
import 'package:goel_church/features/auth/application/login_flow.dart';
import 'package:goel_domain/goel_domain.dart';

IdentitySummary _id(String id) =>
    IdentitySummary(canonicalId: id, displayName: id, state: IdentityState.active);

class _FakeGateway implements AuthGateway {
  final VerificationOutcome verifyResult;
  _FakeGateway(this.verifyResult);

  @override
  Future<Result<OtpRequestOutcome, AuthFailure>> requestOtp(String phone) async =>
      const Ok(OtpRequestOutcome.uniform());

  @override
  Future<Result<VerificationOutcome, AuthFailure>> verifyOtp(
    String phone,
    String code,
  ) async =>
      Ok(verifyResult);

  @override
  Future<Result<SessionEstablished, AuthFailure>> selectIdentity(
    String canonicalId,
  ) async =>
      Ok(SessionEstablished(_id(canonicalId)));
}

void main() {
  group('LoginFlow', () {
    test('enviar número avança para a etapa de código', () async {
      final flow = LoginFlow(_FakeGateway(SessionEstablished(_id('a'))));
      await flow.submitPhone('+5511999999999');
      expect(flow.phase, LoginPhase.otp);
    });

    test('código válido com uma identidade autentica', () async {
      final flow = LoginFlow(_FakeGateway(SessionEstablished(_id('a'))));
      await flow.submitCode('123456');
      expect(flow.phase, LoginPhase.authenticated);
    });

    test('WhatsApp compartilhado pede seleção e depois autentica', () async {
      final flow = LoginFlow(
        _FakeGateway(NeedsIdentitySelection([_id('a'), _id('b')])),
      );
      await flow.submitCode('123456');
      expect(flow.phase, LoginPhase.selectIdentity);
      expect(flow.selectable.length, 2);

      await flow.chooseIdentity('a');
      expect(flow.phase, LoginPhase.authenticated);
    });
  });

  testWidgets('LoginGate exibe a entrada por WhatsApp', (tester) async {
    final flow = LoginFlow(_FakeGateway(SessionEstablished(_id('a'))));
    await tester.pumpWidget(GoelApp(loginFlow: flow));
    expect(find.text('Entrar com o WhatsApp'), findsOneWidget);
  });
}
