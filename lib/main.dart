import 'package:flutter/widgets.dart';

import 'app/goel_app.dart';
import 'core/env/app_env.dart';
import 'core/supabase/supabase_bootstrap.dart';

/// Ponto de entrada da camada de entrega (Delivery Layer).
///
/// Slice 02 — inicializa a plataforma Supabase (se configurada) antes de
/// levantar a UI. Sem credenciais, o app roda em modo "não configurado".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.fromEnvironment();
  final supabaseConfigured = await SupabaseBootstrap.initialize(env);

  runApp(GoelApp(supabaseConfigured: supabaseConfigured));
}
