# GOEL CHURCH — Homologação do Hotfix WhatsApp (padrão copiar → abrir grupo)

> **Roteiro de homologação em dispositivo real.** Sem gerar AAB, sem alterar
> código. Fluxo em teste: **preencher → copiar mensagem → abrir grupo oficial →
> colar → Enviar**. O app **não** afirma "enviado" (diz "Preparamos sua
> mensagem"). Commit do hotfix: `1b8c0d0`.
>
> **Evidência automatizada (já verde):** `flutter analyze` limpo · `flutter test`
> **84 testes PASS**, incluindo os 10 pontos do hotfix (mensagem exata,
> clipboard, grupo correto, sem `wa.me/?text=`, falha preserva texto, copiar
> novamente, sem "enviado" falso).

## Como marcar

Para cada passo: ☐ **PASS** · ☐ **FAIL** · Observações: __________

### Dados do teste
- Testador: ______ · Data: ______ · Dispositivo: ______ · Android: ______
- Grupos oficiais existem no WhatsApp do aparelho? ☐ Sim ☐ Não

---

## TESTE 1 — TESTEMUNHO

1. Abrir **Testemunho**, preencher Nome, WhatsApp e Testemunho → tocar **Enviar
   Testemunho**.
   - ☐ Aparece a orientação **"Mensagem copiada!"** com os 3 passos.
2. **Mensagem copiada:** em qualquer campo de texto, colar e conferir o formato:
   ```
   QUEREMOS OUVIR SEU TESTEMUNHO PARA EDIFICAR CADA DIA A NOSSA FÉ

   Nome: <nome>
   WhatsApp: <telefone>

   Testemunho:
   <texto>
   ```
   - ☐ Texto colado está **íntegro e correto**.
3. **Grupo correto abre:** tocar **Abrir grupo** → abre o grupo **Testemunhos
   Goel** (não o seletor de contatos).
   - ☐ Abriu o grupo certo.
4. **Colar no grupo:** no campo do grupo, segurar → **Colar** → mensagem aparece
   íntegra → **Enviar**.
   - ☐ Mensagem íntegra no grupo.
5. **Copiar novamente:** repetir e, na orientação, tocar **Copiar novamente** →
   colar de novo.
   - ☐ Recopiou corretamente.
6. **Cancelar:** tocar **Cancelar** → fecha a orientação sem abrir o grupo; a
   tela mostra **"Preparamos sua mensagem"** (nunca "enviado").
   - ☐ Cancelou corretamente e o texto é honesto.

## TESTE 2 — PEDIDO DE ORAÇÃO

Mesmo fluxo do Teste 1, com a mensagem:
```
PEDIDO DE ORAÇÃO — GOEL CHURCH

Nome: <nome>
WhatsApp: <telefone>

Pedido:
<texto>
```
- ☐ Copiada · ☐ Grupo **Pedido de Oração** abre · ☐ Íntegra · ☐ Copiar
  novamente · ☐ Cancelar · ☐ Sem "enviado".

## TESTE 3 — QUERO SER SERVO

Mesmo fluxo, **validando a área escolhida**. Ex.: escolher **Mídia**:
```
QUERO SER SERVO — GOEL CHURCH

Nome: <nome>
WhatsApp: <telefone>
Área de interesse: Mídia

Quero servir na equipe de Mídia.
```
- ☐ Área correta na mensagem · ☐ Copiada · ☐ Grupo **Quero Ser Servo** abre ·
  ☐ Íntegra · ☐ Copiar novamente · ☐ Cancelar · ☐ Sem "enviado".
- (Opcional) escolher **2 áreas** → frase no plural ("...nas equipes de X e Y.").

## TESTE NEGATIVO — falha ao abrir o WhatsApp

Simular indisponibilidade (ex.: WhatsApp desinstalado/desabilitado, ou modo
avião) e tocar **Enviar** → **Abrir grupo**.
- ☐ App mostra aviso de que não foi possível abrir (sem travar).
- ☐ **A mensagem continua copiada** (colar em outro app e conferir).

## TESTE DE UX

- **Clareza:** a orientação (colar e enviar) é compreensível? ☐ Sim ☐ Não
- **Tempo:** o fluxo é rápido (copiar + abrir grupo)? ☐ Sim ☐ Não
- **Orientações:** os 3 passos ajudam a concluir? ☐ Sim ☐ Não
- **Facilidade:** um membro leigo consegue sozinho? ☐ Sim ☐ Não
- Observações de UX: __________

---

## Resultado da homologação

| Teste | Resultado |
|---|---|
| 1 — Testemunho | ☐ PASS · ☐ FAIL |
| 2 — Pedido de Oração | ☐ PASS · ☐ FAIL |
| 3 — Quero Ser Servo | ☐ PASS · ☐ FAIL |
| Negativo (falha ao abrir) | ☐ PASS · ☐ FAIL |
| UX | ☐ PASS · ☐ FAIL |

### GATE FINAL
- ☐ **PASS COMPLETO** → autorizar geração da **RC Code 12**.
- ☐ **FAIL** → abrir DEF no `DEFECT_LOG` (não gerar build).

> **Nenhum build antes da homologação.** A RC **Code 12** só é gerada após
> **PASS completo** e **autorização do Owner**.
