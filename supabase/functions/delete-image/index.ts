
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

/**
 * Extracts Cloudinary public_id from URL
 */
function getPublicIdFromUrl(url: string): string | null {
    if (!url || !url.includes("cloudinary.com")) return null;
    try {
        const splitUrl = url.split("/upload/");
        if (splitUrl.length < 2) return null;
        const afterUpload = splitUrl[1];
        const parts = afterUpload.split("/");
        if (parts.length > 0 && parts[0].match(/^v\d+$/)) {
            parts.shift();
        }
        const publicIdWithExtension = parts.join("/");
        return publicIdWithExtension.substring(0, publicIdWithExtension.lastIndexOf("."));
    } catch (e) {
        return null;
    }
}

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const payload = await req.json();
        console.log("Webhook received payload:", JSON.stringify(payload, null, 2));

        const { type, table, record, old_record } = payload;
        let imageUrlToDelete = null;

        // Logic based on event type
        if (type === "DELETE") {
            imageUrlToDelete = old_record?.primary_image;
        } else if (type === "UPDATE") {
            // If the image was changed, delete the old one
            if (old_record?.primary_image && old_record.primary_image !== record?.primary_image) {
                imageUrlToDelete = old_record.primary_image;
            }
        }

        if (!imageUrlToDelete) {
            return new Response(JSON.stringify({ message: "No image cleanup needed." }), {
                headers: { "Content-Type": "application/json" },
                status: 200,
            });
        }

        const publicId = getPublicIdFromUrl(imageUrlToDelete);
        if (!publicId) {
            return new Response(JSON.stringify({ error: "Could not extract public_id" }), {
                headers: { "Content-Type": "application/json" },
                status: 200, // Not 400 because we don't want to break the webhook retry logic if it's just a non-cloudinary URL
            });
        }

        const cloudName = Deno.env.get("CLOUDINARY_CLOUD_NAME");
        const apiKey = Deno.env.get("CLOUDINARY_API_KEY");
        const apiSecret = Deno.env.get("CLOUDINARY_API_SECRET");

        if (!cloudName || !apiKey || !apiSecret) {
            throw new Error("Missing Cloudinary credentials");
        }

        const auth = btoa(`${apiKey}:${apiSecret}`);
        const url = `https://api.cloudinary.com/v1_1/${cloudName}/resources/image/upload?public_ids[]=${publicId}`;

        console.log(`🗑️ Deleting from Cloudinary: ${publicId}`);

        const response = await fetch(url, {
            method: "DELETE",
            headers: { "Authorization": `Basic ${auth}` },
        });

        const data = await response.json();

        return new Response(JSON.stringify({ success: true, result: data }), {
            headers: { "Content-Type": "application/json" },
            status: 200,
        });

    } catch (error) {
        console.error("Function error:", error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { "Content-Type": "application/json" },
            status: 400,
        });
    }
});
