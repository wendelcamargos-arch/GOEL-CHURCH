import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/features/content/presentation/devocionais_screen.dart';
import 'package:goel_domain/goel_domain.dart';

class _FakeDevotionalRepository implements DevotionalRepository {
  @override
  Future<List<Devotional>> list() async => [
        Devotional(
          id: '1',
          title: 'Comece o dia com gratidão',
          body: 'Texto do devocional.',
          author: 'Goel Church',
          publishedAt: DateTime(2026, 1, 1),
        ),
      ];
}

void main() {
  testWidgets('lista devocionais e abre o detalhe', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DevocionaisScreen(repository: _FakeDevotionalRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Comece o dia com gratidão'), findsOneWidget);

    await tester.tap(find.text('Comece o dia com gratidão'));
    await tester.pumpAndSettle();

    expect(find.text('Devocional'), findsOneWidget); // AppBar do detalhe
    expect(find.text('Texto do devocional.'), findsOneWidget);
  });
}
