# Handoff técnico — Goel Church MVP 01–07 (para Davi)

Objetivo: **entregar um APK instalável e distribuído por Firebase App
Distribution**, com o MVP 01–07 funcional. Este documento é autossuficiente.

**Escopo travado:** somente Slices 01–07. NÃO alterar arquitetura, ADRs,
domínio, nem iniciar 08–09 (oração / IA pastoral — bloqueados por LGPD).

---

## PARTE 1 — Estado revisado do projeto

Já verificado (por análise estática / Postgres local):
- ✅ **Patch cumulativo** `GOEL-CHURCH-mvp-slices-01-07-completo.patch` aplica
  **limpo** sobre a `main` atual (`git am`), 7 slices + estabilização de casts.
- ✅ **Migrações** `0001–0003` aplicam e são **idempotentes** (validadas em
  PostgreSQL 16 com shim Supabase: roles + `auth.uid()`).
- ✅ **11 testes** (domínio + widget), 6 Edge Functions, assets JSON válidos.

Ainda NÃO verificado (depende de você, Davi — precisa de toolchain/rede):
- `flutter analyze/test/build`, deploy Supabase, distribuição Firebase, install.

---

## PARTE 2 — Pré-requisitos (versões)

| Ferramenta | Versão | Uso |
|---|---|---|
| Flutter | stable (≥ 3.22) | build/test |
| Dart | vem com o Flutter | testes de domínio |
| Android SDK + cmdline-tools | platform 34 | build APK |
| Java (JDK) | 17 (Temurin) | Gradle/Android |
| Firebase CLI | atual | (opcional; o CI usa a action) |
| Supabase CLI | atual | migrações + Edge Functions |
| GitHub CLI | opcional | disparar/ver workflows |

Instalação local rápida:
```bash
flutter doctor        # deve ficar tudo verde p/ Android
dart --version
java -version         # 17
```

---

## PARTE 3 — Setup do Firebase (console, uma vez)

1. **Projeto**: criar `goel-church` (ou usar existente).
2. **App Android**: registrar com o applicationId **`br.com.goelchurch.goel_church`**
   (o mesmo que o build vai usar em `flutter create --org br.com.goelchurch`).
   Anotar o **App ID** (formato `1:123...:android:abc...`).
3. **App Distribution → Testadores**: criar o grupo **`testadores-internos`** e
   incluir o **e-mail do Owner**.
4. **Service Account** (Google Cloud Console → IAM → Contas de serviço):
   criar conta, papel **Firebase App Distribution Admin**, gerar **chave JSON**.

> `google-services.json` **NÃO é necessário** só para distribuir (é para o
> Firebase SDK no app, ex.: push). Fica de fora do escopo do MVP.

---

## PARTE 4 — Secrets do GitHub (Settings → Secrets → Actions)

| Secret | Conteúdo | Para quê |
|---|---|---|
| `FIREBASE_ANDROID_APP_ID` | App ID do Firebase | upload App Distribution |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | JSON da service account | auth do upload |
| `SUPABASE_URL` | `https://rzxeqvczjfwcggkgcsxw.supabase.co` | `--dart-define` no build |
| `SUPABASE_ANON_KEY` | anon/publishable key | `--dart-define` no build |

**Obsoletos — NÃO usar:** `FIREBASE_CI_TOKEN` (descontinuado; use a service
account), `google-services.json` (fora de escopo).

> Sem `SUPABASE_URL` + `SUPABASE_ANON_KEY` no build, o app abre em
> "Supabase não configurado" e **não chega ao login**.

---

## PARTE 5 — Build Android (local ou CI)

```bash
# aplicar o código (sobre a main atual)
git checkout -B mvp main
git am --3way < patches/GOEL-CHURCH-mvp-slices-01-07-completo.patch

flutter pub get
dart format --set-exit-if-changed .          # se acusar, rode 'dart format .' e commite
flutter analyze
flutter test
( cd packages/goel_domain && dart pub get && dart test )

# gerar a pasta android/ (não versionada — é boilerplate)
flutter create --org br.com.goelchurch --platforms=android,ios .

# APK release (assinado em debug: instalável p/ teste interno; NÃO serve p/ Play)
flutter build apk --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
# saída: build/app/outputs/flutter-apk/app-release.apk
```

