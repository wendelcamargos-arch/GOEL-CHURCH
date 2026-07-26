import 'package:flutter/material.dart';
import 'package:goel_domain/goel_domain.dart';

import '../app/theme/app_theme.dart';
import '../bootstrap/bootstrap_screen.dart';
import '../features/auth/application/login_flow.dart';
import '../features/auth/presentation/login_gate.dart';
import '../features/content/data/local_verse_repository.dart';
import '../features/content/presentation/devocionais_screen.dart';
import '../features/content/presentation/versiculo_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/member/application/cadastro_flow.dart';
import '../features/member/presentation/cadastro_screen.dart';

/// MODO DE PREVIEW VISUAL — ativado por `--dart-define=UI_PREVIEW=true`.
///
/// Ferramenta OFICIAL de homologação visual. Abre uma CENTRAL DE HOMOLOGAÇÃO
/// ("GOEL CHURCH UI PREVIEW") que reúne as telas do app e ferramentas de
/// inspeção (tema, fonte, simulação de dispositivo). Sem Supabase, WhatsApp,
/// OTP, Firebase, Meta, backend ou persistência. NÃO faz parte do fluxo normal:
/// nada aqui roda quando `UI_PREVIEW=false`. Não altera domínio, arquitetura
/// nem contratos — apenas compõe as telas existentes com dados fake.
class UiPreviewApp extends StatefulWidget {
  const UiPreviewApp({super.key});

  @override
  State<UiPreviewApp> createState() => _UiPreviewAppState();
}

/// Simulação de dispositivo aplicada ao preview.
enum _DeviceSim { none, mobile, tablet }

