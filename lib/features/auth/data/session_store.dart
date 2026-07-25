import 'package:goel_domain/goel_domain.dart';

/// Sessão autenticada corrente (lado cliente).
///
/// Slice 03: mantida em memória para provar o fluxo de login fim-a-fim.
/// A persistência segura (flutter_secure_storage) e a amarração ao cliente
/// Supabase entram na etapa de sessão/refresh, junto com a revogação por estado
/// de identidade (A2.2B).
class SessionStore {
  IdentitySummary? _identity;
  String? _accessToken;

  bool get isAuthenticated => _accessToken != null;
  IdentitySummary? get identity => _identity;
  String? get accessToken => _accessToken;

  void set(IdentitySummary identity, String accessToken) {
    _identity = identity;
    _accessToken = accessToken;
  }

  void clear() {
    _identity = null;
    _accessToken = null;
  }
}
