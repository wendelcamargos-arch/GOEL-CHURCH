# GOEL CHURCH — Homologação em Ondas (1.1.0)

> **STATUS: QUALITY ASSURANCE.** Candidata oficial **1.1.0 (code 11)** ·
> **code 10 = SUPERSEDED**. Escopo **congelado**: nenhuma funcionalidade nova,
> nenhuma alteração de arquitetura, **nenhuma abertura da V2.0** antes do
> encerramento oficial da homologação.
>
> **Trilha:** `Google Play → Internal Testing → TEST_PLAN_1.1.0 → DEFECT_LOG →
> RELEASE_BOARD`.
>
> A homologação é organizada em **5 ondas**. Cada onda usa os casos do
> `TEST_PLAN_1.1.0.md`; defeitos vão para `DEFECT_LOG.md` (registro) e
> `RELEASE_BOARD.md` (fluxo).

## Candidata oficial

```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  11        (candidata oficial)
CODE 10       SUPERSEDED
SHA-256       e52cd6c814454d7211a2430ab1005a183ce1ec6d3781b628593a7edeee031dc5
RUN           #15 (30960306833) · commit b35671a
```

---

## ONDA 1 — Fluxo principal
**Módulos:** Splash · Login · Cadastro · Home
**Casos (TEST_PLAN):** S-01, S-02 · L-01, L-02, L-03 · C-01, C-02, C-03 ·
H-01, H-02, H-03
**Foco:** app abre sem tela branca/freeze; login/sessão; cadastro persiste;
Home refinada (logo/nome/slogan/saudação centralizados; 4 cards sem rolagem).
**Saída da onda:** 0 críticos e 0 altos nestes módulos.

## ONDA 2 — Bible Engine
**Módulos:** Versículo do Dia · Bible Engine · Busca · Favoritos · Planos ·
Compartilhar
**Casos:** V-01, V-02 · B-01…B-08 · BU-01, BU-02 · F-01, F-02 · P-01, P-02 ·
CS-01
**Foco:** capítulo completo (Salmos 119 = 176 versículos), rolagem contínua,
modos Púlpito/Culto, busca por referência/palavra, favoritos, planos,
compartilhar.
**Saída da onda:** 0 críticos e 0 altos nestes módulos.

## ONDA 3 — Comunidade
**Módulos:** Comunidade · Testemunhos · Pedidos de Oração · Quero Ser Servo ·
Goel Home · Gabinete Pastoral · Redes Sociais · Google Maps
**Casos:** CM-01 · T-01, T-02 · O-01, O-02 · QS-01, QS-02 · GH-01 · G-01, G-02 ·
R-01, R-02, R-03 · M-01
**Foco:** mensagem pronta no WhatsApp (limitação oficial reconhecida),
entrar nos grupos, contatos do gabinete, redes e localização (Maps).
**Saída da onda:** 0 críticos e 0 altos nestes módulos.

## ONDA 4 — Administração
**Módulos:** Escalas · Configurações (aba "Mais")
**Casos:** E-01, E-02, E-03 · CF-01, CF-02
**Foco:** escalas com equipe editável (adicionar/editar/remover/reordenar) e
rodízio ao vivo; índice de recursos; logout limpa a sessão.
**Saída da onda:** 0 críticos e 0 altos nestes módulos.

## ONDA 5 — Estabilidade
**Módulos:** transversal (todos)
**Foco:** abertura a frio/quente sem freeze; uso prolongado (Modo Culto sem
travar); comportamento offline (Bíblia funciona sem rede); navegação repetida
entre abas; consumo/tamanho aceitável; ausência de crashes.
**Casos:** repetir S-01/S-02 + varredura geral; observar performance e
estabilidade ao longo da rodada completa.
**Saída da onda:** 0 críticos e 0 altos; nenhum crash reproduzível.

---

## Placar de encerramento (por onda e global)

| Onda | Críticos | Altos | Status |
|---|---|---|---|
| 1 — Fluxo principal | 0 | 0 | ☐ concluída |
| 2 — Bible Engine | 0 | 0 | ☐ concluída |
| 3 — Comunidade | 0 | 0 | ☐ concluída |
| 4 — Administração | 0 | 0 | ☐ concluída |
| 5 — Estabilidade | 0 | 0 | ☐ concluída |
| **GLOBAL** | **0** | **0** | ☐ pronto |

> Fonte de verdade dos números: `DEFECT_LOG.md` / `RELEASE_BOARD.md`.

## Critério de conclusão

Somente após **ZERO defeitos críticos** e **ZERO defeitos altos** (global):

### ▶ Emitir: **RELEASE READY FOR PRODUCTION**

Registro a ser emitido no encerramento:
```
GOEL CHURCH
RELEASE   1.1.0 (code 11)
STATUS    RELEASE READY FOR PRODUCTION
CRITÉRIO  Críticos = 0 · Altos = 0 (todas as 5 ondas)
DATA      <preencher>
```

> **Nenhuma implementação da V2.0** antes do encerramento oficial da
> homologação. Após a produção (com autorização do Owner), abre-se a V2.0.
