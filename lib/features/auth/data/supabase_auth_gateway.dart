import 'package:goel_domain/goel_domain.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'session_store.dart';

/// Implementação do contrato [AuthGateway] sobre as Edge Functions do Supabase.
///
/// A camada de dados traduz HTTP ↔ domínio. O domínio (Dart puro) não conhece
/// Supabase nem Meta. Nenhum segredo aqui: o token da Meta é server-side.
class SupabaseAuthGateway implements AuthGateway {
  final SupabaseClient _client;
  final SessionStore _session;

  String? _pendingSelectionToken;

  SupabaseAuthGateway(this._client, this._session);

  @override
  Future<Result<OtpRequestOutcome, AuthFailure>> requestOtp(
    String phoneE164,
  ) async {
    try {
      await _client.functions.invoke('request-otp', body: {'phone': phoneE164});
      return const Ok(OtpRequestOutcome.uniform());
    } catch (_) {
      return const Err(AuthFailure.channelUnavailable);
    }
  }

  @override
  Future<Result<VerificationOutcome, AuthFailure>> verifyOtp(
    String phoneE164,
    String code,
  ) async {
    try {
      final res = await _client.functions.invoke(
        'verify-otp',
        body: {'phone': phoneE164, 'code': code},
      );
      final data = res.data as Map<String, dynamic>;

      switch (data['status']) {
        case 'failed':
          return Err(_mapReason(data['reason'] as String?));
        case 'session':
          final identity = _identityFrom(data['identity'] as Map<String, dynamic>);
          _session.set(identity, data['accessToken'] as String);
          return Ok(SessionEstablished(identity));
        case 'select_identity':
          _pendingSelectionToken = data['selectionToken'] as String?;
          final ids = (data['identities'] as List<dynamic>)
              .map((e) => _identityFrom(e as Map<String, dynamic>))
              .toList();
          return Ok(NeedsIdentitySelection(ids));
        default:
          return const Err(AuthFailure.unknown);
      }
    } catch (_) {
      return const Err(AuthFailure.channelUnavailable);
    }
  }

  @override
  Future<Result<SessionEstablished, AuthFailure>> selectIdentity(
    String canonicalId,
  ) async {
    final token = _pendingSelectionToken;
    if (token == null) return const Err(AuthFailure.unknown);
    try {
      final res = await _client.functions.invoke(
        'select-identity',
        body: {'selectionToken': token, 'canonicalId': canonicalId},
      );
      final data = res.data as Map<String, dynamic>;
      if (data['status'] == 'session') {
        final identity = _identityFrom(data['identity'] as Map<String, dynamic>);
        _session.set(identity, data['accessToken'] as String);
        _pendingSelectionToken = null;
        return Ok(SessionEstablished(identity));
      }
      return const Err(AuthFailure.unknown);
    } catch (_) {
      return const Err(AuthFailure.channelUnavailable);
    }
  }

  IdentitySummary _identityFrom(Map<String, dynamic> data) => IdentitySummary(
        canonicalId: data['canonicalId'] as String,
        displayName: (data['displayName'] as String?) ?? 'Minha conta',
        // Identidades retornadas já são selecionáveis (filtradas server-side).
        state: IdentityState.active,
      );

  AuthFailure _mapReason(String? reason) => switch (reason) {
        'codeExpired' => AuthFailure.codeExpired,
        'invalidCode' => AuthFailure.invalidCode,
        'tooManyAttempts' => AuthFailure.tooManyAttempts,
        _ => AuthFailure.unknown,
      };
}
