import 'package:flutter/material.dart';

/// Home (Slice 05) — hub acolhedor após login/cadastro.
///
/// APENAS camada de apresentação/experiência — contrato preservado
/// (memberName + builders de jornada + onLogout). Continuidade visual com as
/// Sprints anteriores via cabeçalho de marca (fachada + logo); corpo claro para
/// leitura confortável no uso diário. Acessibilidade (todas as idades): alvos
/// amplos, tipografia grande, contraste e Semantics.
class HomeScreen extends StatelessWidget {
  final String? memberName;

  /// Destinos das jornadas, injetados pela composição raiz conforme os slices
  /// vão existindo. Nulo → placeholder "Em breve".
  final WidgetBuilder? versiculoBuilder;
  final WidgetBuilder? devocionalBuilder;

  /// Ação de limpeza da sessão local (Logout). A navegação de volta ao Login é
  /// feita pela própria Home após chamar esta ação.
  final VoidCallback? onLogout;

  const HomeScreen({
    super.key,
    this.memberName,
    this.versiculoBuilder,
    this.devocionalBuilder,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final greeting = (memberName == null || memberName!.trim().isEmpty)
        ? 'Bem-vindo(a) à Goel Church'
        : 'Olá, ${memberName!.split(' ').first}';

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(greeting: greeting, onLogout: onLogout, onLogoutTap: _logout),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: LayoutBuilder(
                builder: (context, c) {
                  final cards = [
                    _HomeCard(
                      icon: Icons.auto_stories_outlined,
                      title: 'Versículo do dia',
                      subtitle: 'Uma palavra para hoje',
                      onTap: () =>
                          _go(context, 'Versículo do dia', versiculoBuilder),
                    ),
                    _HomeCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Devocionais',
                      subtitle: 'Leituras para o seu dia',
                      onTap: () => _go(context, 'Devocionais', devocionalBuilder),
                    ),
                  ];
                  // Tablet: duas colunas; mobile: uma coluna.
                  if (c.maxWidth >= 600) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 16),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 16),
                      cards[1],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    // Logout LOCAL (sem revogação server-side): limpa a sessão e o estado.
    onLogout?.call();
    // Limpa a pilha de navegação, voltando à raiz (Login). Impede "Voltar"
    // para a Home.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _go(BuildContext context, String title, WidgetBuilder? builder) {
    final WidgetBuilder destination =
        builder ?? (_) => _ComingSoonScreen(title: title);
    Navigator.of(context).push(MaterialPageRoute(builder: destination));
  }
}

/// Cabeçalho de marca: fachada + overlay + logo + saudação (e ação Sair).
class _Header extends StatelessWidget {
  final String greeting;
  final VoidCallback? onLogout;
  final void Function(BuildContext) onLogoutTap;

  const _Header({
    required this.greeting,
    required this.onLogout,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 232 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/brand/church_facade.jpg',
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.1),
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Color(0xFF14210F)),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x88000000), Color(0xD9000000)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 12, 12, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _logoMark(),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Goel Church',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (onLogout != null)
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Sair',
                        onPressed: () => onLogoutTap(context),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  greeting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Que bom ter você aqui hoje.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoMark() => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.5),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/brand/goel_logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Colors.black,
              child: Icon(Icons.church_outlined, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Abrir $title',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: scheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
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

/// Placeholder até o conteúdo do slice correspondente (06/07) existir.
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Em breve.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
