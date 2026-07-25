// Edge Function AGENDADA: birthday-greetings
//
// AUTOMAÇÃO DE ANIVERSÁRIO — 100% automática, sem intervenção humana.
// Executa uma vez ao dia (agendar às 08:00 America/Sao_Paulo), busca os
// aniversariantes do dia (com opt-in) e envia a saudação pelo WhatsApp.
//
// Agendamento (do seu lado): Supabase Scheduled Functions / pg_cron chamando
// esta função diariamente. Ex.: cron "0 11 * * *" em UTC ≈ 08:00 BRT.

import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { json } from "../_shared/responses.ts";
import { serviceClient } from "../_shared/otp_store.ts";
import { sendBirthdayGreeting } from "../_shared/meta_whatsapp.ts";

serve(async (req) => {
  // Protege contra chamada indevida: exige o header do agendador.
  const secret = Deno.env.get("SCHEDULER_SECRET") ?? "";
  if (secret && req.headers.get("x-scheduler-secret") !== secret) {
    return json({ error: "forbidden" }, 403);
  }

  const db = serviceClient();
  const { data, error } = await db.rpc("members_with_birthday_today");
  if (error) return json({ status: "error" }, 500);

  const rows = (data ?? []) as Array<
    { identity_id: string; full_name: string; phone_e164: string }
  >;

  let sent = 0;
  for (const r of rows) {
    const ok = await sendBirthdayGreeting(r.phone_e164, r.full_name);
    if (ok) sent++;
  }

  return json({ status: "done", candidates: rows.length, sent });
});
