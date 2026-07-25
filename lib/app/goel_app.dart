import 'package:flutter/material.dart';

import '../bootstrap/bootstrap_screen.dart';
import '../features/auth/application/login_flow.dart';
import '../features/auth/presentation/login_gate.dart';
import 'theme/app_theme.dart';

/// Raiz da camada de entrega (Delivery Layer).
///
/// Framework Independence (ADR GOEL-ARCH-P2A-01 / P2A-02B-A1): esta camada
/// apresenta e coleta; ela NÃO contém regra de negócio. As regras vivem no
/// pacote `goel_domain` (Dart puro).
class GoelApp extends StatelessWidget {
  /// Indica se a plataforma Supabase foi inicializada (Slice 02).
  final bool supabaseConfigured;

  /// Fluxo de login (Slice 03), injetado quando o Supabase está configurado.
  /// Nulo → cai na tela de bootstrap (útil em testes e sem credenciais).
  final LoginFlow? loginFlow;

  const GoelApp({super.key, this.supabaseConfigured = false, this.loginFlow});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goel Church',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: loginFlow != null
          ? LoginGate(flow: loginFlow!)
          : BootstrapScreen(supabaseConfigured: supabaseConfigured),
    );
  }
}
