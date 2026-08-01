import 'package:flutter_tts/flutter_tts.dart';

import 'verse_voice.dart';

/// Voz GRÁTIS da Palavra: usa o Text-to-Speech nativo do aparelho.
///
/// Android → Google TTS · iOS → AVSpeechSynthesizer. Em português (pt-BR),
/// offline, sem chave e sem custo. É a opção padrão do app.
class DeviceVerseVoice extends VerseVoice {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.45); // ritmo calmo e acolhedor
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => onComplete?.call());
    _tts.setCancelHandler(() => onCancel?.call());
    _configured = true;
  }

  @override
  Future<void> speak(String text) async {
    await _ensureConfigured();
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  Future<void> dispose() async {
    await _tts.stop();
  }
}
