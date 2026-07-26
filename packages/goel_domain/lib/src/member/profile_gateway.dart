import '../shared/result.dart';
import 'member_profile.dart';

/// Falhas possíveis ao salvar o perfil.
enum ProfileError { unauthenticated, invalid, unavailable }

/// Contrato de persistência do perfil do membro (Stable Module Boundaries).
///
/// O domínio define O QUE; a camada de dados (Supabase) define o COMO.
abstract interface class MemberProfileGateway {
  Future<Result<MemberProfile, ProfileError>> save(MemberProfile profile);
}
