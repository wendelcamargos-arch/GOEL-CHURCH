# core/

Utilitários transversais da camada de entrega (Flutter) que não pertencem a
nenhum bounded context específico.

Regras:
- **Não** contém regra de negócio (isso vive em `packages/goel_domain`).
- **Não** expõe internals de módulos de feature.
- Mantém-se pequeno: só entra aqui o que é genuinamente compartilhado.

Vazio no Slice 01 por design — cresce conforme os slices seguintes exigirem.