---

## PARTE 6 — Workflow de distribuição (`.github/workflows/distribuicao.yml`)

```yaml
name: Distribuição Interna (Firebase App Distribution)
on: { workflow_dispatch: {}, push: { branches: [main] } }
env:
  PATCH_FILE: patches/GOEL-CHURCH-mvp-slices-01-07-completo.patch
jobs:
  build-distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: git config --global user.name CI && git config --global user.email ci@goel.church
      - run: git am --3way < "$PATCH_FILE"
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test
      - run: flutter create --org br.com.goelchurch --platforms=android .
      - run: |
          flutter build apk --release \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}
      - uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_JSON }}
          groups: testadores-internos
          file: build/app/outputs/flutter-apk/app-release.apk
          releaseNotes: "MVP 01-07 — build ${{ github.sha }}"
```
Se um passo falhar: identificar causa raiz, corrigir só ela, repetir.

---

## PARTE 7 — Backend (necessário para o app funcionar de verdade)

Distribuir o APK o torna **instalável e aberto** (splash/home). Mas
**login, versículo NVI, devocional e persistência** dependem do **backend**:

```bash
supabase link --project-ref rzxeqvczjfwcggkgcsxw
supabase db push        # migrações 0001–0003 (já validadas)
supabase functions deploy request-otp verify-otp select-identity \
                          save-profile birthday-greetings verse-of-the-day
# secrets server-side (ver supabase/functions/README.md):
supabase secrets set OTP_PEPPER=... META_WHATSAPP_TOKEN=... \
  META_WHATSAPP_PHONE_NUMBER_ID=... META_WHATSAPP_OTP_TEMPLATE=... \
  BIBLE_API_KEY=... BIBLE_NVI_ID=... SCHEDULER_SECRET=...
```
Dependências externas que o Owner precisa prover: **Meta WhatsApp Business API**
(número verificado + templates OTP e aniversário aprovados) e **API bíblica
licenciada** (NVI). Sem elas: login OTP não completa e o versículo cai no
**fallback offline de domínio público**.

Pré-registrar ao menos 1 membro para testar login:
```sql
insert into identities (display_name, state) values ('Owner', 'pre_registered')
  returning id;
insert into phone_identity_links (phone_e164, identity_id)
  values ('+55DDDNUMERO', '<id_retornado>');
```

---

## PARTE 8 — Validação funcional (checklist)

Só com APK distribuído:
- [ ] APK instala no Android
- [ ] app abre / splash
- [ ] Home abre (após cadastro; ou tela de bootstrap se backend ausente)

Com backend provisionado (PARTE 7):
- [ ] Login WhatsApp OTP recebe e valida código
- [ ] Cadastro salva perfil
- [ ] Versículo do dia (NVI online, ou fallback offline)
- [ ] Devocional (lista → detalhe)
- [ ] Comunicação Supabase / persistência do perfil

---

## ENTREGA (Davi preenche)

1. Status Flutter: ____  2. Android Build: ____  3. Firebase: ____
4. Supabase: ____  5. GitHub Actions: ____
6. Link App Distribution: ____
7. Localização do APK: `build/app/outputs/flutter-apk/app-release.apk`
8. Funcionalidades OK: ____
9. Pendências: ____
10. Próxima etapa recomendada: ____

---

## Ordem recomendada para o Davi
1. Setup Firebase (PARTE 3) + secrets (PARTE 4).
2. Rodar workflow (PARTE 6) → APK distribuído → validar install/abre (PARTE 8, bloco 1).
3. Provisionar backend (PARTE 7) → validar login/conteúdo (PARTE 8, bloco 2).
4. Trazer qualquer log de erro ao arquiteto (Claude) para causa raiz.
