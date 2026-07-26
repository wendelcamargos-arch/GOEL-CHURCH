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

  testWidgets('tocar em um card sem builder abre o "Em breve"', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeScreen(memberName: 'Ana')),
    );

    await tester.tap(find.text('Versículo do dia'));
    await tester.pumpAndSettle();

    // Sem builder injetado, o atalho leva à tela "Em breve".
    expect(find.textContaining('Em breve'), findsWidgets);
  });
}
