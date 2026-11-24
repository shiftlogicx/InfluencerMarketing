import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const SENDER_EMAIL = "notifications@creatorpulse.app";

interface NotificationPayload {
  influencer_id: string;
  influencer_email: string;
  influencer_tier: "free" | "gold" | "burgundy";
  brand_id: string;
  brand_name: string;
  brand_email: string;
  brand_category: string;
  brand_location: string;
}

serve(async (req) => {
  // CORS Headers
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    const payload: NotificationPayload = await req.json();

    let subject = "";
    let htmlContent = "";

    // BRD Module 4 Logic:
    // If Influencer is on Free Tier:
    // Email subject reads, "Someone viewed your profile!"
    // Body says, "A brand looking for [Category] in [Location] viewed your profile. Upgrade to Gold to see who they are and contact them directly."
    if (payload.influencer_tier === "free") {
      subject = "Someone viewed your profile!";
      htmlContent = `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #070709; color: #F5F5F7; padding: 40px; border-radius: 16px; max-width: 580px; margin: 0 auto; border: 1px solid rgba(255,255,255,0.1);">
          <div style="font-size: 11px; letter-spacing: 1px; color: #86868B; text-transform: uppercase; font-weight: 700; margin-bottom: 12px;">CreatorPulse Lead Engine</div>
          <h2 style="font-size: 24px; font-weight: 700; color: #FFFFFF; margin-top: 0;">Someone viewed your profile!</h2>
          <p style="font-size: 15px; line-height: 1.6; color: #86868B;">
            A brand looking for <strong>${payload.brand_category}</strong> in <strong>${payload.brand_location}</strong> viewed your profile.
          </p>
          <div style="margin: 28px 0; padding: 20px; background-color: #101014; border-radius: 12px; border: 1px solid rgba(229,192,123,0.3);">
            <div style="font-size: 13px; color: #E5C07B; font-weight: 600;">Upgrade to Gold (₹149 / 3 months)</div>
            <div style="font-size: 12px; color: #86868B; margin-top: 4px;">Unlock the exact brand name, decision-maker email, and proactive reach-out coordinates.</div>
          </div>
          <a href="https://creatorpulse-app.web.app" style="display: inline-block; background-color: #E5C07B; color: #000000; font-weight: 700; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-size: 14px;">Upgrade to Gold & Unlock Lead</a>
        </div>
      `;
    } else {
      // BRD Module 4 Logic:
      // If Influencer is on Gold/Burgundy Tier:
      // Email subject reads, "[Brand Name] viewed your profile!"
      // Body includes the brand's registered email/name so the influencer can proactively reach out.
      subject = `${payload.brand_name} viewed your profile!`;
      htmlContent = `
        <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #070709; color: #F5F5F7; padding: 40px; border-radius: 16px; max-width: 580px; margin: 0 auto; border: 1px solid rgba(255,255,255,0.1);">
          <div style="font-size: 11px; letter-spacing: 1px; color: #30D158; text-transform: uppercase; font-weight: 700; margin-bottom: 12px;">Verified Brand Interest (${payload.influencer_tier.toUpperCase()})</div>
          <h2 style="font-size: 24px; font-weight: 700; color: #FFFFFF; margin-top: 0;">${payload.brand_name} viewed your profile!</h2>
          <p style="font-size: 15px; line-height: 1.6; color: #86868B;">
            A marketing representative from <strong>${payload.brand_name}</strong> just discovered your portfolio for upcoming <strong>${payload.brand_category}</strong> campaigns in <strong>${payload.brand_location}</strong>.
          </p>
          <div style="margin: 24px 0; padding: 20px; background-color: #101014; border-radius: 12px; border: 1px solid rgba(41,151,255,0.3);">
            <div style="font-size: 13px; color: #FFFFFF; font-weight: 600;">Brand Contact Coordinates:</div>
            <div style="font-size: 13px; color: #2997FF; margin-top: 6px;">Email: <a href="mailto:${payload.brand_email}" style="color: #2997FF;">${payload.brand_email}</a></div>
            <div style="font-size: 12px; color: #86868B; margin-top: 4px;">Location: ${payload.brand_location}</div>
          </div>
          <a href="mailto:${payload.brand_email}?subject=Collaboration%20Inquiry%20via%20CreatorPulse" style="display: inline-block; background-color: #2997FF; color: #FFFFFF; font-weight: 700; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-size: 14px;">Contact Brand Directly</a>
        </div>
      `;
    }

    // Dispatch via Resend API
    let resendResponse = { id: "simulated_resend_id" };
    if (RESEND_API_KEY) {
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: SENDER_EMAIL,
          to: [payload.influencer_email],
          subject: subject,
          html: htmlContent,
        }),
      });
      resendResponse = await res.json();
    }

    return new Response(
      JSON.stringify({
        status: "success",
        subject,
        recipient: payload.influencer_email,
        resend: resendResponse,
      }),
      {
        headers: { "Content-Type": "application/json" },
        status: 200,
      }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ status: "error", message: err.message }),
      {
        headers: { "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
