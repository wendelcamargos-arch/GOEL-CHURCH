// Cliente da Meta WhatsApp Cloud API.
//
// O TOKEN DA META VIVE APENAS AQUI (server-side), lido de variável de ambiente.
// Nunca é exposto ao cliente Flutter (Modelo de Confiança — P2A-02B-A1).

const GRAPH_VERSION = "v20.0";

interface MetaConfig {
  token: string;
  phoneNumberId: string;
  templateName: string;
  templateLang: string;
}

function readConfig(): MetaConfig | null {
  const token = Deno.env.get("META_WHATSAPP_TOKEN") ?? "";
  const phoneNumberId = Deno.env.get("META_WHATSAPP_PHONE_NUMBER_ID") ?? "";
  // Template de AUTENTICAÇÃO aprovado na Meta (obrigatório para OTP).
  const templateName = Deno.env.get("META_WHATSAPP_OTP_TEMPLATE") ?? "";
  const templateLang = Deno.env.get("META_WHATSAPP_OTP_TEMPLATE_LANG") ?? "pt_BR";
  if (!token || !phoneNumberId || !templateName) return null;
  return { token, phoneNumberId, templateName, templateLang };
}

/// Envia o código via template de autenticação do WhatsApp.
/// Retorna true em sucesso; false se indisponível/erro (o chamador mantém a
/// resposta uniforme e não vaza o motivo ao cliente).
export async function sendOtpViaWhatsApp(
  phoneE164: string,
  code: string,
): Promise<boolean> {
  const cfg = readConfig();
  if (cfg === null) return false;

  const url =
    `https://graph.facebook.com/${GRAPH_VERSION}/${cfg.phoneNumberId}/messages`;

  const payload = {
    messaging_product: "whatsapp",
    to: phoneE164,
    type: "template",
    template: {
      name: cfg.templateName,
      language: { code: cfg.templateLang },
      components: [
        {
          type: "body",
          parameters: [{ type: "text", text: code }],
        },
        {
          type: "button",
          sub_type: "url",
          index: 0,
          parameters: [{ type: "text", text: code }],
        },
      ],
    },
  };

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${cfg.token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });
    return res.ok;
  } catch (_) {
    return false;
  }
}
