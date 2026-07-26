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
/// Objetivo: permitir que o Owner revise TODA a interface no navegador, sem
/// depender de Supabase, WhatsApp, OTP, backend ou persistência. Abre direto
/// na Home e oferece um menu flutuante ("Telas") que navega para todas as telas
/// de inspeção. NÃO faz parte do fluxo normal do app; nada aqui é usado quando
/// `UI_PREVIEW=false`. Não altera domínio nem arquitetura — apenas compõe as
/// telas existentes com dados fake em memória.
class UiPreviewApp extends StatelessWidget {
  const UiPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositórios de inspeção: versículo é offline por natureza (domínio
    // público); devocional usa dados fake em memória (sem rede).
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

    Widget loginScreen() {
      final flow = LoginFlow(_PreviewAuthGateway());
      return LoginGate(
        flow: flow,
        postLoginBuilder: (_) => cadastroScreen(),
      );
    }

    final destinations = <_PreviewDestination>[
      _PreviewDestination('Splash', Icons.flag_outlined,
          (_) => const BootstrapScreen(supabaseConfigured: true),),
      _PreviewDestination(
          'Login (visual)', Icons.login_outlined, (_) => loginScreen(),),
      _PreviewDestination(
          'Cadastro', Icons.person_add_alt_outlined, (_) => cadastroScreen(),),
      _PreviewDestination(
          'Home', Icons.home_outlined, (_) => homeScreen(),),
      _PreviewDestination('Versículo do dia', Icons.auto_stories_outlined,
          (_) => VersiculoScreen(
                repository: verseRepository,
                sourceLabel: 'Almeida — domínio público',
              ),),
      _PreviewDestination('Devocionais', Icons.menu_book_outlined,
          (_) => DevocionaisScreen(repository: devotionalRepository),),
    ];

    return MaterialApp(
      title: 'Goel Church — Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: homeScreen(),
      // Menu flutuante de inspeção sobreposto a qualquer tela (fica acima do
      // Navigator, então navega de qualquer lugar).
      builder: (context, child) => Stack(
        children: [
          child ?? const SizedBox.shrink(),
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: _PreviewMenuButton(destinations: destinations),
            ),
          ),
        ],
      ),
    );
  }
}

/// Um destino de inspeção do menu de preview.
class _PreviewDestination {
  final String label;
  final IconData icon;
  final WidgetBuilder builder;
  const _PreviewDestination(this.label, this.icon, this.builder);
}

/// Botão flutuante que abre a lista de telas para inspeção visual.
class _PreviewMenuButton extends StatelessWidget {
  final List<_PreviewDestination> destinations;
  const _PreviewMenuButton({required this.destinations});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'preview-menu',
      icon: const Icon(Icons.palette_outlined),
      label: const Text('Telas'),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_outlined),
                    const SizedBox(width: 12),
                    Text('Preview visual — telas',
                        style: Theme.of(sheetContext).textTheme.titleMedium,),
                  ],
                ),
              ),
              for (final d in destinations)
                ListTile(
                  leading: Icon(d.icon),
                  title: Text(d.label),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    // "Home" volta à raiz; as demais são empilhadas.
                    if (d.label == 'Home') {
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: d.builder),
                      );
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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

/// Gateway de autenticação fake: o login é apenas VISUAL — nenhum OTP é enviado,
/// nenhuma chamada de rede ocorre. Qualquer número/código "avança" a tela.
class _PreviewAuthGateway implements AuthGateway {
  @override
  Future<Result<OtpRequestOutcome, AuthFailure>> requestOtp(
          String phoneE164,) async =>
      const Ok<OtpRequestOutcome, AuthFailure>(OtpRequestOutcome.uniform());

  @override
  Future<Result<VerificationOutcome, AuthFailure>> verifyOtp(
          String phoneE164, String code,) async =>
      const Ok<VerificationOutcome, AuthFailure>(
          SessionEstablished(_previewIdentity),);

  @override
  Future<Result<SessionEstablished, AuthFailure>> selectIdentity(
          String canonicalId,) async =>
      const Ok<SessionEstablished, AuthFailure>(
          SessionEstablished(_previewIdentity),);
}

/// Gateway de perfil fake: o cadastro é apenas VISUAL — nada é persistido.
class _PreviewProfileGateway implements MemberProfileGateway {
  @override
  Future<Result<MemberProfile, ProfileError>> save(
          MemberProfile profile,) async =>
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
