import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/app/goel_app.dart';

void main() {
  testWidgets('Slice 01: o app inicializa e exibe a tela de bootstrap',
      (tester) async {
    await tester.pumpWidget(const GoelApp());

    expect(find.text('Goel Church'), findsOneWidget);
    expect(find.textContaining('Slice 01'), findsOneWidget);
  });
}
