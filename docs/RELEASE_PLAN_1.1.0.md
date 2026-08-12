# GOEL CHURCH — Plano de Release 1.1.0

> **DECISÃO OFICIAL DO OWNER:** a Release **1.1.0 (Version Code 9)** **NÃO**
> será publicada em Produção agora. Destino oficial: **Google Play → Internal
> Testing**. Escopo **congelado** — nenhuma funcionalidade nova, nenhuma Sprint
> nova, somente correções de defeitos via `DEFECT_LOG.md`.

## Trilha oficial (progressão)

```
Google Play
   │
   ▼
INTERNAL TESTING   ← etapa atual (homologação em dispositivos reais)
   │  critério: DEFECT_LOG → CRÍTICOS = 0  e  ALTOS = 0
   ▼
CLOSED TESTING     ← só após o critério acima
   │  aprovação do Closed Testing
   ▼
PRODUÇÃO           ← só após Closed Testing aprovado + autorização do Owner
```

## Etapa atual — Internal Testing

- **Objetivo:** homologação em **dispositivos reais**.
- **Duração prevista:** **3 dias**.
- **Durante o período:** **todo** defeito entra obrigatoriamente no
  `DEFECT_LOG.md`, seguindo o fluxo oficial:
  ```
  DEF → Evidência → Auditoria → Causa raiz → Correção mínima →
  flutter analyze → flutter test → Nova homologação → Fechamento
  ```

## Critério para ENCERRAR o Internal Testing

| Métrica | Meta |
|---|---|
| Defeitos **CRÍTICOS** abertos | **0** |
| Defeitos **ALTOS** abertos | **0** |

> Médios/baixos não bloqueiam o encerramento do Internal Testing, mas ficam
> registrados. Conferir sempre o **Placar** do `DEFECT_LOG.md`.

## Portões seguintes

1. **Closed Testing** — autorizado **somente** após CRÍTICOS = 0 e ALTOS = 0.
2. **Produção** — autorizada **somente** após Closed Testing aprovado e
   **autorização explícita do Owner** (ver `GO_LIVE_CHECKLIST.md`, bloco
   Produção: Política de Privacidade, Data Safety, etc.).

## Regras da fase

- Nenhuma funcionalidade nova · nenhuma Sprint nova.
- Somente correções de defeitos, cada uma com um `DEF` aberto.
- Escopo 1.1.0 permanece **congelado**.

---

### Registro
```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  9
STATUS        RELEASE CERTIFIED
DESTINO       Internal Testing (NÃO Produção)
JANELA        ~3 dias (homologação em dispositivos reais)
SAÍDA         Críticos = 0 e Altos = 0  →  Closed Testing  →  Produção
```
