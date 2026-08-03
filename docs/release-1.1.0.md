# Release 1.1.0 — GOEL CHURCH (proposta, aguardando aprovação)

> NÃO gerar o AAB antes da aprovação do Owner.

## Versão
- **Version Name:** 1.1.0
- **Version Code:** 9 (aprovado pelo Owner)

## NOVIDADES DA VERSÃO (texto oficial da loja)
- Bíblia Offline completa
- Busca por palavra
- Busca por referência
- Favoritos
- Marca-texto
- Notas pessoais
- Continue lendo
- Compartilhar versículos
- Planos de leitura
- Melhorias gerais de estabilidade

## Release Notes (loja / usuário)
**Novidades da versão 1.1.0 — Bíblia completa offline 📖**
- Bíblia inteira (Almeida 1911, domínio público): 66 livros, leitura com
  rolagem contínua entre capítulos e livros.
- Busca por palavra e por referência ("João 3:16").
- Favoritos, marca-texto (4 cores) e anotações nos versículos.
- Planos de leitura: 30 dias, 90 dias, 1 ano e o Plano Goel Church.
- Continue lendo (retoma de onde parou) e histórico.
- Modo púlpito (fonte ampliada) e Modo culto (tela sempre ligada).
- Ajuste de tamanho da fonte e tema claro/escuro no leitor.
- Compartilhar versículo em texto ou imagem (com QR da Goel Church).
- Tudo funciona 100% offline.

## Changelog (técnico)
- [1] Importador `tool/build_biblia.dart` (valida 66/1.189/31.102).
- [2-3] `assets/biblia/manifest.json` + 66 `livros/<id>.json` (Almeida 1911).
- [4] Domínio (`BibleRepository`, `ReferenceParser`) + `AssetBibleRepository`
  (cache LRU, carga sob demanda).
- [5] Leitor reescrito: scroll contínuo, fonte, tema do leitor.
- [6] Busca por palavra (stream) e por referência.
- [7] Favoritos + persistência (`shared_preferences`).
- [8] Compartilhar: texto/imagem/imagem+QR (`share_plus`, `qr_flutter`).
- [9] Planos de leitura (assets `planos/*.json`) + progresso.
- [10] Modo púlpito/culto (`wakelock_plus`), continue lendo, histórico,
  marca-texto, anotações, "Sobre a Bíblia".

## Impacto
- **Tamanho do app:** +~4,1 MB (assets da Bíblia). Sem impacto em performance
  de leitura (carga por livro, cache LRU — nunca a Bíblia inteira em memória).
- **Novas dependências:** shared_preferences, share_plus, qr_flutter,
  wakelock_plus. Todas offline, sem API externa.
- **Permissões Android:** `wakelock_plus` adiciona `WAKE_LOCK` (tela ligada no
  Modo culto). Nenhuma permissão sensível.
- **Privacidade / Data safety:** nenhum dado novo é coletado ou enviado —
  favoritos/anotações/histórico/planos ficam **apenas no aparelho**
  (SharedPreferences). Sem mudança na declaração de privacidade.
- **Sem impacto** em Firebase (não usado), Supabase ou autenticação.
- **⚠️ versionCode:** o Teste Interno já recebeu o **código 8** (v1.0.3). O
  Google Play exige que o novo código seja **estritamente maior**. Portanto o
  código **6 seria REJEITADO**. Recomendação: **versionCode = 9**
  (Version Name 1.1.0). Confirmar antes de gerar.
- **Workflow:** `release-aab.yml` hoje usa `build-number = github.run_number`.
  Para fixar o código, mudar para `--build-number="9"` e
  `--build-name="1.1.0"`.

## Checklist final de publicação
- [ ] Definir versionCode (recomendado **9**) e versionName **1.1.0**.
- [ ] Atualizar `pubspec.yaml` (`version: 1.1.0+9`) e `release-aab.yml`
      (build-name 1.1.0 / build-number 9).
- [ ] `flutter analyze` limpo e `flutter test` verdes (atual: 74/74 ✅).
- [ ] Confirmar `WAKE_LOCK` na ficha de permissões do Play (justificativa:
      Modo culto).
- [ ] Data safety: manter "nenhum dado coletado".
- [ ] Gerar **AAB assinado** (chave de upload `31:E8:C6`) — só após aprovação.
- [ ] Upload no **Teste Interno** → homologação no aparelho → **Produção**.
