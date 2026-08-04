# GOEL CHURCH — Final Release Certification (Release 1.1.0)

> **✅ STATUS: RELEASE CERTIFIED.** Release 1.1.0 (Version Code **10**)
> oficialmente APROVADA pelo Owner em 2026-08-04. AAB oficial gerado e assinado
> (run #14). Candidata oficial para publicação. Projeto em **FASE DE
> HOMOLOGAÇÃO** — nenhuma implementação/Sprint nova (ver `GO_LIVE_CHECKLIST.md`).
>
> **Histórico de versionCode:** code 9 (run #13) foi **recusado pelo Google
> Play** ("código de versão 9 já foi usado" — DEF-GP-01). Subimos para **code
> 10**; este é o artefato oficial da 1.1.0.

```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  10
STATUS        RELEASE CERTIFIED
```

## Identidade da Release

| Campo | Valor |
|---|---|
| **Version Name** | `1.1.0` |
| **Version Code** | `10` |
| **Branch** | `claude/projeto-goel-v0f6ya` |
| **Commit** | `f60c9a1b24d4b56e7a40e7016c080751453c223d` |
| **Destino** | Internal Testing (NÃO Produção) |
| **Assinatura** | Keystore oficial `goel` (SHA1 `31:E8:C6`), via secrets do CI |

### Nota sobre o Version Code (histórico)

- Código **8** — publicado no Google Play (run #8).
- Código **9** — gerado (runs #12/#13), mas **recusado no upload** pelo Play:
  "O código de versão 9 já foi usado." Registrado como **DEF-GP-01**.
- Código **10** — build oficial atual (run #14). `version: 1.1.0+10` no
  pubspec e `--build-number=10` no workflow. Version name segue `1.1.0`.

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
| Workflow Run | **#14** (`30947625225`) — ✅ success |
| Commit SHA do build | `f60c9a1b24d4b56e7a40e7016c080751453c223d` |
| Artefato | `goel-church-aab` → `app-release.aab` |
| Tamanho | **55.888.212 bytes** (~53,3 MB) |
| SHA-256 | `07b9f5908ad7a646bfc9e4803aefe70a5f20abdfe808ba8cbd7d63a8e759d341` |
| Build iniciado (UTC) | 2026-08-04 20:23:22 |
| Build concluído (UTC) | 2026-08-04 20:30:09 |
| Duração | ~6 min 47 s |
| Artefato expira em | 2026-08-18 (baixar antes) |

## Autorização

- [x] **Owner autorizou gerar o AAB da Release 1.1.0.** — 2026-08-04.
- [x] versionCode ajustado 9 → **10** (DEF-GP-01) para aceitar o upload.

> AAB gerado, assinado (keystore `goel`, SHA1 `31:E8:C6`) e certificado.
> Próximo passo: upload no Google Play → Internal Testing (sem produção).
