import 'package:flutter/material.dart';

import '../../agenda/presentation/agenda_screen.dart';
import '../../aniversariantes/presentation/aniversariantes_screen.dart';
import '../../biblia/presentation/biblia_screen.dart';
import '../../contribua/presentation/contribua_screen.dart';
import '../../devocional_tematico/presentation/devocional_tematico_screen.dart';
import '../../escalas/presentation/escalas_screen.dart';
import '../../gabinete/presentation/gabinete_screen.dart';
import '../../galeria/presentation/galeria_screen.dart';
import '../../goelhome/presentation/goel_home_screen.dart';
import '../../membros/presentation/membros_screen.dart';
import '../../oracao/presentation/oracao_screen.dart';
import '../../palavras/presentation/palavras_screen.dart';
import '../../pregacoes/presentation/pregacoes_screen.dart';
import '../../propositos/presentation/propositos_screen.dart';
import '../../redes/presentation/redes_screen.dart';
import '../../servo/presentation/servo_screen.dart';
import '../../testemunho/presentation/testemunho_screen.dart';
import 'coming_soon_view.dart';
import 'home_screen.dart';

/// Casca principal do app (pós-login) — navegação por barra inferior.
///
/// APENAS camada de apresentação/experiência. O contrato de composição é
/// preservado: recebe [memberName] + os builders das jornadas + [onLogout],
/// exatamente como a Home recebia. Domínio, dados, auth e arquitetura intactos.
///
/// Barra inferior no padrão dos apps de referência: cinco destinos com o
/// **Início** central e elevado. Recursos ainda sem tela aparecem como
/// "Em breve" — o app já se navega por inteiro.
class MainShell extends StatefulWidget {
  final String? memberName;
  final WidgetBuilder? versiculoBuilder;
  final WidgetBuilder? devocionalBuilder;
  final VoidCallback? onLogout;

  /// Aba inicial (2 = Início, central). Exposto para composição/preview.
  final int initialIndex;

  const MainShell({
    super.key,
    this.memberName,
    this.versiculoBuilder,
    this.devocionalBuilder,
    this.onLogout,
    this.initialIndex = 2,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Início é o destino central (índice 2) e o padrão ao abrir.
  late int _index = widget.initialIndex;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      const PalavrasScreen(),
      const BibliaScreen(),
      HomeScreen(
        memberName: widget.memberName,
        versiculoBuilder: widget.versiculoBuilder,
        devocionalBuilder: widget.devocionalBuilder,
      ),
      const ContribuaScreen(),
      _MaisTab(
        memberName: widget.memberName,
        versiculoBuilder: widget.versiculoBuilder,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: _GoelBottomBar(current: _index, onSelect: _select),
    );
  }
}

/// Barra inferior custom: cinco destinos, o central elevado (estilo referência).
class _GoelBottomBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onSelect;

  const _GoelBottomBar({required this.current, required this.onSelect});

  static const _items = <(IconData, IconData, String)>[
    (Icons.play_circle_outline, Icons.play_circle, 'Palavras'),
    (Icons.menu_book_outlined, Icons.menu_book, 'Bíblia'),
    (Icons.home_outlined, Icons.home, 'Início'),
    (Icons.favorite_outline, Icons.favorite, 'Contribua'),
    (Icons.segment, Icons.segment, 'Mais'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomInset, top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _items.length; i++)
            i == 2
                ? _CenterItem(
                    icon: _items[i].$2,
                    label: _items[i].$3,
                    selected: current == i,
                    onTap: () => onSelect(i),
                  )
                : _BarItem(
                    icon: current == i ? _items[i].$2 : _items[i].$1,
                    label: _items[i].$3,
                    selected: current == i,
                    onTap: () => onSelect(i),
                  ),
        ],
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 26),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Destino central elevado (Início).
class _CenterItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CenterItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkResponse(
          onTap: onTap,
          radius: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: scheme.onPrimary, size: 28),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -6),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? scheme.primary : scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aba "Mais": índice completo de recursos + sair. Recursos com tela real
/// navegam; os demais mostram "Em breve".
class _MaisTab extends StatelessWidget {
  final String? memberName;
  final WidgetBuilder? versiculoBuilder;
  final VoidCallback? onLogout;

