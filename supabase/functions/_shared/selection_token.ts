// Token de seleção de identidade — curto e assinado.
//
// Emitido por verify-otp quando o número autentica MAIS DE UMA identidade
// (WhatsApp compartilhado). Amarra a escolha subsequente a um OTP recém
// validado: sem ele, ninguém pode pedir sessão para uma identidade arbitrária.

function b64url(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}
function fromB64url(s: string): Uint8Array {
  const pad = s.replace(/-/g, "+").replace(/_/g, "/");
  return Uint8Array.from(atob(pad), (c) => c.charCodeAt(0));
}

async function hmac(input: string): Promise<Uint8Array> {
  const secret = Deno.env.get("SUPABASE_JWT_SECRET")!;
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign("HMAC", key, new TextEncoder().encode(input));
  return new Uint8Array(sig);
}

const TTL_SECONDS = 120; // janela curta de seleção (parametrizável)

export async function issueSelectionToken(
  phoneE164: string,
  allowedCanonicalIds: string[],
): Promise<string> {
  const payload = {
    phone: phoneE164,
    ids: allowedCanonicalIds,
    exp: Math.floor(Date.now() / 1000) + TTL_SECONDS,
  };
  const body = b64url(new TextEncoder().encode(JSON.stringify(payload)));
  const sig = b64url(await hmac(body));
  return `${body}.${sig}`;
}

export interface SelectionClaims {
  phone: string;
  ids: string[];
}

export async function verifySelectionToken(
  token: string,
): Promise<SelectionClaims | null> {
  const [body, sig] = token.split(".");
  if (!body || !sig) return null;
  const expected = b64url(await hmac(body));
  if (expected !== sig) return null;
  const claims = JSON.parse(new TextDecoder().decode(fromB64url(body)));
  if ((claims.exp ?? 0) < Math.floor(Date.now() / 1000)) return null;
  return { phone: claims.phone, ids: claims.ids };
}
