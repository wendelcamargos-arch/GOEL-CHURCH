# GOEL CHURCH 2.0 — MASTER PLAN

> **STATUS: APROVADO (Owner, 2026-08-04).** Fase de planejamento da Versão 2.0
> **oficialmente encerrada**. Apenas planejamento — **nenhuma implementação,
> nenhum código, nenhum Firebase, nenhum Flutter**. A Release **1.1.0 permanece
> congelada** (só correções de defeitos via `DEFECT_LOG.md`). Datas são
> **estimativas** a calibrar com o Owner conforme a capacidade da equipe.
>
> **Próximo foco:** Homologação da 1.1.0 → Internal Testing → Correção de
> defeitos → Abertura da 2.0. **Nenhuma implementação adicional antes do retorno
> da homologação.**
>
> **Pilares:** 1 Comunidade · 2 Membros · 3 Vida Espiritual · 4 Administração ·
> **5 Inteligência**.

---

## 1. Visão da Versão 2.0

A 1.1.0 entregou o **alicerce**: Bíblia offline, jornadas de comunidade
(Oração/Testemunho/Servo via WhatsApp), redes e conteúdo. A **2.0** transforma a
Goel Church de um app de **consumo** em uma **plataforma viva de comunidade,
pastoreio e gestão**, com dados próprios (Supabase), moderação, governança LGPD
e integrações — preservando a identidade preto e branco e a acessibilidade para
todas as idades.

> **Frase-guia:** "Uma igreja para você frequentar e uma família para você
> pertencer" — agora com **pertencimento gerenciável, seguro e escalável**.

## 2. Objetivos

1. **Dono dos dados:** mensagens e perfis passam a viver no Supabase com RLS,
   auditoria e histórico (não mais só um atalho para o WhatsApp).
2. **Moderação e governança:** aprovar antes de publicar; rastrear quem fez o
   quê (Message Hub).
3. **Pertencimento real:** diretório de membros e aniversariantes com
   consentimento LGPD.
4. **Vida espiritual aprofundada:** Bíblia híbrida (online + offline), planos,
   devocionais e oração conectados.
5. **Administração:** painel para liderança (escalas, conteúdo, gabinete,
   contribuições, métricas).
6. **Conformidade:** LGPD como pré-requisito inegociável de tudo que trata dado
   pessoal.
7. **Qualidade contínua:** manter `analyze` limpo, testes verdes e homologação
   por defeito.

## 3. Arquitetura geral

```
                         ┌──────────────────────────────┐
                         │        APP (Flutter)         │
                         │  membros · leitura · jornadas │
                         └───────────────┬──────────────┘
                                         │ HTTPS (auth + RLS)
                         ┌───────────────▼──────────────┐
                         │           SUPABASE            │
                         │ Auth · Postgres(RLS) · Edge   │
                         │ Functions · Storage · Realtime│
                         └───────┬───────────────┬───────┘
                                 │               │
             ┌───────────────────▼───┐     ┌─────▼────────────────────┐
             │ PAINEL ADMIN (web)    │     │ INTEGRAÇÕES               │
             │ moderação · gestão    │     │ WhatsApp Business (futuro)│
             │ escalas · conteúdo    │     │ Maps · YouTube · Storage  │
             └───────────────────────┘     └──────────────────────────┘
```

**Princípios de arquitetura (mantidos da 1.x):**
- **Framework independence:** regra de negócio no pacote `goel_domain` (Dart
  puro); Flutter é só entrega.
- **Offline-first** onde fizer sentido (Bíblia continua funcionando sem rede).
- **Camadas:** Presentation → Domain (contratos) → Data (Supabase/asset).
- **Segurança por padrão:** RLS em todas as tabelas; escrita sensível por Edge
  Functions autenticadas; PII só a papéis autorizados; auditoria imutável.
- **Sem Firebase** (decisão do Owner). Crash/analytics: decisão à parte.

## 4. Roadmap (por pilares)

| Onda | Foco | Pilares |
|---|---|---|
| **Onda 0** | Fundações (Auth papéis, RLS, painel base, LGPD operacional) | transversal |
| **Onda 1** | **Comunidade** (Message Hub) | Pilar 1 |
| **Onda 2** | **Membros** (diretório, aniversariantes, perfil) | Pilar 2 |
| **Onda 3** | **Vida Espiritual** (Bíblia híbrida, planos, devocionais) | Pilar 3 |
| **Onda 4** | **Administração** (escalas backend, conteúdo, gabinete, métricas) | Pilar 4 |
| **Onda 5** | **Inteligência** (Dashboard Pastoral + indicadores) | Pilar 5 |
| **Onda 6** | **Integração WhatsApp Business** (avaliação/piloto) | Pilar 1 (fase 3) |

