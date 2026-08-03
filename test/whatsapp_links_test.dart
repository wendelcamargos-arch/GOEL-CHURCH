import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/whatsapp/whatsapp_links.dart';

void main() {
  test('links de grupo começam vazios (placeholders — Sprint 4)', () {
    expect(WhatsAppLinks.testemunhos, '');
    expect(WhatsAppLinks.oracao, '');
    expect(WhatsAppLinks.servo, '');
    expect(WhatsAppLinks.gcSenadorCanedo, '');
    expect(WhatsAppLinks.gcGoiania, '');
    expect(WhatsAppLinks.gcJovens, '');
  });

  test('contatos do Gabinete Pastoral JÁ existem (auditoria EU-07)', () {
    expect(WhatsAppLinks.definido(WhatsAppLinks.pastorLinniker), isTrue);
    expect(WhatsAppLinks.definido(WhatsAppLinks.pastoraWanessa), isTrue);
  });

  test('definido() distingue placeholder de link real', () {
    expect(WhatsAppLinks.definido(''), isFalse);
    expect(WhatsAppLinks.definido('   '), isFalse);
    expect(WhatsAppLinks.definido('https://chat.whatsapp.com/abc'), isTrue);
  });

  testWidgets('link de grupo vazio avisa "em breve" sem quebrar',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => abrirGrupoWhatsApp(
                  context,
                  WhatsAppLinks.testemunhos,
                  aviso: 'Grupo em breve.',
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pump();
    expect(find.text('Grupo em breve.'), findsOneWidget);
  });
}
