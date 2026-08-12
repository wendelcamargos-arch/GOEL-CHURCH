import 'package:flutter/material.dart';

/// "Sobre a Bíblia" — origem, tradução e atribuição da fonte (obrigatório).
class SobreBibliaScreen extends StatelessWidget {
  const SobreBibliaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    Widget bloco(String titulo, String corpo) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),),
              const SizedBox(height: 6),
              Text(corpo,
                  style: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant, height: 1.45,),),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Sobre a Bíblia')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                bloco('Tradução',
                    'João Ferreira de Almeida — edição de 1911 (revista).',),
                bloco('Licença',
                    'Texto em Domínio Público. Obra centenária, livre para uso '
                    'pessoal e comercial.',),
                bloco('Digitalização',
                    'A digitalização utilizada é do projeto JFAAL. As Escrituras '
                    'em português são da JFAAL, © Marcos Cristiano Alves '
                    'Ferreira, sob Licença Creative Commons Atribuição 3.0 '
                    'Brasil.',),
                bloco('Cânon',
                    '66 livros · 1.189 capítulos · 31.102 versículos.',),
                bloco('Funcionamento',
                    'Todo o conteúdo funciona 100% offline, sem depender de '
                    'internet.',),
                const SizedBox(height: 8),
                Text('Goel Church',
                    textAlign: TextAlign.center,
                    style: textTheme.labelLarge
                        ?.copyWith(color: scheme.onSurfaceVariant),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