> Gate entre ondas: LGPD cumprido para o que trata dado pessoal + homologação
> verde (0 defeitos críticos).

## 5. Cronograma (estimativa)

Base: **sprints de 2 semanas**. Início-alvo: **após publicação e estabilização
da 1.1.0**. Datas indicativas (2026) — recalibrar com a equipe.

| Período (estim.) | Sprints | Entrega |
|---|---|---|
| Set/2026 | S0.1–S0.2 | Fundações: papéis, RLS, painel base, política LGPD |
| Out/2026 | S1.1–S1.2 | Pilar 1 — Message Hub (captura + moderação + publicação manual) |
| Nov/2026 | S2.1–S2.2 | Pilar 2 — Membros + Aniversariantes (com consentimento) |
| Dez/2026 | S3.1–S3.2 | Pilar 3 — Bíblia híbrida + planos/devocionais |
| Jan/2027 | S4.1–S4.2 | Pilar 4 — Administração (escalas backend, conteúdo, métricas) |
| Fev/2027 | S5.1 | Integração WhatsApp Business (piloto, se elegível) |

## 6. Sprints (visão macro)

Cada sprint: **planejar → construir → `flutter analyze` + `flutter test` →
homologar → fechar**. Regras da fase de QA continuam valendo (defeito com DEF,
correção mínima). Detalhe por pilar na Seção "Pilares".

## 7. Dependências

- **Supabase** provisionado (Auth, Postgres, Edge Functions, Storage, Realtime).
- **Painel Administrativo web** (stack a definir; pode ser web app separado).
- **Aprovação LGPD** (`docs/rc1/EU-09-lgpd-aprovacao.md`) — **pré-requisito** de
  todo pilar que trata dado pessoal (1, 2 e partes do 4).
- **Política de Privacidade** publicada + **Data Safety** no Google Play.
- **Official Business Account (OBA)** + Cloud API — só para a fase de WhatsApp
  Business (Pilar 1, fase 3).
- **Definição de crash/analytics** (sem Firebase) — decisão do Owner.
- Estabilização da **1.1.0** em produção antes de iniciar as ondas.

## 8. LGPD

> Pré-requisito **obrigatório** (base: `EU-09-lgpd-aprovacao.md`).

- Consentimento **específico por finalidade** (publicar testemunho/pedido;
  aparecer no diretório; aparecer em aniversariantes).
- Minimização, retenção, **revogação** fácil, e **auditoria** de acesso/
  publicação.
- RLS + Edge Functions; PII restrita a papéis; canal do encarregado (DPO).
- Nenhuma listagem de dados pessoais entra em produção sem LGPD cumprida.

## 9. Integrações

| Integração | Uso | Estado |
|---|---|---|
| **Supabase** | Dados/auth/storage/realtime | Base da 2.0 |
| **WhatsApp Business (Cloud/Groups API)** | Publicação assistida/automática | Fase futura (OBA + custo) |
| **Google Maps** | "Como chegar" (já na 1.1.0) | Manter |
| **YouTube (@Goel_Church)** | Conteúdo/pregações | Manter/expandir |
| **Google Drive** | Materiais (PALAVRAS) | Manter |
| **Crash/Analytics** (ex.: Sentry) | Estabilidade | A decidir (sem Firebase) |

## 10. Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| LGPD mal endereçada em dados pessoais | Alto (legal) | LGPD como gate; DPO; consentimento e auditoria |
| Escopo inflar (scope creep) | Alto | Pilares + backlog fechado por sprint; congelar 1.1.0 |
| WhatsApp Business (OBA/custo/elegibilidade) | Médio | Tratar como fase isolada; fallback manual |
| Exposição de PII (telefones) | Alto | RLS + papéis + acesso auditado |
| Complexidade do painel admin | Médio | MVP primeiro (fila + aprovar); iterar |
| Dependência de backend online | Médio | Offline-first onde possível; degradação graciosa |
| Custo/manutenção Supabase | Médio | Monitorar uso; otimizar consultas/Storage |

## 11. Critérios de aceite (globais da 2.0)

