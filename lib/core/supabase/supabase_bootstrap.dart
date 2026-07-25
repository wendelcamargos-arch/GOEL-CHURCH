import 'package:supabase_flutter/supabase_flutter.dart';

import '../env/app_env.dart';

/// Inicializa a plataforma Supabase (Platform-as-a-Foundation).
///
/// A camada de dados consome o Supabase por aqui; o domínio (Dart puro)
/// permanece independente deste detalhe de infraestrutura.
class SupabaseBootstrap {
  const SupabaseBootstrap._();

  /// Inicializa o Supabase se o ambiente estiver configurado.
  ///
  /// Retorna `true` se conectado; `false` (degradação graciosa) quando as
  /// credenciais não foram fornecidas — o app roda isolado sem quebrar.
  static Future<bool> initialize(AppEnv env) async {
    if (!env.isConfigured) return false;
    await Supabase.initialize(
      url: env.supabaseUrl,
      anonKey: env.supabaseAnonKey,
    );
    return true;
  }

  /// Cliente Supabase já inicializado. Só use após [initialize] retornar true.
  static SupabaseClient get client => Supabase.instance.client;
}
