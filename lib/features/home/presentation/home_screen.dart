import 'package:flutter/material.dart';

import '../../../app/widgets/goel_card.dart';
import '../../../app/widgets/goel_header.dart';
import '../../oracao/presentation/oracao_screen.dart';
import '../../servo/presentation/servo_screen.dart';
import '../../testemunho/presentation/testemunho_screen.dart';
import 'coming_soon_view.dart';

/// Home (aba **Início**) — hub acolhedor após login/cadastro.
///
/// Camada de apresentação. Usa o cabeçalho oficial [GoelHeader] (Logo → GOEL
/// CHURCH → slogan) com a saudação como `extra`, e os cards padronizados
/// [GoelCard]. Contrato preservado (memberName + builders de jornada).
class HomeScreen extends StatelessWidget {
  final String? memberName;

  /// Destinos das jornadas, injetados pela composição raiz conforme os slices
  /// vão existindo. Nulo → placeholder "Em breve".
  final WidgetBuilder? versiculoBuilder;
  final WidgetBuilder? devocionalBuilder;

  const HomeScreen({
    super.key,
    this.memberName,
    this.versiculoBuilder,
    this.devocionalBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = (memberName == null || memberName!.trim().isEmpty)
        ? 'Bem-vindo(a) à Goel Church'
        : 'Olá, ${memberName!.split(' ').first}';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho oficial (Logo → GOEL CHURCH → slogan) + saudação.
            // Leve escurecimento por baixo para legibilidade sobre a fachada.
            Stack(
              children: [
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0x66000000)],
                      ),
                    ),
                  ),
                ),
                GoelHeader(
                  extra: Text(
                    greeting,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: LayoutBuilder(
                builder: (context, c) {
                  final cards = <Widget>[
                    GoelCard(
                      icon: Icons.auto_stories_outlined,
                      title: 'Versículo do dia',
                      subtitle: 'Uma palavra para hoje',
                      onTap: () =>
                          _go(context, 'Versículo do dia', versiculoBuilder),
                    ),
                    GoelCard(
                      icon: Icons.record_voice_over_outlined,
                      title: 'Testemunho',
                      subtitle: 'Conte o que Deus fez',
                      onTap: () => _push(context, const TestemunhoScreen()),
                    ),
                    GoelCard(
                      icon: Icons.volunteer_activism_outlined,
                      title: 'Pedido de Oração',
                      subtitle: 'Estamos com você',
                      onTap: () => _push(context, const OracaoScreen()),
                    ),
                    GoelCard(
                      icon: Icons.handshake_outlined,
                      title: 'Quero Ser Servo',
                      subtitle: 'Sirva com a gente',
                      onTap: () => _push(context, const ServoScreen()),
                    ),
                  ];
                  // Tablet: duas colunas; mobile: uma coluna.
                  if (c.maxWidth >= 600) {
                    return Column(
                      children: [
                        for (var i = 0; i < cards.length; i += 2)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i + 2 < cards.length ? 10 : 0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: cards[i]),
                                const SizedBox(width: 16),
                                if (i + 1 < cards.length)
                                  Expanded(child: cards[i + 1])
                                else
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        cards[i],
                        if (i < cards.length - 1) const SizedBox(height: 10),
                      ],
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

  void _go(BuildContext context, String title, WidgetBuilder? builder) {
    final WidgetBuilder destination = builder ??
        (_) => ComingSoonScreen(icon: Icons.auto_stories_outlined, title: title);
    Navigator.of(context).push(MaterialPageRoute(builder: destination));
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}
