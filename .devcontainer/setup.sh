#!/usr/bin/env bash
# Bootstrap oficial do ambiente de desenvolvimento Flutter (Goel Church).
# Executado pelo devcontainer (onCreateCommand). Provisiona Flutter, Android
# SDK e as dependências do projeto para que o Codespace abra pronto para:
#   flutter pub get / flutter analyze / flutter test / flutter build apk
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.44.8}"
FLUTTER_HOME="${FLUTTER_HOME:-/opt/flutter}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
ANDROID_PLATFORM="android-36"
ANDROID_BUILD_TOOLS="36.0.0"
CMDLINE_TOOLS_ZIP="commandlinetools-linux-11076708_latest.zip"

echo ">>> [1/4] Flutter SDK ${FLUTTER_VERSION}"
if [ ! -x "${FLUTTER_HOME}/bin/flutter" ]; then
  sudo mkdir -p "$(dirname "${FLUTTER_HOME}")"
  sudo chown -R "$(id -u):$(id -g)" "$(dirname "${FLUTTER_HOME}")"
  curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -o /tmp/flutter.tar.xz
  tar -xf /tmp/flutter.tar.xz -C "$(dirname "${FLUTTER_HOME}")"
  rm -f /tmp/flutter.tar.xz
fi
git config --global --add safe.directory "${FLUTTER_HOME}"
export PATH="${FLUTTER_HOME}/bin:${PATH}"
flutter --version
flutter config --no-analytics >/dev/null || true

echo ">>> [2/4] Android SDK (cmdline-tools, ${ANDROID_PLATFORM}, build-tools ${ANDROID_BUILD_TOOLS})"
if [ ! -d "${ANDROID_SDK_ROOT}/cmdline-tools/latest" ]; then
  sudo mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"
  sudo chown -R "$(id -u):$(id -g)" "${ANDROID_SDK_ROOT}"
  curl -fsSL "https://dl.google.com/android/repository/${CMDLINE_TOOLS_ZIP}" -o /tmp/cmdtools.zip
  unzip -q /tmp/cmdtools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"
  mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"
  rm -f /tmp/cmdtools.zip
fi
export PATH="${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${PATH}"
yes | sdkmanager --licenses >/dev/null 2>&1 || true
sdkmanager "platform-tools" "platforms;${ANDROID_PLATFORM}" "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null
flutter config --android-sdk "${ANDROID_SDK_ROOT}" >/dev/null || true

echo ">>> [3/4] Dependências do projeto"
flutter pub get
( cd packages/goel_domain && dart pub get )

echo ">>> [4/4] flutter doctor"
flutter doctor -v || true

echo "✅ Ambiente Flutter pronto: flutter pub get / analyze / test / build apk disponíveis."
