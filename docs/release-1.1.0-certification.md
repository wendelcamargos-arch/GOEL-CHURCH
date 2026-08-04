# GOEL CHURCH — Final Release Certification (Release 1.1.0)

> **✅ STATUS: RELEASE CERTIFIED.** Release 1.1.0 (Version Code **11**)
> oficialmente APROVADA pelo Owner em 2026-08-04. AAB oficial gerado e assinado
> (run #15). **Candidata oficial** para publicação — **substitui o code 10**,
> que deixa de ser a candidata. Projeto em **FASE DE HOMOLOGAÇÃO** — escopo
> congelado.
>
> **Motivo do code 11:** refinamento visual da Home aprovado formalmente pelo
> Owner (Opção B) — build baseado no commit `ff84a84` (Home refinada).

```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  11
STATUS        RELEASE CERTIFIED
```

## Identidade da Release

| Campo | Valor |
|---|---|
| **Version Name** | `1.1.0` |
| **Version Code** | `11` |
| **Branch** | `claude/projeto-goel-v0f6ya` |
| **Commit** | `b35671a959909f8d10ca52b4a97a1ab3c2e6a803` (base: `ff84a84`) |
| **Destino** | Internal Testing (NÃO Produção) |
| **Assinatura** | Keystore oficial `goel` (SHA1 `31:E8:C6`), via secrets do CI |

### Nota sobre o Version Code (histórico)

- Código **8** — publicado no Google Play (run #8).
- Código **9** — gerado (runs #12/#13), mas **recusado no upload** pelo Play:
  "O código de versão 9 já foi usado." Registrado como **DEF-GP-01**.
- Código **10** — build gerado (run #14); **substituído** antes do upload
  definitivo pela Home refinada. Deixa de ser a candidata oficial.
- Código **11** — build oficial atual (run #15). `version: 1.1.0+11` no pubspec
  e `--build-number=11` no workflow. **Candidata oficial** da 1.1.0.

### Conteúdo confirmado (code 11)

✓ Home refinada · ✓ Splash · ✓ Login · ✓ Cadastro · ✓ Bible Engine ·
✓ Redes Sociais · ✓ Google Maps · ✓ RC1 completo · ✓ Todos os links oficiais.

## Conteúdo da Release 1.1.0

**Base (já entregue):**
- 📖 Bíblia offline completa (Almeida 1911 · 66 livros · 1.189 capítulos ·
  31.102 versículos): leitura, busca, favoritos, marca-textos, anotações,
  planos, compartilhar.
- 🔗 Redes Sociais: Instagram · YouTube (@Goel_Church) · Grupo WhatsApp ·
  Como chegar (Maps).
- 📝 PALAVRAS: 3 publicações abrindo pastas do Google Drive.

**RC1 (aprovado — entra na 1.1.0):**
- 🙏 Oração / Testemunho / Servo: mensagem pronta no WhatsApp (usuário escolhe
  o destino) — limitação oficial da plataforma registrada.
- 🗓️ Escalas: equipe editável (adicionar/editar/remover/reordenar).
- 🏠 Home: frase institucional acima da saudação.

**Fora desta Release (por decisão do Owner):**
- Membros e Aniversariantes com dados reais → dependem de LGPD (EU-09) +
  backend/endpoint/política de acesso.
- Bíblia híbrida (EU-08) → arquitetura aprovada, implementação futura.

## Qualidade (verificada)

- `flutter analyze` → **No issues found**.
- `flutter test` → **79 testes verdes**.
- Sem alterações em domínio/arquitetura/Firebase/Supabase/auth.

## Artefato (build oficial)

| Campo | Valor |
|---|---|
| Workflow Run | **#15** (`30960306833`) — ✅ success |
| Commit SHA do build | `b35671a959909f8d10ca52b4a97a1ab3c2e6a803` |
| Artefato | `goel-church-aab` → `app-release.aab` |
| Tamanho | **55.889.323 bytes** (~53,3 MB) |
| SHA-256 | `e52cd6c814454d7211a2430ab1005a183ce1ec6d3781b628593a7edeee031dc5` |
| Build iniciado (UTC) | 2026-08-04 23:32:00 |
| Build concluído (UTC) | 2026-08-04 23:39:18 |
| Duração | ~7 min 18 s |
| Artefato expira em | 2026-08-18 (baixar antes) |

> **Artefato anterior (code 10, run #14, SHA-256 `07b9f590…d341`) — SUPERSEDED.**
> Não usar. A candidata oficial é o **code 11** acima.

## Autorização

- [x] **Owner autorizou gerar o AAB da Release 1.1.0 (Opção B).** — 2026-08-04.
- [x] versionCode **11** — candidata oficial; substitui definitivamente o code 10.
- [x] `flutter analyze` limpo · `flutter test` **79/79 PASS**.

> AAB gerado, assinado (keystore `goel`, SHA1 `31:E8:C6`) e certificado.
> Próximo passo: upload no Google Play → Internal Testing (sem produção).
