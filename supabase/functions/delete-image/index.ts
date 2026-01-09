
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

/**
 * Extracts Cloudinary public_id from URL
 */
function getPublicIdFromUrl(url: string | null): string | null {
    if (!url || !url.includes("cloudinary.com")) return null;
    try {
        const splitUrl = url.split("/upload/");
        if (splitUrl.length < 2) return null;
        const afterUpload = splitUrl[1];
        const parts = afterUpload.split("/");

        // Remove transformations if present (anything between /upload/ and vXXXX/ or the filename)
        // If the first part after /upload/ is NOT a version number, it's a transformation
        while (parts.length > 0 && !parts[0].match(/^v\d+$/) && parts.length > 1) {
            parts.shift();
        }

        // Remove version if present (starts with 'v' and followed by numbers)
        if (parts.length > 0 && parts[0].match(/^v\d+$/)) {
            parts.shift();
        }

        const publicIdWithExtension = parts.join("/");
        const lastDotIndex = publicIdWithExtension.lastIndexOf(".");
        return lastDotIndex !== -1 ? publicIdWithExtension.substring(0, lastDotIndex) : publicIdWithExtension;
    } catch (e) {
        return null;
    }
}

async function deleteFromCloudinary(publicId: string) {
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

    return await response.json();
}

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const payload = await req.json();
        console.log("Image Cleanup Webhook triggered:", payload.table, payload.type);

        const { type, table, record, old_record } = payload;
        const urlsToDelete: string[] = [];

        // Determine which columns to check based on table
        let columns: string[] = [];
        if (table === "menu_items") {
            columns = ["primary_image"];
        } else if (table === "shops") {
            columns = ["logo_url", "banner_url"];
        }

        if (columns.length === 0) {
            return new Response(JSON.stringify({ message: "Table not supported for cleanup." }), { status: 200 });
        }

        // Logic based on event type
        if (type === "DELETE") {
            columns.forEach(col => {
                if (old_record?.[col]) urlsToDelete.push(old_record[col]);
            });
        } else if (type === "UPDATE") {
            columns.forEach(col => {
                if (old_record?.[col] && old_record[col] !== record?.[col]) {
                    urlsToDelete.push(old_record[col]);
                }
            });
        }

        if (urlsToDelete.length === 0) {
            return new Response(JSON.stringify({ message: "No images to cleanup." }), { status: 200 });
        }

        const results = [];
        for (const url of urlsToDelete) {
            const publicId = getPublicIdFromUrl(url);
            if (publicId) {
                const res = await deleteFromCloudinary(publicId);
                results.push({ url, publicId, status: res });
            }
        }

        return new Response(JSON.stringify({ success: true, results }), {
            headers: { "Content-Type": "application/json" },
            status: 200,
        });

    } catch (error) {
        console.error("Cleanup error:", error.message);
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { "Content-Type": "application/json" },
            status: 400,
        });
    }
});
