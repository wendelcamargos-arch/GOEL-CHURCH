# RC1 — Decisão Oficial do Owner

**Status geral: RC1 APROVADO.** Projeto liberado para preparação da Release
1.1.0. **Nenhuma funcionalidade adicional** entra nesta versão — apenas
correções de defeitos.

## Decisões por item

| Item | Decisão | Registro |
|---|---|---|
| **EU-01 Oração** | ✅ **APROVADO** | Manter implementação: mensagem pré-preenchida; usuário escolhe o destino e envia. Registrado como **limitação oficial da plataforma WhatsApp**. |
| **EU-02 Testemunho** | ✅ **APROVADO** | Mesmo fluxo. |
| **EU-03 Quero ser Servo** | ✅ **APROVADO** | Mensagem por área escolhida. |
| **EU-04 Membros** | ⛔ **NÃO IMPLEMENTAR** | Aguardar aprovação definitiva da estratégia LGPD. Dependências: **Backend · Endpoint · Política de acesso**. |
| **EU-05 Escalas** | ✅ **APROVADO** | Lista editável (adicionar/editar/remover/reordenar). |
| **EU-06 Home** | ✅ **APROVADO** | Frase institucional acima da saudação. |
| **EU-07 Aniversariantes** | ⛔ **NÃO IMPLEMENTAR** | Mesma dependência de EU-04. |
| **EU-08 Bíblia híbrida** | 📄 **ARQUITETURA APROVADA** | Não implementar nesta Release; planejar posteriormente. |
| **EU-09 LGPD** | 📄 **DOCUMENTO APROVADO** | **Pré-requisito obrigatório** para qualquer funcionalidade que liste dados pessoais. |

## Limitação oficial registrada (WhatsApp)

A plataforma WhatsApp **não permite** postar/enviar automaticamente uma
mensagem em um **grupo** por link. Os fluxos de Oração, Testemunho e Servo
adotam a alternativa oficial: montam a mensagem e abrem o WhatsApp com o texto
**pronto**; o usuário escolhe o destino (grupo ou contato) e envia.

## Pré-requisito obrigatório registrado (LGPD)

Qualquer funcionalidade que **liste dados pessoais** (Membros, Aniversariantes,
etc.) só pode ser iniciada após cumprir o documento **EU-09 (LGPD)** e ter a
estratégia aprovada em definitivo (backend, endpoint e política de acesso).

## Próximos passos

1. Preparar a **Final Release Certification** da Release 1.1.0 (feito — ver
   `docs/release-1.1.0-certification.md`).
2. **Aguardar autorização do Owner** para gerar o AAB. Nada é construído antes
   disso.
