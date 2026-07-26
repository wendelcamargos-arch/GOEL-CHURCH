import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('Home saúda o membro e mostra as jornadas', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(memberName: 'Ana Maria')),
    );

    expect(find.textContaining('Olá, Ana'), findsOneWidget);
    expect(find.text('Versículo do dia'), findsOneWidget);
    expect(find.text('Devocionais'), findsOneWidget);
  });

  testWidgets('sem nome, mostra saudação genérica', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.textContaining('Bem-vindo'), findsOneWidget);
  });

  testWidgets('sem onLogout, não exibe a ação "Sair"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(memberName: 'Ana Maria')),
    );
    expect(find.byTooltip('Sair'), findsNothing);
  });

  testWidgets('tocar em "Sair" chama onLogout e volta à raiz da navegação',
      (tester) async {
    var loggedOut = false;

    // Simula Login → Home: a Home é empurrada sobre uma raiz (o "Login").
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      memberName: 'Ana Maria',
                      onLogout: () => loggedOut = true,
                    ),
                  ),
                ),
                child: const Text('ir para a Home'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ir para a Home'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Olá, Ana'), findsOneWidget);

    await tester.tap(find.byTooltip('Sair'));
    await tester.pumpAndSettle();

    // A ação de Logout foi executada e a Home saiu da pilha (voltou à raiz).
    expect(loggedOut, isTrue);
    expect(find.text('ir para a Home'), findsOneWidget);
    expect(find.textContaining('Olá, Ana'), findsNothing);
  });
}
