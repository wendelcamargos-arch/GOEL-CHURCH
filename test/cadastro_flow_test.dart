import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/member/application/cadastro_flow.dart';
import 'package:goel_domain/goel_domain.dart';

class _FakeProfileGateway implements MemberProfileGateway {
  final bool ok;
  _FakeProfileGateway(this.ok);

  @override
  Future<Result<MemberProfile, ProfileError>> save(MemberProfile profile) async =>
      ok ? Ok(profile) : const Err(ProfileError.unavailable);
}

void main() {
  DateTime now() => DateTime(2026, 1, 1);

  test('cadastro válido conclui', () async {
    final flow = CadastroFlow(_FakeProfileGateway(true), now: now);
    await flow.submit(
      fullName: 'Ana Maria',
      birthDate: DateTime(1950, 5, 10),
      whatsappOptIn: true,
    );
    expect(flow.done, isTrue);
    expect(flow.message, isNull);
  });

  test('cadastro inválido não conclui e mostra mensagem', () async {
    final flow = CadastroFlow(_FakeProfileGateway(true), now: now);
    await flow.submit(fullName: '', birthDate: null, whatsappOptIn: true);
    expect(flow.done, isFalse);
    expect(flow.message, isNotNull);
  });

  test('falha ao salvar mostra mensagem', () async {
    final flow = CadastroFlow(_FakeProfileGateway(false), now: now);
    await flow.submit(
      fullName: 'Ana',
      birthDate: DateTime(1950, 5, 10),
      whatsappOptIn: false,
    );
    expect(flow.done, isFalse);
    expect(flow.message, isNotNull);
  });
}
