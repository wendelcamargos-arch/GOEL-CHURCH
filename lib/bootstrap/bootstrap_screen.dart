import 'package:flutter/material.dart';

/// Tela de bootstrap dos Slices 01–02 — placeholder neutro que confirma que a
/// aplicação inicializa, o tema é aplicado e mostra o estado da integração com
/// a plataforma Supabase.
///
/// NÃO é a Home (Slice 05) nem qualquer funcionalidade de slices posteriores.
class BootstrapScreen extends StatelessWidget {
  final bool supabaseConfigured;

  const BootstrapScreen({super.key, this.supabaseConfigured = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Goel Church', style: textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  'Uma igreja para você frequentar e uma família para você '
                  'pertencer.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _SupabaseStatus(
                  configured: supabaseConfigured,
                  onColor: scheme.primary,
                  offColor: scheme.error,
                ),
                const SizedBox(height: 16),
                Text('MVP • Slice 02 — Supabase', style: textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupabaseStatus extends StatelessWidget {
  final bool configured;
  final Color onColor;
  final Color offColor;

  const _SupabaseStatus({
    required this.configured,
    required this.onColor,
    required this.offColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = configured ? onColor : offColor;
    final label = configured
        ? 'Supabase: conectado'
        : 'Supabase: não configurado\n(defina SUPABASE_URL e SUPABASE_ANON_KEY)';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(configured ? Icons.check_circle : Icons.info_outline, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
