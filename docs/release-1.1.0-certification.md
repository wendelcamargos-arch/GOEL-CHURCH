# GOEL CHURCH — Final Release Certification (Release 1.1.0)

> **🚀 STATUS: PUBLICADO EM INTERNAL TESTING.** Release 1.1.0 (Version Code
> **12**) oficialmente APROVADA pelo Owner e **enviada ao Google Play →
> Teste Interno** em 2026-08-05. Upload aceito pelo Play. **Em homologação
> com a equipe de testadores** (Owner + testadores internos). AAB oficial
> gerado e assinado (run #16). **Substitui o code 11**, que deixa de ser a
> candidata.
>
> **Motivo do code 12:** duas melhorias de UX aprovadas formalmente pelo
> Owner em 2026-08-05 — (1) rótulo "Generosidade" em uma única linha na barra
> inferior; (2) grade "Ir para o versículo" na leitura da Bíblia. Build
> baseado no commit `223f310`.

```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  12
STATUS        EM INTERNAL TESTING (homologação)
```

## Identidade da Release

| Campo | Valor |
|---|---|
| **Version Name** | `1.1.0` |
| **Version Code** | `12` |
| **Branch** | `claude/projeto-goel-v0f6ya` |
| **Commit** | `223f310488ef55bec91bbba5b2c4f754a2844595` |
| **Destino** | Internal Testing (NÃO Produção) |
| **Assinatura** | Keystore oficial `goel` (SHA1 `31:E8:C6`), via secrets do CI |

### Nota sobre o Version Code (histórico)

- Código **8** — publicado no Google Play (run #8).
- Código **9** — gerado (runs #12/#13), mas **recusado no upload** pelo Play:
  "O código de versão 9 já foi usado." Registrado como **DEF-GP-01**.
- Código **10** — build gerado (run #14); **substituído** antes do upload
  definitivo pela Home refinada. Deixa de ser a candidata oficial.
- Código **11** — build oficial (run #15). Certificado; **substituído** pelo
  code 12 antes do upload, ao incorporar as melhorias de UX aprovadas.
- Código **12** — build oficial atual (run #16). `version: 1.1.0+12` no pubspec
  e `--build-number=12` no workflow. **Candidata oficial** da 1.1.0 —
  **enviada e aceita** no Google Play → Internal Testing (2026-08-05).

### Conteúdo confirmado (code 12)

✓ Home refinada · ✓ **Barra inferior: "Generosidade" em uma linha** ·
✓ **Bíblia: grade "Ir para o versículo"** · ✓ Splash · ✓ Login · ✓ Cadastro ·
✓ Bible Engine · ✓ Redes Sociais · ✓ Google Maps · ✓ RC1 completo ·
✓ Hotfix WhatsApp (copiar → abrir grupo → colar) · ✓ Todos os links oficiais.

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
- `flutter test` → **84 testes verdes**.
- Sem alterações em domínio/arquitetura/Firebase/Supabase/auth — só a camada
  de apresentação.

## Artefato (build oficial)

| Campo | Valor |
|---|---|
| Workflow Run | **#16** (`31007147042`) — ✅ success |
| Commit SHA do build | `223f310488ef55bec91bbba5b2c4f754a2844595` |
| Artefato | `goel-church-aab` → `app-release.aab` |
| Tamanho | **55.929.236 bytes** (~53,3 MB) |
| SHA-256 | `039428565c1f5e2b6240ae276f99c1855532343c639cfa95451a4fcd6f75a1aa` |
| Build iniciado (UTC) | 2026-08-05 12:46:59 |
| Build concluído (UTC) | 2026-08-05 12:53:31 |
| Duração | ~6 min 32 s |
| Artefato expira em | 2026-08-19 (baixar antes) |

> **Artefato anterior (code 11, run #15, SHA-256 `e52cd6c8…1dc5`) — SUPERSEDED.**
> Não usar. A candidata oficial é o **code 12** acima.

## Autorização & Publicação

- [x] **Owner aprovou as duas melhorias de UX** (barra inferior + grade de
  versículos). — 2026-08-05.
- [x] **Owner autorizou gerar o AAB do code 12.** — 2026-08-05.
- [x] versionCode **12** — candidata oficial; substitui definitivamente o code 11.
- [x] `flutter analyze` limpo · `flutter test` **84/84 PASS**.
- [x] AAB gerado, assinado (keystore `goel`, SHA1 `31:E8:C6`) e certificado.
- [x] **Upload no Google Play → Internal Testing — ACEITO** (2026-08-05).
- [ ] Homologação em dispositivo (Owner + testadores) — **EM ANDAMENTO**.
- [ ] Critério de saída: **0 críticos + 0 altos** → promover para Closed Testing.
