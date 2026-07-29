import 'package:flutter/material.dart';

/// Um grupo nas casas (célula / GC).
class GrupoLar {
  final String nome;
  final String dia;
  final String horario;
  final String bairro;
  final String lider;
  const GrupoLar({
    required this.nome,
    required this.dia,
    required this.horario,
    required this.bairro,
    required this.lider,
  });
}

/// Goel Home — grupos nas casas (células). Encontre um grupo perto de você e
/// participe.
///
/// APENAS camada de apresentação: os grupos chegam por parâmetro (com exemplos).
/// "Quero participar" avisa por enquanto; o encaminhamento real entra com o
/// slice de dados.
class GoelHomeScreen extends StatelessWidget {
  final List<GrupoLar>? grupos;
  const GoelHomeScreen({super.key, this.grupos});

  static const _exemplo = <GrupoLar>[
    GrupoLar(
      nome: 'GC Centro',
      dia: 'Terça',
      horario: '20h',
      bairro: 'Centro',
      lider: 'Pr. João e Ana',
    ),
    GrupoLar(
      nome: 'GC Jardim',
      dia: 'Quinta',
      horario: '19h30',
      bairro: 'Jardim das Flores',
      lider: 'Diác. Paulo',
    ),
    GrupoLar(
      nome: 'GC Jovens',
      dia: 'Sábado',
      horario: '18h',
      bairro: 'Vila Nova',
      lider: 'Marina e Rafael',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = grupos ?? _exemplo;

    return Scaffold(
      appBar: AppBar(title: const Text('Goel Home')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Palavra de acolhimento ao visitante.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.favorite_outline,
                              size: 20, color: scheme.onSurface,),
                          const SizedBox(width: 8),
                          Text(
                            'Você é bem-vindo(a)!',
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Que alegria ter você aqui! Na Goel você não é visita, é '
                        'família. Escolha um grupo nas casas, venha caminhar '
                        'conosco e faça parte dessa história. Estamos te '
                        'esperando de braços abertos.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Grupos nas casas',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'A Goel também acontece nos lares. Encontre um grupo perto de '
                  'você e participe.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final g in lista) ...[
                  _GrupoCard(grupo: g, onParticipar: () => _participar(context, g)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _participar(BuildContext context, GrupoLar g) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Em breve você poderá se inscrever no ${g.nome}.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),);
  }
}

class _GrupoCard extends StatelessWidget {
  final GrupoLar grupo;
  final VoidCallback onParticipar;
  const _GrupoCard({required this.grupo, required this.onParticipar});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                      color: scheme.primaryContainer, shape: BoxShape.circle,),
                  child: Icon(Icons.home_outlined,
                      size: 26, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    grupo.nome,
                    style: textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _linha(context, Icons.event, '${grupo.dia} · ${grupo.horario}'),
            const SizedBox(height: 4),
            _linha(context, Icons.place_outlined, grupo.bairro),
            const SizedBox(height: 4),
            _linha(context, Icons.person_outline, 'Líder: ${grupo.lider}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: onParticipar,
                child: const Text('Quero participar'),
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(texto,
              style:
                  textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),),
        ),
      ],
    );
  }
}
