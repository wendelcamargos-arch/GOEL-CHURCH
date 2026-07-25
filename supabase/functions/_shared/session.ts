// Emissão de sessão após autenticação bem-sucedida.
//
// Mint de um JWT compatível com o Supabase (HS256, assinado com o
// SUPABASE_JWT_SECRET), com `sub` = identificador canônico da identidade
// (A1 §2.X.2). O cliente aplica via supabase.auth.setSession.
//
// SESSÃO DE LONGA DURAÇÃO (A2.2A): TTL amplo para reduzir reautenticação por
// OTP (custo Meta + fricção ao idoso). O valor é operacional/parametrizável.
//
// REVOGAÇÃO (A2.2B): como o JWT é stateless, a revogação atrelada ao estado da
// identidade é aplicada nos CHECKPOINTS server-side de operações privilegiadas
// (identidade Suspensa/Encerrada é rejeitada ali). A sessão nunca "autoriza" por
// si só uma operação sensível sem essa verificação de estado.

function b64url(bytes: Uint8Array): string {
  let s = btoa(String.fromCharCode(...bytes));
  return s.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function b64urlStr(str: string): string {
  return b64url(new TextEncoder().encode(str));
}

export interface IssuedSession {
  accessToken: string;
  expiresIn: number;
}

export async function mintSession(canonicalId: string): Promise<IssuedSession> {
  const secret = Deno.env.get("SUPABASE_JWT_SECRET")!;
  const ttl = Number(Deno.env.get("SESSION_TTL_SECONDS") ?? "2592000"); // ~30d (parametrizável)
  const now = Math.floor(Date.now() / 1000);

  const header = { alg: "HS256", typ: "JWT" };
  const payload = {
    sub: canonicalId,
    role: "authenticated",
    aud: "authenticated",
    iat: now,
    exp: now + ttl,
  };

  const signingInput = `${b64urlStr(JSON.stringify(header))}.${b64urlStr(JSON.stringify(payload))}`;

  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(signingInput),
  );

  const jwt = `${signingInput}.${b64url(new Uint8Array(sig))}`;
  return { accessToken: jwt, expiresIn: ttl };
}
