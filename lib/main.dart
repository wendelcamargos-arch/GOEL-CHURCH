import 'package:flutter/material.dart';

import 'app/goel_app.dart';
import 'core/env/app_env.dart';
import 'core/supabase/supabase_bootstrap.dart';
import 'features/auth/application/login_flow.dart';
import 'features/auth/data/session_store.dart';
import 'features/auth/data/supabase_auth_gateway.dart';
import 'features/member/application/cadastro_flow.dart';
import 'features/member/data/supabase_profile_gateway.dart';
import 'features/member/presentation/cadastro_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/content/data/local_verse_repository.dart';
import 'features/content/data/supabase_devotional_repository.dart';
import 'features/content/presentation/versiculo_screen.dart';
import 'features/content/presentation/devocionais_screen.dart';

/// Ponto de entrada da camada de entrega (Delivery Layer).
///
/// Composição raiz: quando o Supabase está configurado, monta o login
/// (Slice 03) e o cadastro (Slice 04). Sem credenciais, roda em modo
/// "não configurado".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final env = AppEnv.fromEnvironment();
  final supabaseConfigured = await SupabaseBootstrap.initialize(env);

  LoginFlow? loginFlow;
  WidgetBuilder? postLoginBuilder;

  if (supabaseConfigured) {
    final session = SessionStore();
    final client = SupabaseBootstrap.client;

    loginFlow = LoginFlow(SupabaseAuthGateway(client, session));

    final cadastroFlow = CadastroFlow(SupabaseProfileGateway(client, session));
    // Versículo do dia: tradução de DOMÍNIO PÚBLICO, offline-first (Opção A).
    final verseRepository = LocalVerseRepository();
    final devotionalRepository = SupabaseDevotionalRepository(client);

    postLoginBuilder = (_) => CadastroScreen(
          flow: cadastroFlow,
          postCadastroBuilder: (_) => HomeScreen(
            memberName: cadastroFlow.savedName,
            versiculoBuilder: (_) => VersiculoScreen(
              repository: verseRepository,
              sourceLabel: 'Almeida — domínio público',
            ),
            devocionalBuilder: (_) =>
                DevocionaisScreen(repository: devotionalRepository),
            // Logout LOCAL: limpa a sessão em memória e reinicia o fluxo de
            // login. Sem revogação server-side (escopo do MVP).
            onLogout: () {
              session.clear();
              loginFlow?.reset();
            },
          ),
        );
  }

  runApp(GoelApp(
    supabaseConfigured: supabaseConfigured,
    loginFlow: loginFlow,
    postLoginBuilder: postLoginBuilder,
  ),);
}
