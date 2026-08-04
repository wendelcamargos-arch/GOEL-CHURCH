# GOEL CHURCH — TEST PLAN 1.1.0 (Internal Testing)

> **Roteiro oficial de homologação em dispositivo real.** Fase **QUALITY
> ASSURANCE** · versão **1.1.0 (code 10)** · escopo **congelado**. Documentação
> operacional — **nenhuma implementação/alteração de código**.
>
> Defeito encontrado → registrar no `DEFECT_LOG.md` (registro) e mover o card no
> `RELEASE_BOARD.md` (fluxo). IDs por módulo: `DEF-B/H/L/C/R/G/S…`.

## Como usar

Para **cada item**, marque:
- ☐ **Funciona** — passou como esperado.
- **Observações:** ____________________ (o que notou)
- ☐ **Defeito encontrado** — não passou.
- **ID do defeito:** `DEF-___` (abrir no DEFECT_LOG/RELEASE_BOARD)

### Dados do teste (preencher 1x por rodada)
- **Testador:** __________  **Data:** __________
- **Dispositivo:** __________ (ex.: Samsung A15)
- **Sistema:** __________ (ex.: Android 16)
- **Origem:** Internal Testing (Google Play)  **Rede:** ☐ Wi-Fi ☐ Dados móveis ☐ Offline

---

## 1. Splash

**S-01 — Abertura a frio (cold start)**
App abre do zero: splash preto com logo → entra sem tela branca/congelamento.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**S-02 — Reabertura (warm start)**
Fechar e reabrir o app: entra rápido, sem travar.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 2. Login

**L-01 — Entrar com credencial válida** → acessa o app.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**L-02 — Sessão persiste** após fechar/reabrir (não pede login de novo).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**L-03 — Credencial inválida** → mensagem de erro clara, sem travar.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 3. Cadastro

**C-01 — Completar perfil** (nome + data de nascimento válida) salva com sucesso.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**C-02 — Validação** de campos obrigatórios (nome/nascimento) bloqueia envio vazio.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**C-03 — Saudação** na Home usa o nome cadastrado após salvar.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 4. Home

**H-01 — Frase institucional** ("Uma igreja para você frequentar e uma família
para você pertencer.") aparece acima da saudação.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**H-02 — Cards** (Versículo do dia, Testemunho, Oração, Servo) abrem ao tocar.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**H-03 — Cabeçalho de marca** (logo/fachada) exibe sem quebra/erro de imagem.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 5. Versículo do Dia

**V-01 — Exibe um versículo** do dia com referência.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**V-02 — Ação de leitura/compartilhar** (se disponível) funciona.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 6. Bible Engine

**B-01 — Lista 66 livros** (Antigo e Novo Testamento).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-02 — Capítulo longo íntegro** (Salmos 119 = **176 versículos**; sem o antigo
defeito de "5 versículos").
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-03 — Rolagem contínua** carrega o próximo capítulo/livro ao chegar ao fim.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-04 — Fonte +/−** e **tema claro/escuro** aplicam na leitura.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-05 — Modo Púlpito** entra (sem AppBar, fonte ampliada) e sai.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-06 — Modo Culto** mantém a tela ligada durante a leitura; desativa ao sair.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-07 — Sobre a Bíblia** mostra a atribuição (Almeida 1911, domínio público).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**B-08 — Continue lendo** retoma a última leitura no ponto certo; histórico
registra.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 7. Favoritos

**F-01 — Favoritar/desfavoritar** um versículo persiste (fecha e reabre).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**F-02 — "Meus favoritos"** lista os versículos marcados; abrir leva ao trecho.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 8. Busca

**BU-01 — Por referência** (ex.: "Jo 3:16") resolve e abre o versículo.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**BU-02 — Por palavra** (ex.: "amor") retorna resultados sem travar a tela.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 9. Planos

**P-01 — Lista de planos** (anual, 90 dias, 30 dias NT, Goel Church 21 dias).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**P-02 — Marcar dia lido** persiste; progresso do plano atualiza.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 10. Compartilhar

**CS-01 — Compartilhar versículo** (texto e/ou imagem) abre a folha de
compartilhamento do sistema.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 11. Comunidade

**CM-01 — Navegação** entre os módulos de comunidade (cards da Home / aba Mais)
abre as telas corretas.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 12. Testemunhos

**T-01 — Enviar testemunho** (nome + título + texto) → abre o WhatsApp com a
**mensagem pronta**.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**T-02 — Entrar no Grupo** (Testemunhos Goel) abre o grupo oficial.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 13. Pedidos de Oração

**O-01 — Enviar pedido** (nome + pedido) → abre o WhatsApp com a mensagem pronta.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**O-02 — Entrar no Grupo** (Pedido de Oração) abre o grupo oficial.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 14. Quero Ser Servo

**QS-01 — Uma área** (ex.: Mídia) → mensagem "Quero servir na equipe de Mídia.".
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**QS-02 — Várias áreas** → frase no plural ("...nas equipes de X e Y.").
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 15. Goel Home

**GH-01 — Abre** e apresenta o conteúdo; ação "participar" (WhatsApp), se houver,
funciona.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 16. Gabinete Pastoral

**G-01 — Abre** e lista os contatos (Pastor Linniker / Pastora Wanessa).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**G-02 — Contato** abre a conversa no WhatsApp com o pastor(a).
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 17. Redes Sociais

**R-01 — Instagram** (@goelchurch_) abre.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**R-02 — YouTube** (@Goel_Church) abre.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**R-03 — Grupo de Boas-vindas** (WhatsApp) abre.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 18. Google Maps

**M-01 — "Como chegar"** abre a localização oficial da igreja no Google Maps.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 19. Escalas

**E-01 — Abrir ministério** e ver a escala/rodízio.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**E-02 — Equipe editável:** adicionar, editar, remover e reordenar (subir/descer)
membros; o rodízio atualiza ao vivo.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**E-03 — Compartilhar/Copiar** a escala funciona.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

## 20. Configurações (aba "Mais")

**CF-01 — Índice de recursos** na aba "Mais" abre as telas corretas.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

**CF-02 — Sair (Logout)** limpa a sessão e volta à raiz/login.
☐ Funciona · Observações: ______ · ☐ Defeito · ID: `DEF-___`

---

## Resumo da rodada (preencher ao final)

| Métrica | Valor |
|---|---|
| Itens testados | ___ / (total) |
| ☐ Funciona | ___ |
| ☐ Defeito encontrado | ___ |
| Defeitos CRÍTICOS | ___ |
| Defeitos ALTOS | ___ |

**Critério para encerrar o Internal Testing:** **CRÍTICOS = 0 e ALTOS = 0**
(ver `RELEASE_PLAN_1.1.0.md`). Defeitos abertos ficam no `DEFECT_LOG.md` /
`RELEASE_BOARD.md`.

### Registro
```
GOEL CHURCH
DOCUMENTO  Test Plan 1.1.0 (Internal Testing)
VERSÃO     1.1.0 (code 10)
STATUS     QUALITY ASSURANCE
USO        Roteiro oficial de homologação em dispositivo real
```
