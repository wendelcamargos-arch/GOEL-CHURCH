import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Um ministério que tem escala de serviço.
class Ministerio {
  final String nome;
  final IconData icon;
  final List<String> equipe; // membros disponíveis (exemplo)
  const Ministerio(this.nome, this.icon, this.equipe);
}

/// Escalas dos ministérios (padrão preto e branco).
///
/// APENAS camada de apresentação. A escala é montada por um RODÍZIO justo e
/// automático (round-robin) sobre a equipe — assim ela "roda" sozinha, sem
/// sobrecarregar ninguém. Aqui os dados são de EXEMPLO; a edição, a persistência
/// e o compartilhamento definitivo entram com o slice de dados.
class EscalasScreen extends StatelessWidget {
  final List<Ministerio>? ministerios;
  const EscalasScreen({super.key, this.ministerios});

  static const _exemplo = <Ministerio>[
    Ministerio('Mídia', Icons.videocam_outlined,
        ['Lucas', 'Marina', 'Rafael', 'Bianca'],),
    Ministerio('Servos', Icons.groups_2_outlined,
        ['Ana', 'Pedro', 'Júlia', 'Tiago', 'Sara'],),
    Ministerio('Cozinha', Icons.restaurant_outlined,
        ['Dona Cleuza', 'Marta', 'Rosa', 'Cida'],),
    Ministerio('Sala das Crianças', Icons.child_care_outlined,
        ['Priscila', 'Débora', 'Ester', 'Noemi'],),
    Ministerio('Obreiros', Icons.badge_outlined,
        ['Pr. João', 'Diác. Paulo', 'Presb. Mateus'],),
    Ministerio('Músicos', Icons.music_note_outlined,
        ['Davi', 'Asafe', 'Mirian', 'Levi'],),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = ministerios ?? _exemplo;

    return Scaffold(
      appBar: AppBar(title: const Text('Escalas')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Text(
                  'Escalas dos ministérios',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'A escala roda automaticamente por rodízio, sem sobrecarregar '
                  'ninguém. Ajuste se precisar e compartilhe no grupo.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final m in lista) ...[
                  _MinisterioCard(
                    ministerio: m,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EscalaMinisterioScreen(ministerio: m),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinisterioCard extends StatelessWidget {
  final Ministerio ministerio;
  final VoidCallback onTap;
  const _MinisterioCard({required this.ministerio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir escala de ${ministerio.nome}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(ministerio.icon,
                      size: 28, color: scheme.onPrimaryContainer,),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ministerio.nome,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ministerio.equipe.length} pessoas na equipe',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detalhe da escala de um ministério: próximas datas + rodízio + compartilhar.
class EscalaMinisterioScreen extends StatelessWidget {
  final Ministerio ministerio;
  const EscalaMinisterioScreen({super.key, required this.ministerio});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final escala = _gerarRodizio(ministerio, DateTime.now(), 4);

    return Scaffold(
      appBar: AppBar(title: Text('Escala — ${ministerio.nome}')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.autorenew,
                          size: 20, color: scheme.onSurfaceVariant,),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Rodízio automático: cada pessoa serve na sua vez, '
                          'de forma equilibrada.',
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                for (final e in escala) ...[
                  _EscalaCard(
                    data: e.$1,
                    membros: e.$2,
                    onAjustar: () => _snack(context, 'Ajuste de escala em breve.'),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _compartilhar(context, escala),
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar no grupo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),);
  }

  Future<void> _compartilhar(
      BuildContext context, List<(String, List<String>)> escala,) async {
    final buffer = StringBuffer('*Escala — ${ministerio.nome}*\n\n');
    for (final e in escala) {
      buffer.writeln('${e.$1}: ${e.$2.join(', ')}');
    }
    final texto = Uri.encodeComponent(buffer.toString());
    final uri = Uri.parse('https://wa.me/?text=$texto');
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('falha');
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o WhatsApp agora.'),
          behavior: SnackBarBehavior.floating,
        ),);
    }
  }
}

class _EscalaCard extends StatelessWidget {
  final String data;
  final List<String> membros;
  final VoidCallback onAjustar;
  const _EscalaCard({
    required this.data,
    required this.membros,
    required this.onAjustar,
  });

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
                Icon(Icons.event, size: 20, color: scheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: onAjustar,
                  child: const Text('Ajustar'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in membros)
                  Chip(
                    label: Text(m),
                    backgroundColor: scheme.surfaceContainerHighest,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Gera um rodízio justo (round-robin) da equipe nas próximas [qtd] datas.
List<(String, List<String>)> _gerarRodizio(
    Ministerio m, DateTime hoje, int qtd,) {
  const meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  // Próximos domingos a partir de hoje.
  final domingos = <DateTime>[];
  var d = hoje;
  while (domingos.length < qtd) {
    d = d.add(const Duration(days: 1));
    if (d.weekday == DateTime.sunday) domingos.add(d);
  }
  // Quantas pessoas por data (2, ou menos se a equipe for pequena).
  final porData = m.equipe.length >= 2 ? 2 : 1;
  final resultado = <(String, List<String>)>[];
  var idx = 0;
  for (final dom in domingos) {
    final membros = <String>[];
    for (var k = 0; k < porData; k++) {
      membros.add(m.equipe[idx % m.equipe.length]);
      idx++;
    }
    final label = '${dom.day} ${meses[dom.month - 1]} · Domingo';
    resultado.add((label, membros));
  }
  return resultado;
}
