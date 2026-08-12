import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// Fake do url_launcher para testes de widget: `launchUrl` "abre" com sucesso
/// (registra a URL) sem plugin de plataforma — evita SnackBars/timers pendentes
/// quando as telas abrem grupos oficiais do WhatsApp.
class FakeUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  final List<String> launched = <String>[];

  /// Quando `false`, simula falha ao abrir (o `launchUrl` retorna false).
  bool ok = true;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return ok;
  }

  @override
  Future<bool> supportsMode(PreferredLaunchMode mode) async => true;

  @override
  Future<bool> supportsCloseForMode(PreferredLaunchMode mode) async => true;
}

/// Instala o fake como plataforma ativa e devolve a instância (para inspeção).
FakeUrlLauncher installFakeUrlLauncher() {
  final fake = FakeUrlLauncher();
  UrlLauncherPlatform.instance = fake;
  return fake;
}
