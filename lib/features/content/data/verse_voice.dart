/// Como a "Palavra do dia" é lida em voz alta.
///
/// A tela não sabe QUAL voz é usada — ela só chama [speak]/[stop]. Isso permite
/// crescer a plataforma sem retrabalho:
///  - Hoje (grátis): [DeviceVerseVoice] — voz nativa do aparelho (Android/iOS).
///  - Futuro (premium): [ElevenLabsVerseVoice] — voz mais natural, quando houver
///    uma chave de API configurada.
///
/// A seleção é feita por [createVerseVoice] (verse_voice_factory.dart).
abstract class VerseVoice {
  /// Chamado quando a leitura termina naturalmente.
  void Function()? onComplete;

  /// Chamado quando a leitura é interrompida (stop).
  void Function()? onCancel;

  /// Lê [text] em voz alta (português).
  Future<void> speak(String text);

  /// Interrompe a leitura atual.
  Future<void> stop();

  /// Libera os recursos.
  Future<void> dispose();
}
