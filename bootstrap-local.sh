#!/usr/bin/env bash
# =============================================================================
# GOEL CHURCH — bootstrap-local.sh
# Provisionamento para máquina LOCAL (Linux ou macOS). Instala Flutter (+Dart),
# Android SDK (+licenças), Java 17, Chrome, GitHub CLI, e configura o PATH no
# shell rc do usuário. Instala em $HOME (não requer /opt). Idempotente.
# Ao final valida flutter/dart/doctor/pub get/analyze/test.
# =============================================================================
set -euo pipefail

FLUTTER_VERSION="3.44.8"
DEV="${HOME}/development"
FLUTTER_HOME="${DEV}/flutter"
ANDROID_SDK_ROOT="${HOME}/Android/sdk"
ANDROID_PLATFORM="android-36"
ANDROID_BUILD_TOOLS="36.0.0"

log() { echo; echo ">>> $*"; }
OS="$(uname -s)"
mkdir -p "${DEV}"

case "${OS}" in
  Linux)
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    CMDLINE_TOOLS_ZIP="commandlinetools-linux-11076708_latest.zip"
    log "[deps] Java 17 + utilitários (apt)"
    if command -v apt-get >/dev/null 2>&1; then
      SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
      $SUDO apt-get update -y
      $SUDO apt-get install -y --no-install-recommends curl git unzip xz-utils ca-certificates openjdk-17-jdk libglu1-mesa
      command -v google-chrome >/dev/null 2>&1 || {
        curl -fsSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb
        $SUDO apt-get install -y /tmp/chrome.deb || $SUDO apt-get -f install -y; rm -f /tmp/chrome.deb; }
      command -v gh >/dev/null 2>&1 || { type -p curl >/dev/null && \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
        $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null && \
        $SUDO apt-get update -y && $SUDO apt-get install -y gh; }
    else
      echo "!! apt-get não encontrado — instale manualmente: git, openjdk-17, chrome, gh"
    fi
    ;;
  Darwin)
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_${FLUTTER_VERSION}-stable.zip"
    CMDLINE_TOOLS_ZIP="commandlinetools-mac-11076708_latest.zip"
    log "[deps] Homebrew: git, openjdk@17, gh, google-chrome"
    if ! command -v brew >/dev/null 2>&1; then
      echo "!! Homebrew ausente. Instale em https://brew.sh e rode de novo."; exit 1
    fi
    brew install git gh || true
    brew install --quiet openjdk@17 || true
    brew install --cask google-chrome || true
    ;;
  *)
    echo "SO não suportado: ${OS} (use Linux ou macOS)"; exit 1;;
esac

log "[flutter] SDK ${FLUTTER_VERSION}"
if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  TMP="$(mktemp -d)"
  if [ "${OS}" = "Darwin" ]; then
    curl -fsSL "${FLUTTER_URL}" -o "${TMP}/flutter.zip"; unzip -q "${TMP}/flutter.zip" -d "${DEV}"
  else
    curl -fsSL "${FLUTTER_URL}" -o "${TMP}/flutter.tar.xz"; tar -xf "${TMP}/flutter.tar.xz" -C "${DEV}"
  fi
  rm -rf "${TMP}"
fi
git config --global --add safe.directory "${FLUTTER_HOME}" || true
export PATH="${FLUTTER_HOME}/bin:${PATH}"

log "[android] SDK (${ANDROID_PLATFORM}, build-tools ${ANDROID_BUILD_TOOLS}, licenças)"
if [ ! -d "${ANDROID_SDK_ROOT}/cmdline-tools/latest" ]; then
  mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
  curl -fsSL "https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}" -o /tmp/cmdtools.zip
  unzip -q /tmp/cmdtools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -f /tmp/cmdtools.zip
fi
export PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
flutter config --android-sdk "${ANDROID_SDK_ROOT}" >/dev/null 2>&1 || true

log "[path] Persistindo no shell rc"
RC="${HOME}/.bashrc"; [ "${OS}" = "Darwin" ] && RC="${HOME}/.zshrc"
if ! grep -q 'GOEL CHURCH provisioning' "$RC" 2>/dev/null; then
  {
    echo '# --- GOEL CHURCH provisioning ---'
    echo "export ANDROID_SDK_ROOT=\"${ANDROID_SDK_ROOT}\""
    echo "export ANDROID_HOME=\"${ANDROID_SDK_ROOT}\""
    echo "export PATH=\"${FLUTTER_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:\$PATH\""
    echo '# --- end GOEL CHURCH ---'
  } >> "$RC"
fi
flutter config --no-analytics >/dev/null 2>&1 || true

log "[verificação] ambiente + projeto"
flutter --version
dart --version
flutter doctor
if [ -f pubspec.yaml ]; then
  flutter pub get
  ( cd packages/goel_domain && dart pub get )
  flutter analyze
  flutter test
fi

log "OK — ambiente local pronto. Novo terminal ou: source ${RC}"
