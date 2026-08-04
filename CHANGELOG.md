# GOEL CHURCH — CHANGELOG

Registro permanente da evolução do produto. Segue ordem cronológica inversa
(mais recente no topo). Versionamento: `MAJOR.MINOR.PATCH (+versionCode)`.

---

## 1.1.0 (code 10)
**Data:** 2026-08-04 · **Status:** RELEASE CERTIFIED · Internal Testing

### Funcionalidades
- 📖 **Bible Engine offline** (Almeida 1911, domínio público): 66 livros /
  1.189 capítulos / 31.102 versículos. Leitura com rolagem contínua, fonte
  +/−, tema claro/escuro, **Modo Púlpito** e **Modo Culto** (tela ligada).
- 🔎 **Busca** por referência (ex.: "Jo 3:16") e por palavra (em background).
- ⭐ **Favoritos**, marca-textos, anotações, **Continue lendo** e histórico.
- 🗓️ **Planos de leitura** (anual, 90 dias, 30 dias NT, Goel Church 21 dias).
- 📤 **Compartilhar** versículo (texto e imagem) com identidade Goel.
- 📝 **PALAVRAS**: 3 publicações abrindo as pastas no Google Drive.
- 🙏 **Comunidade** (Oração, Testemunho, Servo): monta a mensagem e abre o
  WhatsApp com o texto **pronto** (usuário escolhe o destino e envia).
- 🧩 **Servo**: mensagem por área ("Quero servir na equipe de Mídia.").
- 🗂️ **Escalas** com **equipe editável** (adicionar/editar/remover/reordenar);
  rodízio automático ao vivo.
- 🏠 **Home**: frase institucional "Uma igreja para você frequentar e uma
  família para você pertencer.".
- 🔗 **Redes Sociais**: Instagram, **YouTube (@Goel_Church)**, Grupo WhatsApp e
  **Como chegar** (Google Maps).

### Correções
- Eliminado o defeito de leitura que exibia apenas **5 versículos** (agora o
  capítulo completo — ex.: Salmos 119 = 176 versículos).
- **DEF-GP-01**: versionCode ajustado 9 → 10 para aceitar o upload no Google
  Play (o código 9 já havia sido consumido).

### Observações
- Fluxo de comunidade no WhatsApp respeita a **limitação oficial da plataforma**
  (sem auto-post em grupo) — ver `docs/rc1/auditoria-whatsapp.md`.
- Membros/Aniversariantes reais e Bíblia híbrida ficam para a **V2.0**
  (dependem de backend + LGPD). Ver `docs/KNOWN_ISSUES_1.1.0.md`.
- `flutter analyze` limpo · `flutter test` verde (79 testes).

---

## 1.0.3 (baseline)
**Data:** 2026 (release inicial) · **Status:** Publicado (histórico)

### Funcionalidades
- Estrutura inicial do app: Bootstrap, autenticação/sessão (Supabase),
  cadastro de perfil, Home e navegação (abas Início/Mais).
- Módulos de conteúdo e comunidade (versões iniciais), Redes, Contribua/Pix,
  Gabinete Pastoral, Agenda/Eventos, Galeria.
- Identidade visual **preto e branco**, splash nativa e ícones.

### Correções
- Ajustes de publicação no Google Play e **assinatura** (keystore oficial
  `goel`, SHA1 `31:E8:C6`).

### Observações
- Base sobre a qual a 1.1.0 adicionou a Bible Engine e os módulos de
  comunidade/escala.

---

> Convenção: cada nova versão adiciona um bloco no topo com **Versão · Data ·
> Funcionalidades · Correções · Observações**. Detalhes de defeitos ficam no
> `docs/DEFECT_LOG.md`; limitações aceitas no `docs/KNOWN_ISSUES_<versão>.md`.
