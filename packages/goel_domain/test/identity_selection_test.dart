import 'package:goel_domain/goel_domain.dart';
import 'package:test/test.dart';

IdentitySummary _id(String id, IdentityState state) =>
    IdentitySummary(canonicalId: id, displayName: id, state: state);

void main() {
  group('IdentitySelection', () {
    test('só oferece identidades que permitem login', () {
      final all = [
        _id('ativa', IdentityState.active),
        _id('pre', IdentityState.preRegistered),
        _id('suspensa', IdentityState.suspended),
        _id('encerrada', IdentityState.ended),
      ];
      final selectable = IdentitySelection.selectable(all);
      expect(selectable.map((i) => i.canonicalId), ['ativa', 'pre']);
    });

    test('seleção é necessária com mais de uma identidade selecionável', () {
      final all = [
        _id('a', IdentityState.active),
        _id('b', IdentityState.active),
      ];
      expect(IdentitySelection.isSelectionNeeded(all), isTrue);
    });

    test('seleção não é necessária com uma única selecionável', () {
      final all = [
        _id('a', IdentityState.active),
        _id('x', IdentityState.suspended),
      ];
      expect(IdentitySelection.isSelectionNeeded(all), isFalse);
    });
  });

  group('IdentityState', () {
    test('suspensa e encerrada não autenticam', () {
      expect(IdentityState.suspended.canAuthenticate, isFalse);
      expect(IdentityState.ended.canAuthenticate, isFalse);
    });

    test('pré-registrada ativa no primeiro OTP', () {
      expect(IdentityState.preRegistered.activatesOnFirstOtp, isTrue);
    });
  });
}