class _UiPreviewAppState extends State<UiPreviewApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _largeFont = false;
  _DeviceSim _device = _DeviceSim.none;

  void _reset() => setState(() {
        _themeMode = ThemeMode.light;
        _largeFont = false;
        _device = _DeviceSim.none;
      });

  @override
  Widget build(BuildContext context) {
    final verseRepository = LocalVerseRepository();
    final devotionalRepository = _PreviewDevotionalRepository();

    Widget homeScreen() => HomeScreen(
          memberName: 'Maria Aparecida',
          versiculoBuilder: (_) => VersiculoScreen(
            repository: verseRepository,
            sourceLabel: 'Almeida — domínio público',
          ),
          devocionalBuilder: (_) =>
              DevocionaisScreen(repository: devotionalRepository),
        );

    Widget cadastroScreen() => CadastroScreen(
          flow: CadastroFlow(_PreviewProfileGateway()),
          postCadastroBuilder: (_) => homeScreen(),
        );

    Widget loginScreen() => LoginGate(
          flow: LoginFlow(_PreviewAuthGateway()),
          postLoginBuilder: (_) => cadastroScreen(),
        );

    final fluxoPrincipal = <_ScreenItem>[
      _ScreenItem('Splash', 'Inicialização', Icons.flag_outlined,
          (_) => const BootstrapScreen(supabaseConfigured: true),),
      _ScreenItem('Login', 'Entrada por WhatsApp (visual)',
          Icons.login_outlined, (_) => loginScreen(),),
      _ScreenItem('Cadastro', 'Perfil do membro (visual)',
          Icons.person_add_alt_outlined, (_) => cadastroScreen(),),
      _ScreenItem('Home', 'Tela inicial do membro', Icons.home_outlined,
          (_) => homeScreen(),),
    ];

    final conteudo = <_ScreenItem>[
      _ScreenItem('Versículo', 'Versículo do dia', Icons.auto_stories_outlined,
          (_) => VersiculoScreen(
                repository: verseRepository,
                sourceLabel: 'Almeida — domínio público',
              ),),
      _ScreenItem('Devocional', 'Lista de devocionais',
          Icons.menu_book_outlined,
          (_) => DevocionaisScreen(repository: devotionalRepository),),
    ];

    final ferramentas = <_ToolItem>[
      _ToolItem('Tema Claro', Icons.light_mode_outlined,
          active: _themeMode == ThemeMode.light,
          onTap: () => setState(() => _themeMode = ThemeMode.light),),
      _ToolItem('Tema Escuro', Icons.dark_mode_outlined,
          active: _themeMode == ThemeMode.dark,
          onTap: () => setState(() => _themeMode = ThemeMode.dark),),
      _ToolItem('Fonte Grande', Icons.format_size,
          active: _largeFont,
          onTap: () => setState(() => _largeFont = !_largeFont),),
      _ToolItem('Simulação Mobile', Icons.smartphone,
          active: _device == _DeviceSim.mobile,
          onTap: () => setState(() => _device = _DeviceSim.mobile),),
      _ToolItem('Simulação Tablet', Icons.tablet_mac,
          active: _device == _DeviceSim.tablet,
          onTap: () => setState(() => _device = _DeviceSim.tablet),),
      _ToolItem('Reset Preview', Icons.restart_alt, onTap: _reset),
    ];

    return MaterialApp(
      title: 'Goel Church — UI Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      builder: (context, child) => _frame(context, child),
      home: _CentralLauncher(
        fluxoPrincipal: fluxoPrincipal,
        conteudo: conteudo,
        ferramentas: ferramentas,
      ),
    );
  }

  /// Aplica fonte grande (textScaler) e a moldura de simulação de dispositivo
  /// sobre TODA a árvore (launcher + telas empilhadas).
  Widget _frame(BuildContext context, Widget? child) {
    final base = MediaQuery.of(context);
    final scaler = TextScaler.linear(_largeFont ? 1.35 : 1.0);
    final content = child ?? const SizedBox.shrink();

    final double? width = switch (_device) {
      _DeviceSim.mobile => 412,
      _DeviceSim.tablet => 834,
      _DeviceSim.none => null,
    };

    if (width == null) {
      return MediaQuery(
        data: base.copyWith(textScaler: scaler),
        child: content,
      );
    }

    final height = base.size.height * 0.94;
    return ColoredBox(
      color: const Color(0xFF20232A),
      child: Center(
        child: Material(
          elevation: 8,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: width,
            height: height,
            child: MediaQuery(
              data: base.copyWith(
                textScaler: scaler,
                size: Size(width, height),
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

/// Item de tela: abre diretamente a tela correspondente.
class _ScreenItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  const _ScreenItem(this.label, this.subtitle, this.icon, this.builder);
}

/// Item de ferramenta: dispara uma ação de inspeção (tema/fonte/simulação).
class _ToolItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _ToolItem(this.label, this.icon, {required this.onTap, this.active = false});
}

/// Central de Homologação — tela inicial do modo preview.
class _CentralLauncher extends StatelessWidget {
  final List<_ScreenItem> fluxoPrincipal;
  final List<_ScreenItem> conteudo;
  final List<_ToolItem> ferramentas;

  const _CentralLauncher({
    required this.fluxoPrincipal,
    required this.conteudo,
    required this.ferramentas,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('GOEL CHURCH UI PREVIEW', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Central de homologação visual — sem backend, sem autenticação, '
              'sem persistência.',
              style: textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _section(context, 'FLUXO PRINCIPAL'),
            for (final s in fluxoPrincipal) _screenTile(context, s),
            const SizedBox(height: 16),
            _section(context, 'CONTEÚDO'),
            for (final s in conteudo) _screenTile(context, s),
            const SizedBox(height: 16),
            _section(context, 'FERRAMENTAS DE HOMOLOGAÇÃO'),
            for (final t in ferramentas) _toolTile(context, t),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.1,
              ),
        ),
      );

  Widget _screenTile(BuildContext context, _ScreenItem s) => Card(
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          leading: Icon(s.icon, size: 30),
          title: Text(s.label, style: Theme.of(context).textTheme.titleLarge),
          subtitle: Text(s.subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: s.builder)),
        ),
      );

  Widget _toolTile(BuildContext context, _ToolItem t) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: t.active ? scheme.primaryContainer : null,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(t.icon, size: 28),
        title: Text(t.label, style: Theme.of(context).textTheme.titleMedium),
        trailing: t.active
            ? const Icon(Icons.check_circle)
            : const Icon(Icons.tune),
        onTap: t.onTap,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fakes de PREVIEW — em memória, sem rede, sem persistência. Existem apenas
// para renderizar as telas; nunca são usados no fluxo normal do app.
// ---------------------------------------------------------------------------

const IdentitySummary _previewIdentity = IdentitySummary(
  canonicalId: 'preview',
  displayName: 'Maria Aparecida',
  state: IdentityState.active,
);

/// Gateway de autenticação fake: login apenas VISUAL — nenhum OTP, nenhuma rede.
class _PreviewAuthGateway implements AuthGateway {
  @override
  Future<Result<OtpRequestOutcome, AuthFailure>> requestOtp(
    String phoneE164,
  ) async =>
      const Ok<OtpRequestOutcome, AuthFailure>(OtpRequestOutcome.uniform());

  @override
  Future<Result<VerificationOutcome, AuthFailure>> verifyOtp(
    String phoneE164,
    String code,
  ) async =>
      const Ok<VerificationOutcome, AuthFailure>(
        SessionEstablished(_previewIdentity),
      );

  @override
  Future<Result<SessionEstablished, AuthFailure>> selectIdentity(
    String canonicalId,
  ) async =>
      const Ok<SessionEstablished, AuthFailure>(
        SessionEstablished(_previewIdentity),
      );
}

/// Gateway de perfil fake: cadastro apenas VISUAL — nada é persistido.
class _PreviewProfileGateway implements MemberProfileGateway {
  @override
  Future<Result<MemberProfile, ProfileError>> save(
    MemberProfile profile,
  ) async =>
      Ok<MemberProfile, ProfileError>(profile);
}

/// Repositório de devocionais fake: conteúdo em memória para inspeção visual.
class _PreviewDevotionalRepository implements DevotionalRepository {
  @override
  Future<List<Devotional>> list() async => [
        Devotional(
          id: '1',
          title: 'A graça que sustenta',
          body:
              'Nada nos separa do amor de Deus. Em cada manhã, a misericórdia '
              'se renova — e a graça que te chamou é a mesma que te sustenta.',
          publishedAt: DateTime(2026, 1, 6),
          author: 'Pr. João',
        ),
        Devotional(
          id: '2',
          title: 'Uma família para pertencer',
          body:
              'A igreja é lugar de pertencimento. Você não caminha sozinho: '
              'fomos chamados para viver em comunhão, uns cuidando dos outros.',
          publishedAt: DateTime(2026, 1, 13),
          author: 'Pra. Ana',
        ),
        Devotional(
          id: '3',
          title: 'Descanso para o coração cansado',
          body:
              '"Vinde a mim todos os que estais cansados e sobrecarregados." '
              'O convite continua aberto hoje: entregue o peso e receba paz.',
          publishedAt: DateTime(2026, 1, 20),
          author: null,
        ),
      ];
}
