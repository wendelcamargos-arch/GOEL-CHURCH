import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/app/goel_app.dart';

void main() {
  testWidgets('o app inicializa e exibe a tela de bootstrap', (tester) async {
    await tester.pumpWidget(const GoelApp());

    expect(find.text('Goel Church'), findsOneWidget);
    expect(find.textContaining('Slice 02'), findsOneWidget);
  });

  testWidgets('sem credenciais, mostra Supabase não configurado', (tester) async {
    await tester.pumpWidget(const GoelApp(supabaseConfigured: false));
    expect(find.textContaining('não configurado'), findsOneWidget);
  });

  testWidgets('com credenciais, mostra Supabase conectado', (tester) async {
    await tester.pumpWidget(const GoelApp(supabaseConfigured: true));
    expect(find.textContaining('conectado'), findsOneWidget);
  });
}
