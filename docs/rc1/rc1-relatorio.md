# GOEL CHURCH — Relatório RC1 (Release Candidate 1)

> Ajustes anteriores à publicação iOS. **Nenhuma Release gerada** — aguardando
> aprovação do Owner. `flutter analyze` limpo · `flutter test` **verde (79
> testes)**.

## Resumo por item

| Item | Escopo | Status |
|---|---|---|
| **EU-01 Oração** | Novo fluxo: Nome → WhatsApp → Pedido → mensagem pronta → abre WhatsApp | ✅ Implementado |
| **EU-02 Testemunho** | Nome → WhatsApp → Título → Testemunho → mensagem pronta | ✅ Implementado |
| **EU-03 Quero ser Servo** | Área escolhida vira mensagem ("Quero servir na equipe de Mídia.") | ✅ Implementado |
| **EU-04 Membros** | Auditoria (onde carrega / por que não aparece) + plano | 🔎 Auditado — correção travada por LGPD/backend |
| **EU-05 Escalas** | Lista editável: adicionar / editar / remover / reordenar | ✅ Implementado |
| **EU-06 Home** | Frase institucional abaixo do logo, acima do "Bem-vindo" | ✅ Implementado |
| **EU-07 Aniversariantes** | Auditoria do fluxo login→cadastro→nascimento→persistência→tela | 🔎 Auditado — persistência OK; leitura travada por LGPD/backend |
| **EU-08 Bíblia híbrida** | Arquitetura (online + offline fallback) — **sem implementar** | 📄 Documento entregue |
| **EU-09 LGPD** | Documento de aprovação (base legal, consentimento, etc.) | 📄 Documento entregue |

Documentos: `docs/rc1/EU-04-…`, `EU-07-…`, `EU-08-…`, `EU-09-…`.

---

## EU-01 / EU-02 / EU-03 — WhatsApp com mensagem PRONTA

### Limitação oficial (não afirmamos suporte inexistente)

O WhatsApp **não permite postar/enviar automaticamente em um GRUPO por link**.
Links de convite (`chat.whatsapp.com/...`) apenas **entram** no grupo; o esquema
`wa.me` só **pré-preenche** texto para uma **conversa**.

### Alternativa oficial mais próxima (implementada)

Ao enviar, o app **monta a mensagem automaticamente** com os dados do formulário
e abre o WhatsApp com o texto **já pronto** (`https://wa.me/?text=...`). O
usuário então **escolhe o destino** (o grupo oficial ou um contato) e toca em
enviar. É o mais próximo e honesto de "mandar para o grupo".

Helper central: `abrirWhatsAppComMensagem()` em
`lib/core/whatsapp/whatsapp_links.dart` (com `numero` opcional → conversa
direta pré-preenchida, quando fizer sentido).

**Mensagens montadas:**

- **Oração:** `*Pedido de Oração — Goel Church*` + Nome + WhatsApp + pedido.
- **Testemunho:** `*Testemunho — Goel Church*` + Nome + WhatsApp + Título + texto.
- **Servo:** `*Quero Ser Servo — Goel Church*` + Nome + Contato +
  "Quero servir na equipe de **{área}**." (plural quando há várias áreas).

Cada tela mantém também o botão **"Entrar no Grupo"** oficial.

---

## EU-05 — Escalas editáveis

Na tela de cada ministério, a **Equipe** agora é editável:

- **Adicionar** (diálogo com nome), **Editar**, **Remover**.
- **Reordenar** por **subir/descer** (acessível para todas as idades).
- O **rodízio** automático regenera **ao vivo** a cada mudança; "Por escala"
  ajusta-se ao novo tamanho da equipe; estado vazio orienta a adicionar.

Arquitetura preservada: a equipe vira cópia mutável local; quando existir o
slice de dados, a fonte real substitui a inicial **sem mudar a UI**.

---

## EU-06 — Home

Abaixo do logotipo e **acima** da saudação ("Bem-vindo…"):

> **"Uma igreja para você frequentar e uma família para você pertencer."**

---

## EU-04 / EU-07 — por que a correção não entrou na RC1

Ambas têm a **mesma causa raiz**: os perfis são **gravados** (cadastro →
`save-profile`), mas **não há caminho de leitura** — nenhum endpoint/gateway
lista os perfis de volta, e as telas são construídas sem dados (caem em
exemplos fixos).

A correção real exige (a) **endpoint de leitura no backend** (Supabase) e
(b) exposição de **dados pessoais** — que é justamente o que **EU-09 (LGPD)**
manda aprovar **antes**. Por isso, entregamos **auditoria + plano** e deixamos
a implementação condicionada à aprovação LGPD e ao endpoint. Detalhes em
`EU-04-…` e `EU-07-…`.

---

## Qualidade

- `flutter analyze` → **No issues found**.
- `flutter test` → **79 testes verdes** (novos: Servo ×2, Escalas editável ×1;
  Oração/Testemunho atualizados para validar a mensagem no `wa.me`).
- Sem alterações em domínio/arquitetura/Firebase/Supabase/auth.

## Checklist de homologação (RC1)

- [ ] **Oração**: preencher nome + pedido → "Enviar Pedido" abre o WhatsApp com
      a mensagem pronta (Nome + pedido); "Entrar no Grupo" abre o grupo.
- [ ] **Testemunho**: nome + título + texto → abre WhatsApp com mensagem pronta.
- [ ] **Servo**: escolher "Mídia" → mensagem "Quero servir na equipe de Mídia.";
      escolher 2+ áreas → frase no plural.
- [ ] **Escalas**: abrir um ministério → adicionar, editar, remover e
      subir/descer membros; o rodízio atualiza sozinho.
- [ ] **Home**: a frase institucional aparece acima do "Bem-vindo".
- [ ] **Membros / Aniversariantes**: revisar auditoria e decidir sobre EU-09.
- [ ] **EU-08 / EU-09**: revisar e aprovar os documentos.

> **Sem gerar nova Release** até sua aprovação.
