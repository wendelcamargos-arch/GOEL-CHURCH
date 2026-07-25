import 'package:flutter/widgets.dart';

import 'app/goel_app.dart';
import 'core/env/app_env.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'features/auth/application/login_flow.dart';
import 'features/auth/data/session_store.dart';
import 'features/auth/data/supabase_auth_gateway.dart';

/// Ponto de entrada da camada de entrega (Delivery Layer).
///
/// Slice 03 — quando o Supabase está configurado, monta o fluxo de login por
/// WhatsApp OTP. Sem credenciais, o app roda em modo "não configurado".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.fromEnvironment();
  final supabaseConfigured = await SupabaseBootstrap.initialize(env);

  LoginFlow? loginFlow;
  if (supabaseConfigured) {
    final session = SessionStore();
    final gateway = SupabaseAuthGateway(SupabaseBootstrap.client, session);
    loginFlow = LoginFlow(gateway);
  }

  runApp(GoelApp(
    supabaseConfigured: supabaseConfigured,
    loginFlow: loginFlow,
  ));
}
