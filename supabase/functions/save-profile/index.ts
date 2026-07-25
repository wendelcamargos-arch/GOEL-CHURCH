// Edge Function: save-profile
//
// Salva/atualiza o perfil do membro autenticado. Valida a sessão (JWT emitido
// no login) e faz upsert com service role. birth_date é dado de perfil (nunca
// autenticação) e alimenta a automação de aniversário.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json } from "../_shared/responses.ts";
import { serviceClient } from "../_shared/otp_store.ts";
import { verifySession } from "../_shared/session.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return preflight();
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("Authorization") ?? "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";
  const canonicalId = await verifySession(token);
  if (canonicalId === null) {
    return json({ status: "failed", reason: "unauthenticated" }, 401);
  }

  const body = await req.json().catch(() => ({}));
  const fullName = String(body.fullName ?? "").trim();
  const birthDate = String(body.birthDate ?? ""); // 'YYYY-MM-DD'
  const whatsappOptIn = Boolean(body.whatsappOptIn ?? false);

  if (fullName.length < 2 || !/^\d{4}-\d{2}-\d{2}$/.test(birthDate)) {
    return json({ status: "failed", reason: "invalid" }, 200);
  }

  const db = serviceClient();
  const { error } = await db.from("member_profiles").upsert({
    identity_id: canonicalId,
    full_name: fullName,
    birth_date: birthDate,
    whatsapp_opt_in: whatsappOptIn,
    updated_at: new Date().toISOString(),
  }, { onConflict: "identity_id" });

  if (error) return json({ status: "failed", reason: "unavailable" }, 200);
  return json({ status: "saved" });
});
