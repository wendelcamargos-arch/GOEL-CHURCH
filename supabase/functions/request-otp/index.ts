// Edge Function: request-otp
//
// Emite um OTP via WhatsApp para números ELEGÍVEIS (enrollment controlado).
// Resposta SEMPRE UNIFORME (anti-enumeração): nunca revela se o número é membro.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, uniformOtpAccepted, json } from "../_shared/responses.ts";
import {
  issueChallenge,
  selectableIdentities,
  serviceClient,
} from "../_shared/otp_store.ts";
import { sendOtpViaWhatsApp } from "../_shared/meta_whatsapp.ts";

function normalizeE164(raw: string): string {
  const digits = (raw ?? "").replace(/[^\d+]/g, "");
  return digits.startsWith("+") ? digits : `+${digits}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return preflight();
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let phoneE164 = "";
  try {
    const body = await req.json();
    phoneE164 = normalizeE164(body.phone ?? "");
  } catch (_) {
    // Corpo inválido — mantém resposta uniforme para não vazar sinal.
    return uniformOtpAccepted();
  }

  const db = serviceClient();

  // Enrollment controlado: só números com identidade elegível recebem OTP.
  // A resposta é a mesma para conhecidos e desconhecidos.
  const identities = await selectableIdentities(db, phoneE164);
  if (identities.length > 0) {
    const code = await issueChallenge(db, phoneE164);
    if (code !== null) {
      await sendOtpViaWhatsApp(phoneE164, code); // falha silenciosa não vaza motivo
    }
  }

  return uniformOtpAccepted();
});
