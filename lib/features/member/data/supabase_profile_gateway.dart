import 'package:goel_domain/goel_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/session_store.dart';

/// Salva o perfil do membro via Edge Function `save-profile`, autenticando com
/// o token da sessão. birth_date é dado de perfil (nunca autenticação).
class SupabaseProfileGateway implements MemberProfileGateway {
  final SupabaseClient _client;
  final SessionStore _session;

  SupabaseProfileGateway(this._client, this._session);

  @override
  Future<Result<MemberProfile, ProfileError>> save(MemberProfile profile) async {
    final token = _session.accessToken;
    if (token == null) return const Err(ProfileError.unauthenticated);

    try {
      final res = await _client.functions.invoke(
        'save-profile',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'fullName': profile.fullName,
          'birthDate': _formatDate(profile.birthDate),
          'whatsappOptIn': profile.whatsappOptIn,
        },
      );
      final data = Map<String, dynamic>.from(res.data as Map);
      if (data['status'] == 'saved') return Ok(profile);
      return Err(_mapReason(data['reason'] as String?));
    } catch (_) {
      return const Err(ProfileError.unavailable);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  ProfileError _mapReason(String? reason) => switch (reason) {
        'unauthenticated' => ProfileError.unauthenticated,
        'invalid' => ProfileError.invalid,
        _ => ProfileError.unavailable,
      };
}
