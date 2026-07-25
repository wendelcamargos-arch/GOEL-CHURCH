import 'package:flutter_test/flutter_test.dart';
import 'package:goel_church/core/env/app_env.dart';

void main() {
  group('AppEnv.isConfigured', () {
    test('falso quando ambos vazios', () {
      const env = AppEnv(supabaseUrl: '', supabaseAnonKey: '');
      expect(env.isConfigured, isFalse);
    });

    test('falso quando falta a chave', () {
      const env = AppEnv(supabaseUrl: 'https://x.supabase.co', supabaseAnonKey: '');
      expect(env.isConfigured, isFalse);
    });

    test('verdadeiro quando ambos presentes', () {
      const env = AppEnv(
        supabaseUrl: 'https://x.supabase.co',
        supabaseAnonKey: 'anon-key',
      );
      expect(env.isConfigured, isTrue);
    });
  });
}
