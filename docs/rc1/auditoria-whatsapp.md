# GOEL CHURCH — Auditoria Técnica Oficial: WhatsApp

> **STATUS: AUDITORIA APROVADA PELO OWNER.** Limitação da plataforma
> oficialmente reconhecida. Referência para a **Release 1.1.0** (fluxo
> mantido, escopo congelado) e base para a **V2.0** (ver
> `docs/v2/goel-message-hub.md`).

## Registro oficial (1.1.0)

> **Links de grupos do WhatsApp (`chat.whatsapp.com/...`) NÃO suportam mensagem
> pré-preenchida nem envio automático.** Não existe deep link oficial que aponte
> para um grupo com o parâmetro `text=`, e não existe API oficial que publique
> automaticamente em um grupo de convite existente sem interação do usuário.

Por isso, o fluxo atual de **Oração / Testemunho / Servo** monta a mensagem e
abre o WhatsApp com o texto **pronto** (`wa.me/?text=`), cabendo ao usuário
escolher o destino (grupo ou contato) e tocar em enviar. **Este comportamento é
mantido na 1.1.0.**

## Perguntas e respostas objetivas

| # | Pergunta | Resposta |
|---|----------|----------|
| 1 | Abrir `chat.whatsapp.com` com mensagem pré-preenchida? | **NÃO** — link de convite só serve para entrar no grupo; ignora `text=`. |
| 2 | Deep link oficial para **grupos** com `text=`? | **NÃO** — `text=` só funciona para **número** (`wa.me/<numero>?text=`) ou seletor genérico (`wa.me/?text=`). |
| 3 | API oficial que publique automaticamente em um grupo, sem interação? | **NÃO** para os grupos atuais — a Groups API (Cloud API) só gere grupos criados **pela própria API**, exige **Official Business Account** + backend, e não adota grupos de convite existentes. |

## Alternativas (limitação × recomendação)

**Limitação da plataforma:** sem pré-preenchimento em grupo, sem `text=` para
grupo, sem auto-post em grupo de convite existente. Único alvo oficial com
mensagem pronta = **número**.

- **Opção A — número oficial dedicado** (`wa.me/<numero>?text=`): abre o destino
  específico, mensagem pronta, "só tocar ENVIAR". Destino é um número (não o
  grupo); um responsável reposta no grupo.
- **Opção B — manter grupo com seletor** (`wa.me/?text=`, atual na 1.1.0):
  mensagem pronta; usuário escolhe o grupo e envia (1 toque a mais).
- **Opção C — WhatsApp Business Platform + Groups API** (futuro/V2.0): automação
  real, mas exige OBA + backend + custos; não adota grupos de convite atuais.

## Fontes oficiais (Meta/WhatsApp)

- How to use click to chat — https://faq.whatsapp.com/5913398998672934
- Groups API — https://developers.facebook.com/documentation/business-messaging/whatsapp/groups
- Group messaging — https://developers.facebook.com/documentation/business-messaging/whatsapp/groups/groups-messaging/
- Get started with Groups API — https://developers.facebook.com/documentation/business-messaging/whatsapp/groups/get-started

> **Decisão:** 1.1.0 mantém o fluxo atual (Opção B). A automação/moderação real
> é endereçada na **V2.0 — Goel Church Message Hub**.
