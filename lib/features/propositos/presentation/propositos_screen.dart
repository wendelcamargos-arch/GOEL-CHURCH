import 'package:flutter/material.dart';

/// Um propósito entregue no Monte (modelo de apresentação — sem domínio).
class Proposito {
  final String titulo;
  final String descricao;
  const Proposito(this.titulo, this.descricao);
}

/// Propósitos no Monte — página da campanha (padrão preto e branco).
///
/// APENAS camada de apresentação: intro da campanha + lista de propósitos de
/// EXEMPLO (o Owner injeta os reais depois). Sem envio nem persistência.
class PropositosScreen extends StatelessWidget {
  final List<Proposito>? propositos;

  const PropositosScreen({super.key, this.propositos});

  static const _exemplo = <Proposito>[
    Proposito('Jejum e oração',
        'Sete dias buscando a Deus em jejum, com um horário separado para oração.',),
    Proposito('Reconciliação',
        'Restaurar um relacionamento e perdoar de coração.',),
    Proposito('Generosidade',
        'Abençoar uma família em necessidade ao longo do mês.',),
    Proposito('Palavra diária',
        'Ler a Bíblia todos os dias e registrar o que Deus falar.',),
  ];

  @override
  Widget build(BuildContext context) {
    final lista = propositos ?? _exemplo;
    return Scaffold(
      appBar: AppBar(title: const Text('Propósitos no Monte')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              itemCount: lista.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) return const _Intro();
                return _PropositoCard(numero: i, proposito: lista[i - 1]);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.landscape_outlined,
                size: 32, color: scheme.onPrimaryContainer,),
          ),
          const SizedBox(height: 16),
          Text(
            'Propósitos no Monte',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Suba ao Monte com um alvo no coração. Registre o seu propósito e '
            'permaneça firme — Deus honra quem O busca.',
            style: textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PropositoCard extends StatelessWidget {
  final int numero;
  final Proposito proposito;
  const _PropositoCard({required this.numero, required this.proposito});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$numero',
                style: textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposito.titulo,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    proposito.descricao,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
