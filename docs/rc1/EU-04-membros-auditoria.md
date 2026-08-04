# EU-04 — Auditoria: Membros

## Perguntas do Owner

### 1) Onde os membros logados são carregados?

**Em lugar nenhum de real.** Hoje a tela é montada assim:

- `lib/features/home/presentation/main_shell.dart` → `MembrosScreen()` é
  construída **sem parâmetros** (`const MembrosScreen()`).
- `lib/features/membros/presentation/membros_screen.dart` → quando `membros`
  é nulo, a tela usa a lista interna `_exemplo` (8 nomes fictícios:
  "Ana Maria Souza", "Bruno Lima"…).

Ou seja: os nomes exibidos são **placeholders fixos (hardcoded)**, não membros
reais.

### 2) Por que não aparecem?

Porque **não existe caminho de leitura (read) dos perfis**:

- O único gateway de perfil é `SupabaseProfileGateway`
  (`lib/features/member/data/supabase_profile_gateway.dart`) e ele só tem
  `save()` — grava o perfil via Edge Function `save-profile`.
- **Não há** método para LISTAR/consultar perfis (nenhuma Edge Function
  `list-*`, nenhum `select` no cliente). Portanto o app **escreve** o perfil no
  cadastro, mas **nunca lê** de volta.
- Como a `MembrosScreen` não recebe dados e não há de onde buscá-los, ela cai
  no `_exemplo`.

## Causa raiz

> Falta a camada de LEITURA de perfis. O dado é persistido, mas não há endpoint
> nem gateway para consultá-lo, e a tela não está ligada a nenhuma fonte real.

## Correção proposta (plano)

1. **Backend:** criar endpoint de leitura — Edge Function `list-members`
   (ou tabela `profiles` com RLS + `select` protegido) devolvendo apenas os
   campos autorizados.
2. **Domínio/Dados:** adicionar contrato `MemberDirectoryGateway.list()` no
   pacote `goel_domain` e a implementação Supabase correspondente.
3. **Composição:** ligar `main_shell` via `FutureBuilder` e injetar a lista
   real em `MembrosScreen(membros: ...)` — a tela **não muda** (já aceita o
   parâmetro).

## ⚠️ Bloqueio (dependência de EU-09 / LGPD)

Um diretório de membros expõe **dados pessoais** (nome + telefone de todos).
Isso é exatamente o escopo que **EU-09** exige aprovar via LGPD **antes** de
implementar. Além disso, o endpoint de leitura é trabalho de **backend**
(Supabase), fora do repositório do app.

**Decisão honesta para a RC1:** entregamos a auditoria + o plano. A
implementação do diretório real fica condicionada:

- à **aprovação do documento LGPD (EU-09)**, e
- à criação do **endpoint de leitura** no Supabase.

### Recomendação interina (aguardando sua decisão)

A tela hoje mostra nomes fictícios que **parecem reais**. Recomendamos (após
seu aval) trocar por um **estado honesto** ("A lista de membros aparecerá aqui
quando a base for conectada") para não induzir os testadores. Não alteramos
isso na RC1 para não surpreender — aguardamos sua confirmação.
