import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/church/church_links.dart';
import 'package:goel_church/features/redes/presentation/redes_screen.dart';

void main() {
  testWidgets('Redes Sociais abre a localização oficial no Maps',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final abertos = <String>[];
    await tester.pumpWidget(
      MaterialApp(home: RedesScreen(onAbrir: (u) async => abertos.add(u))),
    );

    expect(find.text('Como chegar'), findsOneWidget);
    await tester.tap(find.text('Como chegar'));
    await tester.pump();

    expect(abertos.single, ChurchLinks.location);
    expect(ChurchLinks.location, contains('maps.app.goo.gl'));
  });
}
