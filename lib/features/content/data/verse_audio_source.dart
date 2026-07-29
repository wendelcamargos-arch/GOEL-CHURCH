import 'package:goel_domain/goel_domain.dart';

/// Fonte do áudio da "Palavra do dia".
///
/// Abstração da camada de dados: entrega uma URL/asset TOCÁVEL para o versículo
/// do dia (a narração em voz). A implementação real (voz ElevenLabs) pluga aqui
/// e pode seguir dois caminhos, sem mudar a tela:
///
///  - **Pré-gravado (recomendado, offline-first):** um script gera uma vez o
///    MP3 de cada versículo com a ElevenLabs e empacota como asset; aqui
///    retornamos o caminho do asset. Sem chave no app, sem custo por play.
///  - **Em tempo real:** o app (ou um backend) chama a API da ElevenLabs com o
///    texto do versículo e recebe o MP3; aqui retornamos essa URL/arquivo.
///
/// `null` significa "ainda não há áudio" — a tela mostra o estado honesto
/// "em breve" no lugar de fingir uma reprodução.
abstract class VerseAudioSource {
  Future<String?> audioFor(DailyVerse verse);
}

/// Implementação neutra enquanto a voz da ElevenLabs não está configurada.
class UnavailableVerseAudioSource implements VerseAudioSource {
  const UnavailableVerseAudioSource();

  @override
  Future<String?> audioFor(DailyVerse verse) async => null;
}
