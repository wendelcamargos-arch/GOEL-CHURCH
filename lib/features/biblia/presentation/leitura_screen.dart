import 'package:flutter/material.dart';

import '../data/biblia_livros.dart';

/// Leitura de um capítulo — mostra os versículos (número + palavra).
///
/// A estrutura de leitura está pronta; o TEXTO real dos versículos (Almeida —
/// domínio público) será carregado do conjunto de dados no slice de conteúdo.
/// Por enquanto, exibe uma prévia ilustrativa e um aviso claro.
class LeituraScreen extends StatelessWidget {
  final LivroBiblia livro;
  final int capitulo;

  const LeituraScreen({super.key, required this.livro, required this.capitulo});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Prévia ilustrativa (não é o texto bíblico real — chega com os dados).
    const previa = 5;

    return Scaffold(
      appBar: AppBar(title: Text('${livro.nome} $capitulo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                // Aviso honesto sobre o texto em preparação.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: scheme.onSurfaceVariant,),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'O texto bíblico (Almeida) será carregado aqui em '
                          'breve. Abaixo, uma prévia do formato de leitura.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (var v = 1; v <= previa; v++) ...[
                  _Versiculo(numero: v),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Versiculo extends StatelessWidget {
  final int numero;
  const _Versiculo({required this.numero});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 18),
        children: [
          TextSpan(
            text: '$numero  ',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: 'Versículo em breve — o texto completo será exibido aqui '
                'quando o conteúdo bíblico for carregado.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
