# GOEL CHURCH — GO LIVE CHECKLIST

> Checklist **definitivo** antes da Produção. Documento oficial da **fase de
> homologação** da Release **1.1.0 (Version Code 12)** — `STATUS: PUBLICADO em
> Internal Testing`.
>
> **Regra da fase:** nenhuma implementação nova, nenhuma Sprint nova. Todo
> trabalho segue o ciclo **Teste → Correção → Nova homologação → Produção**.
>
> Legendas: `[ ]` a validar · ✅ pronto/implementado · ⚠️ pendência/decisão ·
> ⛔ fora desta versão.

---

## 1. Google Play — trilhas de lançamento

### 1.1 Internal Testing (atual)
- [x] AAB **code 12** enviado (run #16, SHA-256 `039428…5a1aa`).
- [x] Versão **1.1.0 (12)** aceita no Google Play Console.
- [x] Notas de versão `pt-BR` preenchidas.
- [x] Owner + equipe de testadores na lista; instalação via link do teste.
- [ ] App abre e navega sem tela branca/freeze (regressão do splash resolvida).
- [ ] **Barra inferior**: "Generosidade" em uma linha (sem quebra) — validar.
- [ ] **Bíblia**: "Ir para o versículo" abre a grade e rola até o número — validar.
- [ ] Homologação do Owner + testadores concluída no próprio aparelho.

### 1.2 Closed Testing (após homologação do Owner)
- [ ] Faixa de teste fechado criada.
- [ ] Lista dos **13 e-mails** de testadores adicionada.
- [ ] Feedback coletado e triado (ciclo Teste → Correção → Nova homologação).
- [ ] Zero defeitos bloqueantes em aberto.

### 1.3 Production (somente após aprovação final do Owner)
- [ ] Ficha da loja completa (descrição, screenshots, ícone, gráfico).
- [ ] Classificação indicativa (questionário de conteúdo) respondida.
- [ ] **Política de Privacidade** publicada e URL informada (ver LGPD).
- [ ] Seção **Segurança dos Dados** (Data Safety) preenchida.
- [ ] País/preço (gratuito) e distribuição definidos.
- [ ] Lançamento em produção **autorizado explicitamente pelo Owner**.

> **Nenhuma publicação em Produção** antes da homologação final do Owner.

---

## 2. Bible Engine (offline — Almeida 1911)
- [ ] Abre e lista **66 livros** (AT/NT).
- [ ] Capítulo longo íntegro (ex.: **Salmos 119 = 176 versículos** — sem o
      antigo defeito de "5 versículos").
- [ ] Rolagem contínua carrega o próximo capítulo/livro.
- [ ] Fonte +/−, tema claro/escuro.
- [ ] **"Ir para o versículo"** (ícone de grade): abre os quadradinhos e, ao
      tocar um número (ex.: 30), rola a leitura direto até ele.
- [ ] "Sobre a Bíblia" com atribuição (Almeida 1911, domínio público / JFAAL).

## 3. Login
- [ ] Login conclui e mantém a sessão (token válido).
- [ ] Sessão expirada tratada com mensagem clara.
- [ ] Logout limpa o estado e volta à raiz.

## 4. Cadastro
- [ ] Completar perfil: nome + **data de nascimento** válida.
- [ ] Persistência via `save-profile` (birth_date gravado).
- [ ] Nome retorna na saudação da Home.
- [ ] Validação de campos obrigatórios.

## 5. Home
- [ ] Frase institucional: **"Uma igreja para você frequentar e uma família
      para você pertencer."** acima da saudação.
- [ ] Cards: Versículo do dia, Testemunho, Oração, Servo.
- [ ] Cabeçalho de marca (logo/fachada) sem quebra.
- [ ] **Barra inferior**: rótulo "Generosidade" em **uma única linha**.

## 6. Oração
- [ ] Fluxo Nome → WhatsApp → Pedido monta a mensagem.
- [ ] "Enviar Pedido" abre o WhatsApp com a mensagem **pronta**.
- [ ] "Entrar no Grupo" abre o grupo oficial.
- [ ] Limitação oficial do WhatsApp comunicada com honestidade.

## 7. Testemunho
- [ ] Nome → WhatsApp → Título → Testemunho monta a mensagem.
- [ ] Abre o WhatsApp com o texto pronto; "Entrar no Grupo" funciona.

## 8. Servo
- [ ] Área escolhida vira "Quero servir na equipe de X." (plural p/ várias).
- [ ] Abre o WhatsApp com a mensagem pronta.

## 9. Escalas
- [ ] Equipe **editável**: adicionar / editar / remover / reordenar.
- [ ] Rodízio automático regenera ao vivo; "Por escala" ajusta ao tamanho.
- [ ] Compartilhar/Copiar a escala funciona.

## 10. Redes Sociais
- [ ] Instagram, YouTube (@Goel_Church), Grupo WhatsApp abrem corretamente.

## 11. Como Chegar
- [ ] Abre a localização oficial no Google Maps (`maps.app.goo.gl/…`).

## 12. Bible Search
- [ ] Busca por **referência** (ex.: "Jo 3:16") resolve.
- [ ] Busca por **palavra** retorna resultados via stream sem travar a UI.

## 13. Favoritos
- [ ] Favoritar/desfavoritar versículo persiste.
- [ ] Lista "Meus favoritos" reflete o estado.

## 14. Continue Lendo
- [ ] Última leitura salva e "Continue lendo" retoma no ponto certo.
- [ ] Histórico registra as leituras (sem duplicar).

## 15. Planos
- [ ] Planos listados (anual, 90 dias, 30 dias NT, Goel Church 21 dias).
- [ ] Marcar dia lido persiste; progresso atualiza.

## 16. Modo Púlpito
- [ ] Ativa (sem AppBar, fonte ampliada) e sai corretamente.

## 17. Modo Culto
- [ ] Mantém a tela ligada (wakelock) durante a leitura; desativa ao sair.

## 18. LGPD
- [ ] Documento `docs/rc1/EU-09-lgpd-aprovacao.md` **APROVADO** (pré-requisito).
- ⛔ Membros e Aniversariantes com **dados reais**: fora desta versão até
     cumprir LGPD (base legal, consentimento, retenção, revogação, auditoria) +
     backend/endpoint/política de acesso.
- [ ] **Política de Privacidade** publicada (obrigatória p/ Produção).
- [ ] **Data Safety** do Play coerente com os dados coletados (nome, nascimento,
      WhatsApp opt-in).

## 19. Crash Monitoring
- ⚠️ **Não configurado** nesta versão (decisão: sem Firebase). Antes da
     Produção, **decidir** a ferramenta de crash/erros (ex.: Sentry ou
     Crashlytics) — item de decisão do Owner, **não** implementar sem aprovação.
- [ ] Definição registrada (ativar agora ou pós‑1.1.0).

## 20. Performance
- [ ] Abertura a frio sem freeze/tela branca (regressão do splash resolvida).
- [ ] Rolagem da Bíblia fluida (cache LRU); busca não trava a UI.
- [ ] Tamanho do app aceitável (AAB ~53 MB).
- [ ] Sem vazamentos evidentes em uso prolongado (Modo Culto).

## 21. Acessibilidade
- [ ] Tipografia ampliada e contraste alto (tema preto e branco).
- [ ] Alvos de toque amplos; `Semantics`/labels nos botões e cards.
- [ ] Leitura confortável para todas as idades.

---

## 22. Checklist final (portão de Produção)
- [ ] Todos os itens acima validados na trilha de teste.
- [ ] Zero defeitos bloqueantes em aberto.
- [ ] LGPD: Política de Privacidade + Data Safety prontos.
- [ ] Crash monitoring: decisão registrada.
- [x] `flutter analyze` limpo · `flutter test` verde (**84 testes**) na Release.
- [x] AAB certificado (code 12, SHA-256 conferido).
- [ ] **Homologação final do Owner + testadores concluída.**
- [ ] **Autorização explícita do Owner para publicar em Produção.**

---

### Registro da Release
```
GOEL CHURCH
VERSION       1.1.0
VERSION CODE  12
STATUS        PUBLICADO em Internal Testing
FASE          HOMOLOGAÇÃO (Teste → Correção → Nova homologação → Produção)
```
