import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = "re_a04481f6b3898c981f3da7d6c7ca6cf5c254dc46cf4e69e5f13f24f037cad3ec"; // User provided key

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { email, groupName, inviteLink, inviterName } = await req.json();

        console.log(`Sending invitation email to ${email} for group ${groupName}`);

        const res = await fetch("https://api.resend.com/emails", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${RESEND_API_KEY}`,
            },
            body: JSON.stringify({
                from: "Larnity <onboarding@resend.dev>", // Or update if they have a custom domain
                to: [email],
                subject: `You've been invited to join ${groupName} on Larnity!`,
                html: `
          <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Hello!</h2>
            <p>${inviterName || 'Someone'} has invited you to join the group <strong>${groupName}</strong> on Larnity.</p>
            <p>Click the link below to accept the invitation and get started:</p>
            <a href="${inviteLink}" style="display: inline-block; padding: 12px 24px; background-color: #FF5722; color: white; text-decoration: none; border-radius: 4px; font-weight: bold;">Accept Invitation</a>
            <p>If the button doesn't work, copy and paste this link into your browser:</p>
            <p>${inviteLink}</p>
            <hr />
            <p style="font-size: 12px; color: #666;">If you didn't expect this invitation, you can ignore this email.</p>
          </div>
        `,
            }),
        });

        const data = await res.json();

        if (!res.ok) {
            console.error("Resend API Error:", data);
            return new Response(JSON.stringify({ error: data }), {
                status: 400,
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            });
        }

        console.log("Email sent successfully:", data);

        return new Response(JSON.stringify(data), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        });
    } catch (error) {
        console.error("Error sending email:", error);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        });
    }
});
