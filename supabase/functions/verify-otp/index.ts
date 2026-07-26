// Edge Function: verify-otp
//
// Valida o código e resolve a autenticação:
// - falha → invalidCode | codeExpired | tooManyAttempts (escalonamento reversível)
// - sucesso com 1 identidade → sessão estabelecida
// - sucesso com várias identidades → seleção de identidade (WhatsApp compartilhado)

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json } from "../_shared/responses.ts";
import {
  activatePreRegistered,
  selectableIdentities,
  serviceClient,
  verifyChallenge,
} from "../_shared/otp_store.ts";
import { mintSession } from "../_shared/session.ts";
import { issueSelectionToken } from "../_shared/selection_token.ts";

function normalizeE164(raw: string): string {
  const digits = (raw ?? "").replace(/[^\d+]/g, "");
  return digits.startsWith("+") ? digits : `+${digits}`;
}

serve(async (req) => {
  if (req.method === "OPTIONS") return preflight();
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const body = await req.json().catch(() => ({}));
  const phoneE164 = normalizeE164(body.phone ?? "");
  const code = String(body.code ?? "");

  const db = serviceClient();

  const err = await verifyChallenge(db, phoneE164, code);
  if (err !== null) return json({ status: "failed", reason: err }, 200);

  // Sucesso: ativa pré-registradas (primeiro OTP → Ativa, A1) e resolve.
  const identities = await selectableIdentities(db, phoneE164);
  const preRegistered = identities
    .filter((i) => i.state === "pre_registered")
    .map((i) => i.canonicalId);
  await activatePreRegistered(db, preRegistered);

  if (identities.length === 1) {
    const session = await mintSession(identities[0].canonicalId);
    return json({
      status: "session",
      identity: { canonicalId: identities[0].canonicalId, displayName: identities[0].displayName },
      accessToken: session.accessToken,
      expiresIn: session.expiresIn,
    });
  }

  // WhatsApp compartilhado — o cliente precisa escolher a identidade.
  // O selectionToken amarra a escolha a este OTP validado.
  const selectionToken = await issueSelectionToken(
    phoneE164,
    identities.map((i) => i.canonicalId),
  );
  return json({
    status: "select_identity",
    selectionToken,
    identities: identities.map((i) => ({
      canonicalId: i.canonicalId,
      displayName: i.displayName,
    })),
  });
});
