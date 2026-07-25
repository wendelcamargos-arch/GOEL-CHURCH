import 'package:flutter/material.dart';

/// Tela de bootstrap do Slice 01 — placeholder neutro que confirma que a
/// aplicação inicializa e o tema é aplicado.
///
/// NÃO é a Home (Slice 05) nem qualquer funcionalidade de slices posteriores.
class BootstrapScreen extends StatelessWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                Text('MVP • Slice 01 — Bootstrap', style: textTheme.labelMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
