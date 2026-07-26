// Edge Function: verse-of-the-day
//
// Retorna o versículo do dia. Escolhe uma referência de forma determinística
// (mesma no dia) e busca o TEXTO na API bíblica LICENCIADA (ex.: API.Bible)
// com a chave protegida SERVER-SIDE. Se não configurada / indisponível, retorna
// "unavailable" e o cliente usa seu fallback offline (domínio público).
//
// A NVI é conteúdo licenciado: a licença/curadoria é responsabilidade do owner.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json } from "../_shared/responses.ts";

// Referências (não são protegidas; só o TEXTO é). Formato de passagem no
// padrão API.Bible (ex.: JHN.3.16). Rotação diária determinística.
const REFERENCES: Array<{ display: string; passageId: string }> = [
  { display: "João 3:16", passageId: "JHN.3.16" },
  { display: "Salmos 23:1", passageId: "PSA.23.1" },
  { display: "Filipenses 4:13", passageId: "PHP.4.13" },
  { display: "Provérbios 3:5", passageId: "PRO.3.5" },
  { display: "Isaías 41:10", passageId: "ISA.41.10" },
  { display: "Romanos 8:28", passageId: "ROM.8.28" },
  { display: "Josué 1:9", passageId: "JOS.1.9" },
  { display: "Mateus 11:28", passageId: "MAT.11.28" },
  { display: "Jeremias 29:11", passageId: "JER.29.11" },
  { display: "Salmos 46:1", passageId: "PSA.46.1" },
];

function ordinalDay(now: Date): number {
  const start = Date.UTC(now.getUTCFullYear(), 0, 0);
  const diff = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate()) - start;
  return Math.floor(diff / 86400000);
}

serve(async (req) => {
  if (req.method === "OPTIONS") return preflight();

  const apiUrl = Deno.env.get("BIBLE_API_URL") ?? "https://api.scripture.api.bible";
  const apiKey = Deno.env.get("BIBLE_API_KEY") ?? "";
  const bibleId = Deno.env.get("BIBLE_NVI_ID") ?? ""; // id da NVI na API licenciada

  const ref = REFERENCES[ordinalDay(new Date()) % REFERENCES.length];

  if (!apiKey || !bibleId) {
    return json({ status: "unavailable", reference: ref.display });
  }

  try {
    const url = `${apiUrl}/v1/bibles/${bibleId}/passages/${ref.passageId}` +
      `?content-type=text&include-verse-numbers=false&include-notes=false&include-titles=false`;
    const res = await fetch(url, { headers: { "api-key": apiKey } });
    if (!res.ok) return json({ status: "unavailable", reference: ref.display });
    const body = await res.json();
    const text = (body?.data?.content ?? "").toString().trim();
    if (!text) return json({ status: "unavailable", reference: ref.display });
    return json({ status: "ok", reference: ref.display, text });
  } catch (_) {
    return json({ status: "unavailable", reference: ref.display });
  }
});
