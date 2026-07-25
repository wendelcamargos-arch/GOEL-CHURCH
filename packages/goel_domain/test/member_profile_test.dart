import 'package:goel_domain/goel_domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  group('ProfileValidation', () {
    test('nome com menos de 2 caracteres é inválido', () {
      expect(ProfileValidation.isValidName('a'), isFalse);
    });

    test('nome válido', () {
      expect(ProfileValidation.isValidName('Ana'), isTrue);
    });

    test('nascimento no futuro é inválido', () {
      expect(ProfileValidation.isValidBirthDate(DateTime(2027), now), isFalse);
    });

    test('cadastro completo', () {
      expect(
        ProfileValidation.isComplete('Ana Maria', DateTime(1950, 5, 10), now),
        isTrue,
      );
    });

    test('incompleto sem data', () {
      expect(ProfileValidation.isComplete('Ana', null, now), isFalse);
    });
  });
}