  const _MaisTab({
    required this.memberName,
    required this.versiculoBuilder,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    final entries = <_MaisEntry>[
      _MaisEntry(Icons.auto_stories_outlined, 'Versículo do dia', versiculoBuilder),
      _MaisEntry(Icons.event_available_outlined, 'Escalas',
          (_) => const EscalasScreen(),),
      _MaisEntry(Icons.volunteer_activism_outlined, 'Oração',
          (_) => const OracaoScreen(),),
      _MaisEntry(Icons.home_outlined, 'Goel Home',
          (_) => const GoelHomeScreen(),),
      _MaisEntry(Icons.support_agent, 'Gabinete Pastoral',
          (_) => const GabineteScreen(),),
      _MaisEntry(Icons.handshake_outlined, 'Quero ser Servo',
          (_) => const ServoScreen(),),
      _MaisEntry(Icons.campaign_outlined, 'Pregações',
          (_) => const PregacoesScreen(),),
      _MaisEntry(Icons.record_voice_over_outlined, 'Testemunho',
          (_) => const TestemunhoScreen(),),
      _MaisEntry(Icons.celebration_outlined, 'Eventos',
          (_) => const AgendaScreen(),),
      _MaisEntry(Icons.event_note_outlined, 'Agenda',
          (_) => const AgendaScreen(),),
      _MaisEntry(Icons.pix, 'Pix', (_) => const ContribuaScreen()),
      _MaisEntry(Icons.cake_outlined, 'Aniversariantes',
          (_) => const AniversariantesScreen(),),
      _MaisEntry(Icons.photo_library_outlined, 'Fotos e vídeos',
          (_) => const GaleriaScreen(),),
      _MaisEntry(Icons.public, 'Redes Sociais',
          (_) => const RedesScreen(),),
      _MaisEntry(Icons.people_alt_outlined, 'Membros',
          (_) => const MembrosScreen(),),
      _MaisEntry(Icons.self_improvement_outlined, 'Devocional Homens',
          (_) => const DevocionalTematicoScreen(
                appBarTitle: 'Devocional Homens',
                introTitulo: 'Para os homens da casa',
                introSubtitulo: 'Uma palavra para liderar com fé e integridade.',
                itens: _devocionalHomens,
              ),),
      _MaisEntry(Icons.self_improvement_outlined, 'Devocional Mulheres',
          (_) => const DevocionalTematicoScreen(
                appBarTitle: 'Devocional Mulheres',
                introTitulo: 'Para as mulheres da casa',
                introSubtitulo: 'Uma palavra de força, fé e cuidado.',
                itens: _devocionalMulheres,
              ),),
      _MaisEntry(Icons.landscape_outlined, 'Propósitos no Monte',
          (_) => const PropositosScreen(),),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topInset + 24, 20, 32),
      children: [
        Text(
          'Mais',
          style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Tudo o que a Goel Church tem para você.',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            for (final e in entries)
              _MaisTile(
                entry: e,
                onTap: () => _open(context, e),
              ),
          ],
        ),
        if (onLogout != null) ...[
          const SizedBox(height: 24),
          _LogoutButton(onTap: () => _logout(context)),
        ],
      ],
    );
  }

  void _open(BuildContext context, _MaisEntry e) {
    final WidgetBuilder destination = e.builder ??
        (_) => ComingSoonScreen(icon: e.icon, title: e.label);
    Navigator.of(context).push(MaterialPageRoute(builder: destination));
  }

  void _logout(BuildContext context) {
    // Logout LOCAL (sem revogação server-side): limpa a sessão e o estado, e
    // volta à raiz da navegação (Login), impedindo o "Voltar".
    onLogout?.call();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _MaisEntry {
  final IconData icon;
  final String label;
  final WidgetBuilder? builder;
  const _MaisEntry(this.icon, this.label, this.builder);
}

// Conteúdo de EXEMPLO das trilhas devocionais (o Owner substitui depois).
const _devocionalHomens = <ItemDevocional>[
  ItemDevocional(
    'Liderança que serve',
    'O maior no Reino é aquele que serve. Liderar a sua casa começa de '
        'joelhos, buscando a Deus antes de decidir. Seja um homem de oração '
        'e a sua família colherá os frutos.',
    autor: 'Goel Church',
  ),
  ItemDevocional(
    'Integridade no oculto',
    'O caráter se prova onde ninguém vê. Aquilo que você é no secreto é o '
        'que Deus recompensa em público. Guarde o seu coração.',
    autor: 'Goel Church',
  ),
];

const _devocionalMulheres = <ItemDevocional>[
  ItemDevocional(
    'Força e dignidade',
    'A mulher virtuosa se reveste de força e dignidade e sorri diante do '
        'futuro. A sua confiança não está nas circunstâncias, mas no Deus '
        'que a sustenta.',
    autor: 'Goel Church',
  ),
  ItemDevocional(
    'O valor do descanso',
    'Você não precisa carregar tudo sozinha. Entregue os seus cuidados a '
        'Deus e descanse — Ele cuida de você com amor eterno.',
    autor: 'Goel Church',
  ),
];

class _MaisTile extends StatelessWidget {
  final _MaisEntry entry;
  final VoidCallback onTap;

  const _MaisTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final soon = entry.builder == null;
    return Semantics(
      button: true,
      label: soon ? '${entry.label}, em breve' : 'Abrir ${entry.label}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(entry.icon, size: 28, color: scheme.primary),
                    if (soon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2,),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Em breve',
                          style: textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
                Text(
                  entry.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.logout),
      label: const Text('Sair'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: scheme.error,
        side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
      ),
    );
  }
}
