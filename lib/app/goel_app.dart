import 'package:flutter/material.dart';

import '../bootstrap/bootstrap_screen.dart';
import 'theme/app_theme.dart';

/// Raiz da camada de entrega (Delivery Layer).
///
/// Framework Independence (ADR GOEL-ARCH-P2A-01 / P2A-02B-A1): esta camada
/// apresenta e coleta; ela NÃO contém regra de negócio. As regras vivem no
/// pacote `goel_domain` (Dart puro).
class GoelApp extends StatelessWidget {
  /// Indica se a plataforma Supabase foi inicializada (Slice 02).
  final bool supabaseConfigured;

  const GoelApp({super.key, this.supabaseConfigured = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goel Church',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Slice 01/02: tela de bootstrap neutra. A Home é do Slice 05.
      home: BootstrapScreen(supabaseConfigured: supabaseConfigured),
    );
  }
}
