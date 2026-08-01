# Voz da "Palavra do dia"

O botão **Ouvir a Palavra** lê o versículo em voz alta. A arquitetura tem duas
opções, e trocar entre elas **não exige mudar nenhuma tela**.

## Opção 1 — Voz do aparelho (padrão, GRÁTIS) ✅
Usada hoje. É o Text-to-Speech nativo do celular:
- **Android:** Google TTS · **iOS:** AVSpeechSynthesizer
- Português (pt-BR), **offline**, sem chave e **sem custo**.

Não precisa fazer nada — já vem ativa.

## Opção 2 — ElevenLabs (voz premium, para crescimento futuro)
Voz mais natural. Fica **dormente** até você configurar a chave. Quando quiser
ativar (aplica-se a Android e iOS ao mesmo tempo):

1. Crie uma conta em **elevenlabs.io** e pegue:
   - a **API key** (Profile → API Keys);
   - o **Voice ID** de uma voz multilíngue (na aba Voices).
2. Faça o build passando os dois valores (nunca ficam no código):

   ```bash
   flutter build appbundle --release \
     --dart-define=ELEVENLABS_API_KEY=SUA_CHAVE \
     --dart-define=ELEVENLABS_VOICE_ID=SEU_VOICE_ID
   ```

   No **Codemagic** (iOS) / **GitHub Actions** (Android), adicione os mesmos
   valores como variáveis/segredos e repasse com `--dart-define`.

Com a chave presente, `createVerseVoice()` passa a usar a voz da ElevenLabs
automaticamente; sem a chave, volta para a voz grátis do aparelho.

## Onde está no código
- `lib/features/content/data/verse_voice.dart` — contrato (interface).
- `lib/features/content/data/device_verse_voice.dart` — voz do aparelho (grátis).
- `lib/features/content/data/eleven_labs_verse_voice.dart` — voz ElevenLabs.
- `lib/features/content/data/verse_voice_factory.dart` — escolhe qual usar.
