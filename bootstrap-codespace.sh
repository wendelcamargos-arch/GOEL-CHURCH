#!/usr/bin/env bash
# =============================================================================
# GOEL CHURCH — bootstrap-codespace.sh
# Provisionamento OFICIAL do Codespace para desenvolvimento Flutter.
# Instala Flutter Stable (+Dart), Android SDK (+licenças), Java 17, Chrome,
# GitHub CLI, Git. Configura PATH. Idempotente.
# Ao final valida: flutter --version, dart --version, flutter doctor,
# flutter pub get, dart pub get (goel_domain), flutter analyze, flutter test.
# =============================================================================
set -euo pipefail

FLUTTER_VERSION="3.44.8"
FLUTTER_HOME="/opt/flutter"
ANDROID_SDK_ROOT="/opt/android-sdk"
ANDROID_PLATFORM="android-36"
ANDROID_BUILD_TOOLS="36.0.0"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-11076708_latest.zip"

log() { echo; echo ">>> $*"; }
SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"

log "[1/7] Pacotes base (Git, Java 17, utilitários)"
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  curl git unzip xz-utils ca-certificates gnupg openjdk-17-jdk libglu1-mesa

log "[2/7] Google Chrome"
if ! command -v google-chrome >/dev/null 2>&1; then
  curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb
  $SUDO apt-get install -y /tmp/chrome.deb || $SUDO apt-get -f install -y
  rm -f /tmp/chrome.deb
fi

log "[3/7] GitHub CLI"
if ! command -v gh >/dev/null 2>&1; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  $SUDO apt-get update -y && $SUDO apt-get install -y gh
fi

log "[4/7] Flutter SDK ${FLUTTER_VERSION} (Dart bundled)"
if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
  $SUDO tar -xf /tmp/flutter.tar.xz -C /opt
  $SUDO chown -R "$(id -u):$(id -g)" "${FLUTTER_HOME}"
  rm -f /tmp/flutter.tar.xz
fi
git config --global --add safe.directory "${FLUTTER_HOME}"
export PATH="${FLUTTER_HOME}/bin:${PATH}"

log "[5/7] Android SDK (${ANDROID_PLATFORM}, build-tools ${ANDROID_BUILD_TOOLS}, licenças)"
if [ ! -d "${ANDROID_SDK_ROOT}/cmdline-tools/latest" ]; then
  $SUDO mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
  $SUDO chown -R "$(id -u):$(id -g)" "${ANDROID_SDK_ROOT}"
  curl -fsSL "https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}" -o /tmp/cmdtools.zip
  unzip -q /tmp/cmdtools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -f /tmp/cmdtools.zip
fi
export PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
flutter config --android-sdk "${ANDROID_SDK_ROOT}" >/dev/null 2>&1 || true

log "[6/7] PATH persistente (~/.bashrc)"
RC="${HOME}/.bashrc"
if ! grep -q 'GOEL CHURCH provisioning' "$RC" 2>/dev/null; then
  {
    echo '# --- GOEL CHURCH provisioning ---'
    echo "export FLUTTER_HOME=\"${FLUTTER_HOME}\""
    echo "export ANDROID_SDK_ROOT=\"${ANDROID_SDK_ROOT}\""
    echo "export ANDROID_HOME=\"${ANDROID_SDK_ROOT}\""
    echo 'export CHROME_EXECUTABLE="$(command -v google-chrome || true)"'
    echo "export PATH=\"${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:\$PATH\""
    echo '# --- end GOEL CHURCH ---'
  } >> "$RC"
fi
export CHROME_EXECUTABLE="$(command -v google-chrome || true)"
flutter config --no-analytics >/dev/null 2>&1 || true

log "[7/7] Verificação do ambiente e do projeto"
flutter --version
dart --version
flutter doctor
if [ -f pubspec.yaml ]; then
  flutter pub get
  ( cd packages/goel_domain && dart pub get )
  flutter analyze
  flutter test
fi

log "OK — ambiente GOEL CHURCH provisionado. Novo terminal ou: source ~/.bashrc"
