# Escalas — Registro oficial da origem dos dados

**Sprint 4 — EU-05 (aprovado pelo Owner)**

## Origem atual
- **HARDCODED.** A equipe de cada ministério vive como dado fixo no código,
  em `lib/features/escalas/presentation/escalas_screen.dart` (`_exemplo`).
- Não há JSON, Mock (arquivo), SQLite nem Supabase envolvidos hoje.

## Planejamento futuro
- **Migração para Supabase.** A equipe passará a vir do backend (tabela de
  membros/ministérios), mantendo o rodízio automático (round-robin) já pronto.
- **Sem alterar a interface atual** desta tela — apenas a fonte de dados muda.

## Observação (Sprint 4)
- O número de pessoas por escala deixou de ser limitado a 3 e agora vai até o
  tamanho da equipe do ministério.
