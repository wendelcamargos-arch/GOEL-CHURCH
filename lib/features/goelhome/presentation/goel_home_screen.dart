import 'package:flutter/material.dart';

import '../../../core/whatsapp/whatsapp_links.dart';

/// Um grupo Goel Home (GC) e o link do seu grupo no WhatsApp.
class GrupoGc {
  final String nome;
  final String descricao;

  /// Link do grupo no WhatsApp (placeholder vazio até o Owner definir).
  final String link;
  const GrupoGc({
    required this.nome,
    required this.descricao,
    required this.link,
  });
}

/// Goel Home — grupos nas casas (células). Encontre um grupo perto de você e
/// participe: "Quero participar" abre direto o grupo no WhatsApp.
///
/// APENAS camada de apresentação: os links vivem no arquivo central
/// [WhatsAppLinks]. Enquanto o Owner não cria cada grupo, o app avisa "em
/// breve" com elegância (sem quebrar).
class GoelHomeScreen extends StatelessWidget {
  final List<GrupoGc>? grupos;
  const GoelHomeScreen({super.key, this.grupos});

  static const _gcs = <GrupoGc>[
    GrupoGc(
      nome: 'GC Senador Canedo',
      descricao: 'Um grupo Goel na sua região, em Senador Canedo.',
      link: WhatsAppLinks.gcSenadorCanedo,
    ),
    GrupoGc(
      nome: 'GC Goiânia',
      descricao: 'Um grupo Goel bem pertinho de você, em Goiânia.',
      link: WhatsAppLinks.gcGoiania,
    ),
    GrupoGc(
      nome: 'GC Jovens',
      descricao: 'A juventude Goel reunida para crescer na fé e na amizade.',
      link: WhatsAppLinks.gcJovens,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final lista = grupos ?? _gcs;

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
                  'A Goel também acontece nos lares. Escolha um grupo e toque em '
                  '"Quero participar" para entrar no grupo do WhatsApp.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                for (final g in lista) ...[
                  _GcCard(
                    grupo: g,
                    onParticipar: () => abrirGrupoWhatsApp(
                      context,
                      g.link,
                      aviso: 'O grupo ${g.nome} será disponibilizado em breve.',
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

class _GcCard extends StatelessWidget {
  final GrupoGc grupo;
  final VoidCallback onParticipar;
  const _GcCard({required this.grupo, required this.onParticipar});

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
            Text(
              grupo.descricao,
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: onParticipar,
                icon: const Icon(Icons.chat_outlined, size: 20),
                label: const Text('Quero participar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
