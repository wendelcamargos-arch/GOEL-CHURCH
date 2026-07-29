import 'package:flutter/material.dart';

/// Um aniversariante (modelo de apresentação — sem domínio).
class Aniversariante {
  final String nome;
  final int dia; // dia do mês
  const Aniversariante(this.nome, this.dia);
}

/// Aniversariantes do mês — lista acolhedora (padrão preto e branco).
///
/// APENAS camada de apresentação. Os dados chegam por parâmetro, com uma lista
/// de EXEMPLO como padrão; o Owner injeta os reais na composição quando houver
/// o slice de dados, sem editar a tela.
class AniversariantesScreen extends StatelessWidget {
  final List<Aniversariante> itens;

  /// Rótulo do mês (ex.: "julho"). Nulo → usa o mês atual.
  final String? mesLabel;

  const AniversariantesScreen({
    super.key,
    this.itens = _exemplo,
    this.mesLabel,
  });

  static const _exemplo = <Aniversariante>[
    Aniversariante('Maria Vitória', 7),
    Aniversariante('Arthur Miguel', 12),
    Aniversariante('Dona Cleuza Ferreira', 20),
    Aniversariante('Pr. João Batista', 26),
  ];

  @override
  Widget build(BuildContext context) {
    final mes = mesLabel ?? _mesAtual();
    final ordenados = [...itens]..sort((a, b) => a.dia.compareTo(b.dia));

    return Scaffold(
      appBar: AppBar(title: const Text('Aniversariantes')),
      body: SafeArea(
        child: ordenados.isEmpty
            ? _EmptyState(mes: mes)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: ordenados.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) return _Intro(mes: mes);
                      return _AniversarianteCard(item: ordenados[i - 1]);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  final String mes;
  const _Intro({required this.mes});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aniversariantes de $mes',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Celebre com a nossa família. Deixe uma mensagem de carinho.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AniversarianteCard extends StatelessWidget {
  final Aniversariante item;
  const _AniversarianteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                _iniciais(item.nome),
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.nome,
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.cake_outlined, size: 22, color: scheme.onSurface),
                const SizedBox(height: 2),
                Text(
                  'Dia ${item.dia}',
                  style: textTheme.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String mes;
  const _EmptyState({required this.mes});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cake_outlined,
                  size: 40, color: scheme.onPrimaryContainer,),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum aniversariante em $mes.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _iniciais(String nome) {
  final partes = nome.trim().split(RegExp(r'\s+'));
  if (partes.isEmpty || partes.first.isEmpty) return '?';
  if (partes.length == 1) return partes.first[0].toUpperCase();
  return (partes.first[0] + partes.last[0]).toUpperCase();
}

String _mesAtual() {
  const meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  return meses[DateTime.now().month - 1];
}
