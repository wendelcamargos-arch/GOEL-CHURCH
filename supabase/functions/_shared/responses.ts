// Respostas HTTP compartilhadas das Edge Functions de autenticação.

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/// Resposta UNIFORME da solicitação de OTP (controle C4/C5 — anti-enumeração).
/// É idêntica exista ou não o número no cadastro: nunca revela se é membro.
export function uniformOtpAccepted(): Response {
  return json({ status: "otp_requested" }, 200);
}

export function preflight(): Response {
  return new Response("ok", { headers: corsHeaders });
}
