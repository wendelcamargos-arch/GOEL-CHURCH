import 'package:goel_domain/goel_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Ok carrega o valor e resolve via fold', () {
      const Result<int, String> r = Ok(42);
      expect(r.fold((v) => v, (_) => -1), 42);
    });

    test('Err carrega o erro e resolve via fold', () {
      const Result<int, String> r = Err('falha');
      expect(r.fold((_) => 'ok', (e) => e), 'falha');
    });
  });
}
