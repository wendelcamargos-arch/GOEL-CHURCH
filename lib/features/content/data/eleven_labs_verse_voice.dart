import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import 'verse_voice.dart';

/// Voz PREMIUM da Palavra (futuro): narração mais natural via ElevenLabs.
///
/// Fica dormente até existir uma chave de API (ver verse_voice_factory.dart).
/// Fluxo: chama a API de Text-to-Speech da ElevenLabs, recebe o áudio (MP3) e
/// toca com o audioplayers. Não guarda nada no app; a chave vem por
/// `--dart-define=ELEVENLABS_API_KEY=...` (nunca fica no código).
class ElevenLabsVerseVoice extends VerseVoice {
  final String apiKey;

  /// ID da voz escolhida na conta da ElevenLabs (voz multilíngue acolhedora).
  final String voiceId;

  /// Modelo multilíngue (suporta português).
  final String modelId;

  final AudioPlayer _player = AudioPlayer();
  bool _wired = false;

  ElevenLabsVerseVoice({
    required this.apiKey,
    required this.voiceId,
    this.modelId = 'eleven_multilingual_v2',
  });

  void _wire() {
    if (_wired) return;
    _player.onPlayerComplete.listen((_) => onComplete?.call());
    _wired = true;
  }

  @override
  Future<void> speak(String text) async {
    _wire();
    final uri =
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId');
    final resp = await http.post(
      uri,
      headers: {
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
        'Accept': 'audio/mpeg',
      },
      body: jsonEncode({
        'text': text,
        'model_id': modelId,
        'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75},
      }),
    );
    if (resp.statusCode != 200) {
      throw Exception('ElevenLabs respondeu ${resp.statusCode}');
    }
    await _player.play(BytesSource(Uint8List.fromList(resp.bodyBytes)));
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    onCancel?.call();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}
