# EU-07 — Auditoria: Aniversariantes

> **DECISÃO OFICIAL DO OWNER (RC1): NÃO IMPLEMENTAR.** Mesma dependência de
> EU-04: **Backend** · **Endpoint de leitura** · **Política de acesso**, e
> aprovação definitiva da estratégia LGPD (EU-09).

## Fluxo pedido pelo Owner

```
Login → Cadastro → Data de nascimento → Persistência → Tela de aniversariantes
```

## Verificação etapa por etapa

| Etapa | Situação | Evidência |
|---|---|---|
| **Login** | ✅ OK | `lib/features/auth/…` (sessão + token). |
| **Cadastro** | ✅ OK | `lib/features/member/presentation/cadastro_screen.dart`. |
| **Data de nascimento** | ✅ Coletada | `CadastroFlow.submit(birthDate:)` valida com `ProfileValidation.isComplete(fullName, birthDate, now)`. |
| **Persistência** | ✅ Gravada | `SupabaseProfileGateway.save()` envia `birthDate` (formato `yyyy-MM-dd`) à Edge Function `save-profile`. **birth_date é dado de perfil, nunca de autenticação.** |
| **Tela de aniversariantes** | ❌ **DEFEITO** | `main_shell` constrói `const AniversariantesScreen()` sem dados → a tela cai na lista fixa `_exemplo` (4 nomes fictícios). |

## Causa raiz do defeito

Idêntica à de EU-04: **a escrita funciona, a leitura não existe.**

- A data de nascimento é **coletada e persistida** corretamente no cadastro.
- Mas **não há caminho de leitura** que consulte os perfis, calcule os
  aniversariantes do mês e injete na tela. `AniversariantesScreen` só recebe
  dados por parâmetro; sem injeção, usa `_exemplo`.

> Resumo: o defeito **não** está na coleta/persistência da data (essas estão
> corretas). Está na **ausência da leitura** dos aniversariantes reais.

## Correção proposta (plano)

1. **Backend:** endpoint de leitura `list-birthdays` (ou `select` protegido),
   devolvendo **apenas nome + dia/mês** — nunca o ano nem o telefone.
2. **Domínio/Dados:** contrato de leitura + implementação Supabase.
3. **Composição:** `main_shell` injeta em `AniversariantesScreen(itens: ...)`
   os aniversariantes do mês atual. A tela **não muda** (já aceita `itens`).

## ⚠️ Dependência (EU-09 / LGPD)

Listar aniversariantes lê dados pessoais (nome + data de nascimento) de todos
os membros → **mesma trava de EU-09**. Risco menor que o diretório de telefones
(mostramos só nome + dia), mas ainda é um **slice de dados** que exige base
legal/consentimento aprovados antes de implementar.

**Decisão honesta para a RC1:** auditoria + plano entregues; a leitura real de
aniversariantes entra **após** a aprovação LGPD e a criação do endpoint.
