import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/auth/application/login_flow.dart';
import 'package:goel_church/features/auth/data/session_store.dart';
import 'package:goel_domain/goel_domain.dart';

/// Testes de REGRESSÃO do Logout local (Gate Final PASSO 9).
///
/// Garantem que, após `SessionStore.clear()` + `LoginFlow.reset()`, nenhum
/// estado autenticado permaneça em memória. Não exercitam a UI nem alteram
/// comportamento — apenas travam a invariante de limpeza.

IdentitySummary _id(String id) => IdentitySummary(
      canonicalId: id,
      displayName: id,
      state: IdentityState.active,
    );

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
  group('Logout local — SessionStore.clear()', () {
    test('remove JWT, sessão e identidade selecionada da memória', () {
      final session = SessionStore();
      session.set(_id('canonical-1'), 'jwt-hs256-token');

      // Pré-condição: sessão carregada.
      expect(session.isAuthenticated, isTrue);
      expect(session.accessToken, isNotNull);
      expect(session.identity, isNotNull);

      session.clear();

      // ✓ JWT inexistente
      expect(session.accessToken, isNull);
      // ✓ sessão inexistente
      expect(session.isAuthenticated, isFalse);
      // ✓ identidade selecionada inexistente
      expect(session.identity, isNull);
    });
  });

  group('Logout local — LoginFlow.reset()', () {
    test('após autenticação, reset zera todo o estado do fluxo', () async {
      final flow = LoginFlow(_FakeGateway(SessionEstablished(_id('a'))));
      await flow.submitPhone('+5511999999999');
      await flow.submitCode('123456');
      expect(flow.phase, LoginPhase.authenticated);

      flow.reset();

      // ✓ phase retornou ao estado inicial
      expect(flow.phase, LoginPhase.phone);
      // ✓ loading=false
      expect(flow.loading, isFalse);
      // ✓ mensagens temporárias limpas
      expect(flow.message, isNull);
      // ✓ telefone limpo
      expect(flow.phoneE164, isEmpty);
      // ✓ nenhuma identidade selecionável remanescente
      expect(flow.selectable, isEmpty);
    });

    test('reset limpa também o estado de WhatsApp compartilhado', () async {
      final flow = LoginFlow(
        _FakeGateway(NeedsIdentitySelection([_id('a'), _id('b')])),
      );
      await flow.submitPhone('+5511988887777');
      await flow.submitCode('123456');
      // Estado "sujo": múltiplas identidades e mensagem visível.
      expect(flow.phase, LoginPhase.selectIdentity);
      expect(flow.selectable, isNotEmpty);
      expect(flow.message, isNotNull);
      expect(flow.phoneE164, isNotEmpty);

      flow.reset();

      expect(flow.phase, LoginPhase.phone);
      expect(flow.loading, isFalse);
      expect(flow.message, isNull);
      expect(flow.phoneE164, isEmpty);
      expect(flow.selectable, isEmpty);
    });
  });

  group('Logout local — limpeza completa combinada', () {
    test('nenhum objeto autenticado permanece após clear() + reset()',
        () async {
      final session = SessionStore();
      final flow = LoginFlow(_FakeGateway(SessionEstablished(_id('a'))));

      // Simula uma sessão viva pós-login.
      session.set(_id('a'), 'jwt-hs256-token');
      await flow.submitPhone('+5511999999999');
      await flow.submitCode('123456');

      // Ação de Logout (exatamente o que main.onLogout executa).
      session.clear();
      flow.reset();

      // ✓ nenhum objeto autenticado permanece em memória
      expect(session.isAuthenticated, isFalse);
      expect(session.accessToken, isNull);
      expect(session.identity, isNull);
      expect(flow.phase, LoginPhase.phone);
      expect(flow.loading, isFalse);
      expect(flow.message, isNull);
      expect(flow.phoneE164, isEmpty);
      expect(flow.selectable, isEmpty);
    });
  });
}