- Todo dado pessoal com **consentimento + RLS + auditoria**.
- `flutter analyze` limpo e `flutter test` verde em cada entrega.
- **0 defeitos críticos** para promover qualquer onda a produção.
- Cada pilar cumpre seus critérios de aceite específicos (abaixo).
- Sem Firebase; identidade visual e acessibilidade preservadas.
- Documentação atualizada por sprint (fluxos, modelo de dados, permissões).

## 12. Estratégia de homologação

Mesmo rito da 1.1.0, por **onda/pilar**:
```
Internal Testing → (Críticos=0 e Altos=0) → Closed Testing → Produção
```
- Todo defeito no `DEFECT_LOG.md` (IDs por módulo, severidade/prioridade).
- Homologação em dispositivos reais; janelas definidas por onda.
- Gate LGPD antes de qualquer feature com dado pessoal.
- Autorização explícita do Owner para promover à produção.

---

# PILARES DA VERSÃO 2.0

## PILAR 1 — Comunidade (Message Hub)

- **Objetivo:** receber, **moderar**, aprovar e publicar mensagens dos membros
  (Testemunhos, Oração, Servo) com histórico e auditoria; preparar integração
  com WhatsApp Business. (Detalhe: `docs/v2/goel-message-hub.md`.)
- **Escopo:** captura no app → Supabase; painel de moderação; publicação manual
  no grupo (fase 1) → assistida/automática (fase 3). **Fora:** auto-post em
  grupo de convite existente (limitação oficial do WhatsApp — ver
  `docs/rc1/auditoria-whatsapp.md`).
- **Arquitetura:** App → Supabase (`submissions`, `moderation_actions`,
  `publications`, `staff_roles`, RLS + Edge Functions) → Painel Admin → Equipe →
  WhatsApp.
- **Backlog:** (a) enviar submissão ao Supabase; (b) fila no painel; (c)
  aprovar/rejeitar/editar; (d) auditoria imutável; (e) publicação manual; (f)
  anonimização; (g) notificações à equipe.
- **Sprints:** S1.1 (captura + fila + status) · S1.2 (moderação + auditoria +
  publicação manual).
- **Critérios de aceite:** submissão persistida com consentimento; moderador
  aprova/rejeita com registro; publicação gera `publications`; PII só a papéis;
  LGPD cumprida.

## PILAR 2 — Membros

- **Objetivo:** transformar cadastro em **pertencimento real** — diretório de
  membros e aniversariantes com consentimento (resolve EU-04/EU-07).
- **Escopo:** endpoint de **leitura** de perfis; diretório (nome/contato) restrito
  por papel; aniversariantes do mês (nome + dia); perfil editável do membro.
  **Fora:** exibir telefone a todos.
- **Arquitetura:** Supabase (tabela `profiles` + RLS; Edge Function
  `list-members`/`list-birthdays`); app injeta dados reais nas telas existentes
  (que já aceitam parâmetro) — sem redesenho.
- **Backlog:** (a) endpoint de leitura seguro; (b) consentimento por finalidade;
  (c) diretório com busca; (d) aniversariantes do mês; (e) perfil (editar/
  revogar); (f) exportação restrita a admin com auditoria.
- **Sprints:** S2.1 (perfis + consentimento + aniversariantes) · S2.2 (diretório
  + permissões + exportação auditada).
- **Critérios de aceite:** nenhum PII sem consentimento; RLS por papel;
  aniversariantes só nome + dia; revogação funcional; auditoria de acesso.

## PILAR 3 — Vida Espiritual

- **Objetivo:** aprofundar a jornada espiritual — **Bíblia híbrida**, planos,
  devocionais e oração conectados.
- **Escopo:** Bíblia **online quando houver conexão, offline (Almeida 1911) como
  fallback** (arquitetura aprovada em `EU-08`); progresso de planos na nuvem
  (sincroniza entre dispositivos); devocionais temáticos; oração vinculada ao
  Hub. **Fora:** traduções sem licença clara.
- **Arquitetura:** `HybridBibleRepository` (decorator) sobre
  `AssetBibleRepository` (offline) + `OnlineBibleSource`; contrato
  `BibleRepository` **inalterado**; progresso em Supabase.
- **Backlog:** (a) decorator híbrido + política de fallback/timeout; (b) cache
  online; (c) seleção de versão (com licença); (d) sync de planos/favoritos;
  (e) devocionais; (f) oração integrada ao Hub.
- **Sprints:** S3.1 (Bíblia híbrida + fallback + cache) · S3.2 (sync de planos/
  favoritos + devocionais).
