# Distribuição interna — Firebase App Distribution

Distribui cada build de teste aos testadores **sem passar pela Google Play**.
A automação (CI) faz o build do APK e envia ao Firebase App Distribution após
cada push bem-sucedido na `main`.

> App Distribution **não requer** a Google Play nem o Firebase SDK embutido no
> app — ele apenas hospeda e entrega o APK aos testadores. O APK de release é
> assinado com a chave de debug (instalável para teste interno; **não** serve
> para publicar na Play).

## Setup do Owner (uma vez, no console)

1. **Firebase** → criar/usar um projeto (ex.: `goel-church`).
2. **Adicionar app Android**: informe o **package name** (applicationId). Ele
   precisa ser o MESMO usado no build. Defina um org e gere a pasta Android com:
   ```bash
   flutter create --org br.com.goelchurch --platforms=android,ios .
   # → applicationId: br.com.goelchurch.goel_church
   ```
   Registre exatamente esse package no Firebase. Anote o **App ID**
   (formato `1:1234567890:android:abc123`).
3. **App Distribution** → aba Testadores → criar o grupo **`testadores-internos`**
   e adicionar os e-mails dos testadores.
4. **Credencial de serviço**: Google Cloud Console → IAM → contas de serviço →
   criar conta com o papel **Firebase App Distribution Admin** → gerar chave
   **JSON**.

## Segredos do GitHub (Settings → Secrets → Actions)

| Secret | Valor |
|---|---|
| `FIREBASE_ANDROID_APP_ID` | o App ID do passo 2 |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | conteúdo do JSON do passo 4 |

## Como funciona depois

- Cada push na `main` dispara o workflow `distribuicao.yml`:
  aplica o patch → `flutter analyze`/`test` → `flutter create` (gera Android) →
  `flutter build apk --release` → upload ao App Distribution (grupo
  `testadores-internos`).
- Os testadores recebem e-mail/notificação com o link para instalar.

## Versão / Build Number

Controlados pelo `pubspec.yaml`: `version: 0.1.0+1` → **versionName 0.1.0**,
**versionCode/buildNumber 1**. Suba esse número a cada release
(ex.: `0.1.0+2`, `0.1.1+3`).

## Pendências para funcionamento completo (ação do Owner)

- Projeto Firebase criado + app Android registrado (App ID).
- Grupo `testadores-internos` com e-mails.
- Os 2 secrets configurados no GitHub.
- (Opcional) definir applicationId definitivo antes do primeiro registro.
