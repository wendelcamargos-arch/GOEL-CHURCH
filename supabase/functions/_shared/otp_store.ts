// Ciclo de vida do OTP e consulta de identidades — server-side.
//
// Usa o service role do Supabase (bypassa RLS): estas tabelas NUNCA são
// acessadas diretamente pelo cliente. O código do OTP nunca é armazenado em
// texto — guardamos apenas o hash.
//
// INVARIANTE IDOSO-SEGURO (A2.1B): o excesso de tentativas gera COOLDOWN
// escalonado e REVERSÍVEL. Nunca há bloqueio permanente; o acesso permanece
// sempre recuperável.

import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

// --- Parâmetros operacionais (ajustáveis por ambiente) ---
// "Valor operacional reservado para futura parametrização, sem impacto na
// decisão arquitetural." Defaults sensatos; a POLÍTICA (escalonamento
// reversível) é que é arquitetural, não os números.
const OTP_DIGITS = Number(Deno.env.get("OTP_DIGITS") ?? "6");
const OTP_TTL_SECONDS = Number(Deno.env.get("OTP_TTL_SECONDS") ?? "300");
const OTP_MAX_ATTEMPTS = Number(Deno.env.get("OTP_MAX_ATTEMPTS") ?? "5");
const OTP_RESEND_GAP_SECONDS = Number(Deno.env.get("OTP_RESEND_GAP_SECONDS") ?? "60");
const OTP_COOLDOWN_BASE_SECONDS = Number(Deno.env.get("OTP_COOLDOWN_BASE_SECONDS") ?? "60");
const OTP_PEPPER = Deno.env.get("OTP_PEPPER") ?? "";

export type VerifyError = "codeExpired" | "invalidCode" | "tooManyAttempts";

export interface IdentityRow {
  canonicalId: string;
  displayName: string;
  state: string; // 'active' | 'pre_registered' | 'suspended' | 'ended'
}

export function serviceClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );
}

export function generateCode(): string {
  const max = 10 ** OTP_DIGITS;
  const n = crypto.getRandomValues(new Uint32Array(1))[0] % max;
  return n.toString().padStart(OTP_DIGITS, "0");
}

async function hashCode(phoneE164: string, code: string): Promise<string> {
  const data = new TextEncoder().encode(`${phoneE164}:${code}:${OTP_PEPPER}`);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)].map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

/// Identidades vinculadas ao número que PERMITEM login (active/pre_registered).
export async function selectableIdentities(
  db: SupabaseClient,
  phoneE164: string,
): Promise<IdentityRow[]> {
  const { data } = await db
    .from("phone_identity_links")
    .select("identities(id, display_name, state)")
    .eq("phone_e164", phoneE164);

  const rows = (data ?? [])
    .map((r: any) => r.identities)
    .filter((i: any) => i && (i.state === "active" || i.state === "pre_registered"))
    .map((i: any) => ({
      canonicalId: i.id as string,
      displayName: i.display_name as string,
      state: i.state as string,
    }));
  return rows;
}

/// Cria/renova um desafio de OTP para o número, respeitando o intervalo de
/// reenvio. Retorna o código em texto APENAS em memória (para envio), ou null
/// quando o reenvio deve ser contido.
export async function issueChallenge(
  db: SupabaseClient,
  phoneE164: string,
): Promise<string | null> {
  const now = Date.now();

  const { data: existing } = await db
    .from("otp_challenges")
    .select("last_sent_at, cooldown_until")
    .eq("phone_e164", phoneE164)
    .maybeSingle();

  if (existing) {
    if (existing.cooldown_until && new Date(existing.cooldown_until).getTime() > now) {
      return null; // em cooldown reversível — contém reenvio
    }
    if (
      existing.last_sent_at &&
      now - new Date(existing.last_sent_at).getTime() < OTP_RESEND_GAP_SECONDS * 1000
    ) {
      return null; // reenvio muito próximo — contido
    }
  }

  const code = generateCode();
  const codeHash = await hashCode(phoneE164, code);
  const expiresAt = new Date(now + OTP_TTL_SECONDS * 1000).toISOString();

  await db.from("otp_challenges").upsert({
    phone_e164: phoneE164,
    code_hash: codeHash,
    expires_at: expiresAt,
    attempts: 0,
    last_sent_at: new Date(now).toISOString(),
    cooldown_until: null,
  }, { onConflict: "phone_e164" });

  return code;
}

/// Valida o código. Escalona cooldown reversível ao exceder tentativas.
export async function verifyChallenge(
  db: SupabaseClient,
  phoneE164: string,
  code: string,
): Promise<VerifyError | null> {
  const now = Date.now();
  const { data: ch } = await db
    .from("otp_challenges")
    .select("code_hash, expires_at, attempts, cooldown_until")
    .eq("phone_e164", phoneE164)
    .maybeSingle();

  if (!ch) return "codeExpired";
  if (ch.cooldown_until && new Date(ch.cooldown_until).getTime() > now) {
    return "tooManyAttempts";
  }
  if (new Date(ch.expires_at).getTime() < now) return "codeExpired";

  const expected = ch.code_hash as string;
  const got = await hashCode(phoneE164, code);
  if (got === expected) {
    await db.from("otp_challenges").delete().eq("phone_e164", phoneE164);
    return null; // sucesso
  }

  const attempts = (ch.attempts as number) + 1;
  if (attempts >= OTP_MAX_ATTEMPTS) {
    // Escalonamento REVERSÍVEL: cooldown cresce, mas nunca é permanente.
    const cooldownUntil = new Date(
      now + OTP_COOLDOWN_BASE_SECONDS * 1000 * attempts,
    ).toISOString();
    await db.from("otp_challenges").update({
      attempts,
      cooldown_until: cooldownUntil,
    }).eq("phone_e164", phoneE164);
    return "tooManyAttempts";
  }

  await db.from("otp_challenges").update({ attempts }).eq("phone_e164", phoneE164);
  return "invalidCode";
}

/// Ativa identidades pré-registradas (primeira validação de OTP → Ativa, A1).
export async function activatePreRegistered(
  db: SupabaseClient,
  canonicalIds: string[],
): Promise<void> {
  if (canonicalIds.length === 0) return;
  await db
    .from("identities")
    .update({ state: "active" })
    .in("id", canonicalIds)
    .eq("state", "pre_registered");
}