- **Critérios de aceite:** offline nunca quebra; online degrada com timeout;
  referências consistentes (mesmo manifesto); só versões licenciadas; sync sem
  perda de dados.

## PILAR 4 — Administração

- **Objetivo:** dar à liderança um **painel de gestão** — escalas, conteúdo,
  gabinete, contribuições e métricas.
- **Escopo:** escalas com **backend** (equipe real, persistida); gestão de
  conteúdo (pregações/PALAVRAS/eventos); gabinete pastoral; contribuições/Pix;
  métricas de uso. **Fora:** dados financeiros sensíveis sem controle/auditoria.
- **Arquitetura:** Painel Admin (web) sobre Supabase; RLS por papel
  (`ADMIN`/`MODERADOR`/`INTEGRACAO`); Storage para mídia; Realtime para filas.
- **Backlog:** (a) escalas persistidas (evolui a edição da 1.1.0 para backend);
  (b) CRUD de conteúdo; (c) gabinete/atendimento; (d) contribuições; (e)
  dashboard de métricas; (f) gestão de papéis.
- **Sprints:** S4.1 (escalas backend + papéis) · S4.2 (conteúdo + métricas +
  contribuições).
- **Critérios de aceite:** ações administrativas auditadas; acesso por papel;
  escalas persistem e sincronizam; conteúdo publicável com histórico.

## PILAR 5 — Inteligência

- **Objetivo:** fornecer **indicadores para liderança e pastoreio** — um
  **Dashboard Pastoral** que transforma os dados dos demais pilares em visão
  para cuidar de pessoas e decidir com clareza.
- **Escopo inicial:**
  - **Dashboard Pastoral** (visão consolidada para a liderança).
  - **Indicadores de participação** (acessos, presença, engajamento).
  - **Indicadores de leitura bíblica** (capítulos/planos lidos, constância).
  - **Indicadores de oração** (pedidos recebidos/atendidos, tempo de resposta).
  - **Indicadores de testemunhos** (recebidos/publicados/moderação).
  - **Indicadores de pequenos grupos** (participação, frequência, crescimento).
  - **Indicadores de escalas** (cobertura, equilíbrio do rodízio, faltas).
  - **Arquitetura preparada para expansão futura** (novos indicadores sem
    redesenho).
- **Arquitetura:** camada **analítica derivada** sobre o Supabase — *views*/
  *materialized views* e/ou tabelas de agregação alimentadas por Edge Functions/
  jobs; leitura pelo Painel Admin. **Somente dados agregados/indicadores**, com
  **RLS por papel**; **privacidade por design** (preferir métricas agregadas e
  anonimizadas; nada de expor conteúdo pessoal individual sem base legal).
  Modelo **extensível**: cada indicador é uma definição isolada (fácil somar
  novos) — pronto para BI externo no futuro, se decidido.
- **Backlog:** (a) definição de métricas e fórmulas; (b) camada de agregação
  (views/jobs); (c) Dashboard Pastoral (cards + séries temporais); (d)
  indicadores por domínio (participação, Bíblia, oração, testemunhos, pequenos
  grupos, escalas); (e) filtros por período/ministério; (f) exportação
  restrita/auditada; (g) framework para novos indicadores.
- **Sprints:** S5.1 (camada de agregação + Dashboard base + 2–3 indicadores
  âncora) · S5.2 (demais indicadores + filtros + exportação).
- **Critérios de aceite:** indicadores corretos e reproduzíveis; **apenas
  agregados** (sem expor PII indevidamente); acesso restrito por papel e
  auditado; LGPD respeitada (finalidade: pastoreio/gestão); arquitetura permite
  **adicionar novo indicador sem redesenho**.

> **Dependência:** o Pilar 5 consome dados gerados pelos Pilares 1–4; por isso
> entra **após** eles (Onda 5), quando já há dados suficientes para indicadores
> significativos.

---

### Registro
```
GOEL CHURCH
DOCUMENTO  Master Plan 2.0
STATUS     APROVADO (Owner, 2026-08-04) — fase de planejamento encerrada
ESTADO     Planejamento diretor — sem implementação
PILARES    1 Comunidade · 2 Membros · 3 Vida Espiritual · 4 Administração ·
           5 Inteligência
GATES      LGPD (pré-requisito) · Homologação (0 críticos) · Autorização Owner
PRÓXIMO    Homologação 1.1.0 → Internal Testing → Correções → Abertura da 2.0
1.1.0      CONGELADA
```
