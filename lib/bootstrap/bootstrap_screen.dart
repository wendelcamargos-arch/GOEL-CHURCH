import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Splash institucional do Goel Church.
///
/// Camada 100% visual: fotografia oficial da fachada (cover) + overlay escuro
/// com leve blur, logotipo oficial, wordmark e slogan, com fade-in suave. Sem
/// ruído técnico para o usuário final; o aviso de backend só aparece em
/// desenvolvimento (`!supabaseConfigured`). Não altera domínio, navegação nem
/// lógica — apenas apresentação.
class BootstrapScreen extends StatefulWidget {
  final bool supabaseConfigured;

  const BootstrapScreen({super.key, this.supabaseConfigured = false});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen>
    with SingleTickerProviderStateMixin {
  // Caminhos dos assets oficiais (substituir os placeholders por estes nomes).
  static const _bgAsset = 'assets/brand/church_facade.jpg';
  static const _logoAsset = 'assets/brand/goel_logo.png';

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Fotografia da fachada — cobre a tela toda, foco central.
          FadeTransition(
            opacity: _fade,
            child: Image.asset(
              _bgAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              // Fallback caso o asset real ainda não tenha sido adicionado.
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF14210F)),
            ),
          ),

          // 2) Overlay escuro + leve blur para leitura dos elementos centrais.
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: const ColoredBox(color: Color(0xA6000000)), // preto ~65%
          ),

          // 3) Conteúdo central (rolável — evita overflow em landscape/telas
          //    baixas) com fade-in de logo + wordmark + slogan.
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 32,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Semantics(
                            label: 'Logotipo Goel Church',
                            image: true,
                            child: Image.asset(
                              _logoAsset,
                              width: 132,
                              height: 132,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.church_outlined,
                                size: 96,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'GOEL CHURCH',
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Vivendo a Palavra.\nCompartilhando Esperança.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 56),
                          const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          if (!widget.supabaseConfigured) ...[
                            const SizedBox(height: 20),
                            Text(
                              'Ambiente de desenvolvimento — '
                              'backend não configurado',
                              textAlign: TextAlign.center,
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
