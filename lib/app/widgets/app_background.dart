import 'package:flutter/material.dart';

/// Fundo global do app — a fachada da Goel Church atrás de TODAS as telas.
///
/// Aplicado uma única vez na raiz (via `MaterialApp.builder`). Com os Scaffolds
/// transparentes (ver [AppTheme]), a imagem aparece por baixo de qualquer rota,
/// fixa enquanto o conteúdo rola/transiciona. Um escurecimento (scrim) garante
/// a legibilidade do texto e dos cards por cima — mesma linguagem da abertura.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF0B0B0B),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/brand/church_facade.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.1),
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFF0B0B0B)),
            ),
          ),
          // Scrim: mais escuro no rodapé, para leitura confortável do conteúdo.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x99000000), Color(0xCC000000)],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
