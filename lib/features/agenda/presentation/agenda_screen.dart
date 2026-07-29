import 'package:flutter/material.dart';

/// Um evento da agenda (modelo de apresentação — sem domínio).
class Evento {
  final String titulo;
  final DateTime quando;
  final String local;
  const Evento({
    required this.titulo,
    required this.quando,
    required this.local,
  });
}

/// Agenda — próximos eventos da Goel Church (padrão preto e branco).
///
/// APENAS camada de apresentação. Os eventos chegam por parâmetro, com uma
/// lista de EXEMPLO como padrão; o Owner injeta os reais na composição quando
/// houver o slice de dados, sem editar a tela.
class AgendaScreen extends StatelessWidget {
  /// Nulo → usa a lista de EXEMPLO. Uma lista vazia → estado vazio.
  final List<Evento>? eventos;

  const AgendaScreen({super.key, this.eventos});

  static final _exemplo = <Evento>[
    Evento(
      titulo: 'Culto de Celebração',
      quando: DateTime(2026, 8, 2, 18, 0),
      local: 'Templo — Goel Church',
    ),
    Evento(
      titulo: 'Encontro de Jovens',
      quando: DateTime(2026, 8, 8, 19, 30),
      local: 'Salão de eventos',
    ),
    Evento(
      titulo: 'Escola Bíblica',
      quando: DateTime(2026, 8, 9, 9, 30),
      local: 'Templo — Goel Church',
    ),
    Evento(
      titulo: 'Culto de Ação de Graças',
      quando: DateTime(2026, 8, 15, 20, 0),
      local: 'Templo — Goel Church',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ordenados = [...(eventos ?? _exemplo)]
      ..sort((a, b) => a.quando.compareTo(b.quando));

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda')),
      body: SafeArea(
        child: ordenados.isEmpty
            ? const _EmptyState()
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: ordenados.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      if (i == 0) return const _Intro();
                      return _EventoCard(evento: ordenados[i - 1]);
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximos encontros',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Participe da vida da nossa família. Esperamos por você.',
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Evento evento;
  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloco de data.
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${evento.quando.day}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _mesAbrev(evento.quando.month),
                    style: textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.titulo,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  _linha(context, Icons.schedule,
                      '${_diaSemana(evento.quando)} · ${_hora(evento.quando)}',),
                  const SizedBox(height: 2),
                  _linha(context, Icons.place_outlined, evento.local),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(BuildContext context, IconData icon, String texto) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            texto,
            style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              child: Icon(Icons.event_note_outlined,
                  size: 40, color: scheme.onPrimaryContainer,),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum evento agendado por enquanto.',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _hora(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _mesAbrev(int m) {
  const meses = [
    'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
    'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ',
  ];
  return meses[m - 1];
}

String _diaSemana(DateTime d) {
  const dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  return dias[d.weekday - 1];
}
