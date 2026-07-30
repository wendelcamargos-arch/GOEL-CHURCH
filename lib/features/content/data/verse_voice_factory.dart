import 'device_verse_voice.dart';
import 'eleven_labs_verse_voice.dart';
import 'verse_voice.dart';

/// Chave e voz da ElevenLabs vindas do ambiente (nunca ficam no código):
///   flutter build ... --dart-define=ELEVENLABS_API_KEY=xxxx \
///                     --dart-define=ELEVENLABS_VOICE_ID=yyyy
const String _elevenApiKey = String.fromEnvironment('ELEVENLABS_API_KEY');
const String _elevenVoiceId = String.fromEnvironment('ELEVENLABS_VOICE_ID');

/// Escolhe a voz da Palavra:
///  - Se houver chave da ElevenLabs configurada → voz PREMIUM (paga).
///  - Caso contrário → voz GRÁTIS do aparelho (padrão do app hoje).
///
/// Assim, "ligar" a ElevenLabs no futuro é só buildar com a chave — sem mudar
/// nenhuma tela.
VerseVoice createVerseVoice() {
  if (_elevenApiKey.isNotEmpty && _elevenVoiceId.isNotEmpty) {
    return ElevenLabsVerseVoice(
      apiKey: _elevenApiKey,
      voiceId: _elevenVoiceId,
    );
  }
  return DeviceVerseVoice();
}
