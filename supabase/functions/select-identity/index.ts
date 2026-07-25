// Edge Function: select-identity
//
// Conclui a autenticação quando o número autentica várias identidades. Só emite
// sessão se: (a) o selectionToken é válido; (b) a identidade escolhida estava no
// conjunto autorizado; (c) ela ainda permite login (não Suspensa/Encerrada).

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { preflight, json } from "../_shared/responses.ts";
import { selectableIdentities, serviceClient } from "../_shared/otp_store.ts";
import { mintSession } from "../_shared/session.ts";
import { verifySelectionToken } from "../_shared/selection_token.ts";

serve(async (req) => {
  if (req.method === "OPTIONS") return preflight();
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const body = await req.json().catch(() => ({}));
  const token = String(body.selectionToken ?? "");
  const canonicalId = String(body.canonicalId ?? "");

  const claims = await verifySelectionToken(token);
  if (claims === null || !claims.ids.includes(canonicalId)) {
    return json({ status: "failed", reason: "invalidSelection" }, 200);
  }

  // Reconfirma o estado atual: a identidade precisa continuar selecionável.
  const db = serviceClient();
  const stillSelectable = await selectableIdentities(db, claims.phone);
  if (!stillSelectable.some((i) => i.canonicalId === canonicalId)) {
    return json({ status: "failed", reason: "invalidSelection" }, 200);
  }

  const session = await mintSession(canonicalId);
  return json({
    status: "session",
    identity: { canonicalId },
    accessToken: session.accessToken,
    expiresIn: session.expiresIn,
  });
});
