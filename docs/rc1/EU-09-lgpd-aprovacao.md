# EU-09 — Documento de aprovação LGPD (Slices 08 e 09)

> **STATUS: DOCUMENTO APROVADO PELO OWNER (RC1).** Fica registrado como
> **PRÉ-REQUISITO OBRIGATÓRIO** para **qualquer** funcionalidade que liste
> dados pessoais (ex.: Membros / Aniversariantes com dados reais). Nenhum slice
> desse tipo pode ser iniciado sem cumprir este documento.
>
> Observação mantida: **recomenda-se validação por responsável jurídico /
> encarregado (DPO)** antes de produção. Não é parecer jurídico.

## Contexto

Os slices 08 e 09 (diretório de **Membros** e **Aniversariantes** com dados
reais — ver EU-04 e EU-07) tratam **dados pessoais** de membros da igreja:
nome completo, telefone/WhatsApp e data de nascimento. Por isso, exigem base
legal e salvaguardas LGPD (Lei 13.709/2018) **antes** de qualquer leitura/
exibição real.

## 1. Base legal (Art. 7º / 11)

| Dado | Finalidade | Base legal sugerida |
|---|---|---|
| Nome completo | Identificação do membro; diretório | **Consentimento** (Art. 7º, I) |
| Telefone/WhatsApp | Contato pastoral e comunitário | **Consentimento** (Art. 7º, I) |
| Data de nascimento | Aniversariantes do mês | **Consentimento** (Art. 7º, I) |

> Observação: dados de congregados podem envolver **contexto religioso**. Ainda
> que os campos acima não sejam, por si, "dado sensível", o vínculo a uma
> igreja pode caracterizar convicção religiosa (Art. 5º, II). Por prudência,
> adotamos **consentimento específico e destacado** como base — a ser
> confirmado pelo DPO.

## 2. Consentimento

- **Momento:** no cadastro (após login), com **opt‑in explícito** por
  finalidade (checkbox separado para "aparecer no diretório de membros" e para
  "aparecer nos aniversariantes"). Já existe o campo `whatsappOptIn` no perfil
  como precedente.
- **Forma:** linguagem clara, sem caixas pré‑marcadas, granular por finalidade.
- **Registro:** guardar data/hora e versão do texto de consentimento aceito.
- **Menores:** cadastro de menores de idade requer consentimento do
  responsável (Art. 14) — definir política (idade mínima? autorização?).

## 3. Finalidade

- Uso **restrito** às finalidades declaradas (contato pastoral/comunitário e
  celebração de aniversários). **Proibido** uso para marketing externo,
  compartilhamento com terceiros ou venda.
- **Minimização:** aniversariantes exibem **apenas nome + dia/mês** (nunca o
  ano); diretório exibe telefone **somente** a quem tiver permissão.

## 4. Retenção

- Manter os dados **enquanto durar o vínculo** do membro com a igreja e o
  consentimento.
- **Descarte/anonimização** após revogação do consentimento ou saída do
  membro, respeitando eventuais obrigações legais de guarda.
- Definir prazo de revisão periódica (ex.: revisão anual da base).

## 5. Revogação

- O membro pode **revogar o consentimento a qualquer momento**, de forma tão
  fácil quanto concedê‑lo (tela de perfil: "Sair do diretório" / "Não exibir
  meu aniversário").
- Revogação → remoção **imediata** da exibição e agendamento de
  descarte/anonimização.

## 6. Controle de acesso e segurança

- **Diretório de telefones:** visível **apenas** a papéis autorizados
  (ex.: liderança), nunca a todos. Aplicar **RLS** no Supabase.
- Exportação (CSV) restrita a administradores e **registrada**.
- Tráfego sempre por HTTPS; tokens de sessão; sem expor dados a usuários não
  autenticados.

## 7. Auditoria e direitos do titular

- **Log de acessos** a dados pessoais (quem leu/exportou, quando).
- Atender aos **direitos do titular** (Art. 18): confirmação, acesso,
  correção, eliminação, portabilidade e informação sobre compartilhamentos.
- Canal do **encarregado (DPO)** publicado (contato) para requisições e
  incidentes; plano de resposta a incidentes.

## Pendências para você decidir/confirmar

1. Aprovar as **bases legais** (consentimento por finalidade) — idealmente com
   o DPO/jurídico.
2. Definir **política para menores**.
3. Definir **quem** vê o diretório de telefones (papéis/permissões).
4. Definir **prazos de retenção** e rotina de revisão.
5. Publicar **Política de Privacidade** e contato do encarregado.

> Só após a aprovação deste documento os slices 08 e 09 (EU-04 / EU-07 com
> dados reais) podem ser iniciados.
