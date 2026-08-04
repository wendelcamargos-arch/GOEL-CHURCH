# GOEL CHURCH — Known Issues 1.1.0

> Limitações **conhecidas** que **não impedem a publicação** da 1.1.0. São
> decisões/escopos deliberados (não defeitos abertos). Defeitos reprodutíveis
> vão para o `DEFECT_LOG.md` / `RELEASE_BOARD.md`.
>
> Versão: **1.1.0 (code 10)** · Fase: **QUALITY ASSURANCE**.

| ID | Descrição | Motivo | Impacto | Versão prevista | Status |
|----|-----------|--------|---------|-----------------|--------|
| **KI-01** | Diretório de **Membros** mostra dados de exemplo (não os membros reais). | Não há caminho de leitura de perfis; exige backend/endpoint + **LGPD** (EU-04/EU-09). | Baixo — tela informativa; não bloqueia uso. | **V2.0** (Pilar 2) | Planejado |
| **KI-02** | **Aniversariantes** mostra exemplos (não os reais). | Persistência da data existe, mas falta leitura; exige backend + **LGPD** (EU-07/EU-09). | Baixo — informativo. | **V2.0** (Pilar 2) | Planejado |
| **KI-03** | Oração/Testemunho/Servo **não postam automaticamente no grupo**; abrem o WhatsApp com a mensagem pronta e o usuário escolhe o destino. | **Limitação oficial do WhatsApp** (sem `text=` para grupo, sem auto-post em grupo de convite) — ver `docs/rc1/auditoria-whatsapp.md`. | Baixo — 1 toque a mais (escolher o grupo). | **V2.0** (Pilar 1 — Message Hub) | Aceito (limitação de plataforma) |
| **KI-04** | **Bíblia** é 100% offline (Almeida 1911); sem modo online/outras versões. | Modo híbrido planejado; depende de backend + licenciamento (EU-08). | Baixo — leitura completa garantida offline. | **V2.0** (Pilar 3) | Planejado |
| **KI-05** | Sem **monitoramento de crash/erros** (ex.: Sentry). | Decisão de não usar Firebase; ferramenta a definir. | Médio — sem telemetria automática de falhas nesta fase. | A decidir (pós‑1.1.0) | Em decisão |
| **KI-06** | Sem **moderação/histórico** das mensagens da comunidade. | Message Hub (fila, aprovação, auditoria) é escopo da 2.0. | Baixo — fluxo atual via WhatsApp funciona. | **V2.0** (Pilar 1) | Planejado |

> Estas limitações foram **revisadas e aceitas** para a publicação da 1.1.0.
> Nenhuma delas é defeito crítico ou alto.
