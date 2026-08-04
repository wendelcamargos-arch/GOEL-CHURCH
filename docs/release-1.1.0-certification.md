# GOEL CHURCH — Final Release Certification (Release 1.1.0)

> **✅ STATUS: RELEASE CERTIFIED.** Release 1.1.0 (Version Code 9) oficialmente
> APROVADA pelo Owner em 2026-08-04. AAB oficial gerado e assinado (run #13).
> Candidata oficial para publicação. Projeto em **FASE DE HOMOLOGAÇÃO** —
> nenhuma implementação/Sprint nova (ver `GO_LIVE_CHECKLIST.md`).

```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  9
STATUS        RELEASE CERTIFIED
```

## Identidade da Release

| Campo | Valor |
|---|---|
| **Version Name** | `1.1.0` |
| **Version Code** | `9` |
| **Branch** | `claude/projeto-goel-v0f6ya` |
| **Commit** | HEAD da branch no momento da autorização (inclui RC1) |
| **Destino** | Internal Testing (teste do Owner antes da lista de e-mails) |
| **Assinatura** | Keystore oficial `goel` (SHA1 `31:E8:C6`), via secrets do CI |

### Nota sobre o Version Code 9

- O código **8** já foi publicado no Google Play (run #8).
- O código **9** foi certificado antes (commit `cd5201e`), porém **não chegou a
  ser publicado** no Play — o Owner ainda estava testando.
- A RC1 **substitui** aquele build. O AAB final da 1.1.0 será **code 9**
  reconstruído a partir do HEAD atual (com RC1). Como o code 9 nunca foi
  publicado, reutilizá-lo é válido (9 > 8, e nenhum code 9 está no Play).

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
| Workflow Run | **#13** (`30939842122`) — ✅ success |
| Commit SHA do build | `45692f7988e02360af4a2731d9aa5d2fa41af4e4` |
| Artefato | `goel-church-aab` → `app-release.aab` |
| Tamanho | **55.888.205 bytes** (~53,3 MB) |
| SHA-256 | `dfa2195765f68f0aacf740634fa42aefca9714913ccd66eedff601f15f064e5f` |
| Build iniciado (UTC) | 2026-08-04 18:42:01 |
| Build concluído (UTC) | 2026-08-04 18:48:58 |
| Duração | ~6 min 57 s |
| Artefato expira em | 2026-08-18 (baixar antes) |

## Autorização

- [x] **Owner autorizou gerar o AAB da Release 1.1.0 (code 9).** — 2026-08-04.

> AAB gerado, assinado (keystore `goel`, SHA1 `31:E8:C6`) e certificado.
> Próximo passo: upload no Google Play → Internal Testing (sem produção).
