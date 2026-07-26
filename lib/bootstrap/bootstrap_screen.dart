import 'package:flutter/material.dart';

/// Splash / tela de abertura do Goel Church.
///
/// Primeira impressão do app para a comunidade: marca + acolhimento, sem ruído
/// técnico. Para o usuário final a tela é limpa. O parâmetro
/// [supabaseConfigured] apenas exibe um aviso DISCRETO de desenvolvimento quando
/// o backend não está configurado (nunca aparece em produção configurada).
class BootstrapScreen extends StatelessWidget {
  final bool supabaseConfigured;

  const BootstrapScreen({super.key, this.supabaseConfigured = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Marca — placeholder do logotipo oficial da igreja (substituir
              // por asset quando disponível). Semântica para leitor de tela.
              Semantics(
                label: 'Goel Church',
                image: true,
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.church_outlined,
                    size: 62,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Goel Church',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Uma igreja para você frequentar e uma família para você '
                'pertencer.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              const Spacer(flex: 3),

              // Indicação calma de carregamento.
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Aviso DISCRETO apenas em ambiente de desenvolvimento sem backend.
              if (!supabaseConfigured)
                Text(
                  'Ambiente de desenvolvimento — backend não configurado',
                  textAlign: TextAlign.center,
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
