# EU-08 — Arquitetura proposta: Bíblia em modo HÍBRIDO

> **STATUS: ARQUITETURA APROVADA PELO OWNER (RC1).** Não implementar nesta
> Release 1.1.0 — será planejada posteriormente. Este documento passa a ser a
> referência oficial de arquitetura para o modo híbrido.

## Objetivo

- **Online** quando houver conexão (texto sempre disponível, espaço para
  versões/recursos adicionais servidos pela nuvem).
- **Offline (Almeida 1911)** como *fallback* garantido — o app **nunca** fica
  sem Bíblia, mesmo sem internet.

## Princípio: o offline JÁ EXISTE e é a base

A Bíblia offline entregue na 1.1.0 (Almeida 1911, 66 livros / 1.189 capítulos /
31.102 versículos) permanece como **fonte de verdade local**. O modo híbrido é
uma **camada por cima**, sem quebrar nada do que já funciona.

## Desenho em camadas (preserva o contrato atual)

```
Presentation (telas de leitura/busca) — INALTERADAS
        │
        ▼
BibleRepository (contrato do domínio) — INALTERADO
        │
        ▼
HybridBibleRepository  ← NOVO (decorator)
    ├── OnlineBibleSource   (rede; quando disponível)
    └── AssetBibleRepository (offline Almeida 1911; fallback) ← ATUAL
```

- O contrato `BibleRepository` (`livros()`, `capitulo()`,
  `resolverReferencia()`, `buscarPalavra()`) **não muda**.
- Um novo `HybridBibleRepository` decide a fonte por chamada; as telas nem
  percebem.

## Política de decisão (por requisição)

1. **Sem conexão** → usa offline (Almeida 1911). Sempre funciona.
2. **Com conexão**:
   - Tenta a fonte online com **timeout curto** (ex.: 2–3 s).
   - Falhou/expirou → **fallback imediato** para o offline.
   - Sucesso → usa o online e (opcional) **cacheia** para leituras futuras.
3. **Escolha de versão**: se o usuário selecionar uma versão que só existe
   online e estiver offline, avisamos com honestidade e oferecemos a Almeida
   1911 offline.

## Cache e desempenho

- Reaproveitar o **LRU cache** já existente (livros decodificados) e o
  `manifest.json`.
- Cache online opcional em disco (por capítulo), com verificação de validade,
  para acelerar releituras e reduzir dados móveis.
- Busca continua via *stream* em background (não trava a UI).

## Sincronização e atualização

- Offline é **empacotado no app** (já é). Atualizações da base offline entram
  por release normal.
- Online permite corrigir/adicionar conteúdo **sem** nova release, quando o
  backend existir.

## Fora de escopo agora (decisões que dependem de você)

- **Qual backend** serve o conteúdo online (Supabase Storage? API própria?).
- **Quais versões** além da Almeida 1911 (licenciamento de cada tradução —
  algumas exigem autorização/pagamento).
- **Política de dados móveis** (baixar só no Wi‑Fi? pré-baixar livros?).

## Riscos / cuidados

- **Licenciamento**: só publicar traduções com direito de uso claro (a Almeida
  1911 é domínio público; outras podem não ser).
- **Consistência de referências**: o `ReferenceParser` e o esquema de
  `bookId:cap:ver` devem valer para online e offline (mesmo manifesto).
- **Custo/estabilidade** da fonte online — por isso o offline é o alicerce.

## Recomendação

Aprovar o **decorator `HybridBibleRepository`** como caminho, mantendo a
Almeida 1911 offline como base. Implementação só após:
1. definição do backend/versões, e
2. confirmação de licenciamento das versões extras.
