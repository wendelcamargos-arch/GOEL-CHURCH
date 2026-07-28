# GOEL CHURCH — Guia do Desenvolvedor (README-DEV)

Ambiente oficial de desenvolvimento do app **Goel Church** (Flutter). O
provisionamento é **automático e versionado**: qualquer pessoa clona, abre no
Codespaces, aguarda o bootstrap e roda `flutter run` — **sem configuração
manual**.

## Estrutura do ambiente

```
.devcontainer/devcontainer.json   # gatilho: chama bootstrap-codespace.sh ao criar o Codespace
bootstrap-codespace.sh            # provisionamento oficial do Codespace (Linux/apt)
bootstrap-local.sh                # provisionamento para máquina local (Linux/macOS)
README-DEV.md                     # este guia
```

Ambos os scripts instalam a **mesma versão** (Flutter **3.44.8** / Dart 3.12.2)
e o **Android SDK 36**, garantindo paridade entre Codespace, máquina local e CI.

---

## Como abrir o projeto (Codespaces — recomendado)

1. No GitHub, botão **Code → Codespaces → Create codespace on main**.
2. Aguarde o **bootstrap automático** (`onCreateCommand` roda
   `bootstrap-codespace.sh`). Na primeira vez leva alguns minutos (baixa Flutter
   + Android SDK).
3. Ao terminar, abra um **novo terminal** e confirme:
   ```bash
   flutter --version
   ```
4. Rode o app (ver seções UI_PREVIEW / Android abaixo).

## Como recriar o Codespace

- **Rebuild (mesmo Codespace):** Command Palette (`F1`) → **Codespaces: Rebuild
  Container**. Reexecuta o bootstrap.
- **Novo Codespace:** apague o antigo em <https://github.com/codespaces> e crie
  outro em `main`. Como o provisionamento é versionado, nasce pronto.
- **Provisionar manualmente** (se o automático não rodar):
  ```bash
  cd /workspaces/GOEL-CHURCH
  bash bootstrap-codespace.sh
  source ~/.bashrc
  ```

## Como executar localmente (Linux/macOS)

```bash
git clone https://github.com/wendelcamargos-arch/GOEL-CHURCH.git
cd GOEL-CHURCH
bash bootstrap-local.sh      # instala Flutter, Dart, Android SDK, Java, Chrome, gh
source ~/.bashrc             # (ou ~/.zshrc no macOS)
flutter --version
```
- **Linux:** usa `apt` (Java/Chrome/gh) e instala o Flutter em `~/development/flutter`.
- **macOS:** usa **Homebrew** (instale antes em <https://brew.sh>); Flutter em
  `~/development/flutter`, Android SDK em `~/Android/sdk`.

## Como atualizar o Flutter

O ambiente **fixa** a versão (reprodutibilidade). Para mudar:
1. Edite `FLUTTER_VERSION="3.44.8"` no topo de `bootstrap-codespace.sh` **e**
   `bootstrap-local.sh` para a nova versão estável.
2. Remova o SDK atual e reprovisione:
   ```bash
   sudo rm -rf /opt/flutter        # (local: rm -rf ~/development/flutter)
   bash bootstrap-codespace.sh     # (local: bash bootstrap-local.sh)
   ```
3. Rode `flutter pub get` / `flutter test` e confirme que o projeto segue verde
   antes de commitar a mudança de versão.

> Alternativa pontual (não recomendada para o padrão do time): `flutter upgrade`
> — porém isso desalinha a versão fixada; prefira editar a variável.

## Como atualizar o Android SDK

Ajuste as variáveis no topo dos scripts:
```bash
ANDROID_PLATFORM="android-36"       # ex.: android-37
ANDROID_BUILD_TOOLS="36.0.0"        # ex.: 37.0.0
```
Depois reprovisione (ou rode direto):
```bash
sdkmanager "platforms;android-37" "build-tools;37.0.0"
yes | sdkmanager --licenses
```
O `applicationId` do Android deve permanecer alinhado ao app registrado no
Firebase (não alterar sem coordenar o App Distribution).

## Como iniciar o UI_PREVIEW (homologação visual, sem backend)

Modo oficial de revisão da interface — **sem Supabase, WhatsApp, backend**:
```bash
flutter run -d web-server \
  --web-hostname 0.0.0.0 \
  --web-port 3000 \
  --dart-define=UI_PREVIEW=true
```
- No Codespaces a porta **3000** é encaminhada automaticamente (torne-a
  **Public** na aba *Ports* para abrir no navegador).
- URL: `https://<CODESPACE_NAME>-3000.app.github.dev`
- Abre a **Central de Homologação** (Splash, Login, Cadastro, Home, Versículo,
  Devocional + ferramentas de tema/fonte/dispositivo).
- **Produção não muda:** sem a flag (`UI_PREVIEW=false`) roda o fluxo normal.

## Como iniciar o Android

Pré-requisito: Android SDK provisionado (o bootstrap já faz).
```bash
# debug (rápido, chave de debug)
flutter build apk --debug

# release (para distribuição) — passe os segredos por --dart-define
flutter build apk --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```
APK gerado em `build/app/outputs/flutter-apk/`. A distribuição ao grupo de
testadores é feita pelo workflow **Firebase App Distribution** (CI), a partir do
artefato do **Android Build** — não manualmente.

---

## Fluxo esperado (zero configuração manual)

```
git clone  →  Open in Codespaces  →  aguardar bootstrap  →  flutter run
```

## Solução de problemas

| Sintoma | Causa provável | Ação |
|---|---|---|
| `flutter: command not found` | bootstrap não rodou / PATH não carregou | `bash bootstrap-codespace.sh` e `source ~/.bashrc` |
| Web abre em branco | cache do service worker | abrir em **aba anônima** / `Ctrl+Shift+R`; garantir `--dart-define=UI_PREVIEW=true` |
| `flutter doctor` sem Android | Android SDK/licenças | `yes | sdkmanager --licenses` e reprovisionar |
| `analyze` com erros em `packages/goel_domain/test` | faltou resolver o subpacote | `cd packages/goel_domain && dart pub get` |
