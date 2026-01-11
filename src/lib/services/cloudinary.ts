import { supabase } from "./supabase";

export const CLOUDINARY_CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME;
export const CLOUDINARY_UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET;

/**
 * Uploads an image file to Cloudinary via a secure Supabase Edge Function.
 * @param file The image file to upload.
 * @param folder The folder to store the image in.
 * @returns The secure URL of the uploaded image.
 */
export async function uploadImage(file: File, folder: string = 'general'): Promise<string> {
    const { data: { session } } = await supabase.auth.getSession();

    const formData = new FormData();
    formData.append("file", file);
    formData.append("folder", folder);

    try {
        const response = await fetch(
            `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/cloudinary-upload`,
            {
                method: "POST",
                headers: {
                    'Authorization': `Bearer ${session?.access_token || import.meta.env.VITE_SUPABASE_ANON_KEY}`,
                },
                body: formData,
            }
        );

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error || "Upload failed");
        }

        const data = await response.json();
        return data.secure_url;
    } catch (error) {
        console.error("Cloudinary upload error:", error);
        throw error;
    }
}


/**
 * Generates an optimized image URL (WebP/AVIF, auto quality).
 * Ensures 'f_auto,q_auto' is always applied.
 * @param url The original Cloudinary URL
 * @param width Optional width to resize to
 */
export function getOptimizedImageUrl(url: string, width?: number): string {
    if (!url || !url.includes("cloudinary.com")) return url;

    // Split at /upload/ to insert transformations
    const parts = url.split("/upload/");
    if (parts.length !== 2) return url;

    const base = parts[0];
    let rest = parts[1];

    // If there are already transformations, they appear before 'vYYYY' or 'public_id'
    // Format: .../upload/{transformations}/v{version}/{public_id}
    // We want to force f_auto,q_auto

    // Check if the first part of 'rest' is a transformation string (doesn't start with 'v' followed by numbers, and has more parts)
    const restParts = rest.split("/");
    if (restParts.length > 1 && !restParts[0].match(/^v\d+$/)) {
        // It has existing transformations, remove them to replace with optimized ones
        restParts.shift();
        rest = restParts.join("/");
    }

    let transformation = "f_auto,q_auto";
    if (width) {
        transformation += `,w_${width},c_limit`; // c_limit keeps aspect ratio and doesn't upscale
    }

    return `${base}/upload/${transformation}/${rest}`;
}

/**
 * Extracts the public ID from a Cloudinary URL.
 * @param url The Cloudinary image URL
 */
export function getPublicIdFromUrl(url: string): string | null {
    if (!url || !url.includes("cloudinary.com")) return null;

    try {
        const splitUrl = url.split("/upload/");
        if (splitUrl.length < 2) return null;

        let afterUpload = splitUrl[1];
        const parts = afterUpload.split("/");

        // Skip transformations if present
        while (parts.length > 0 && !parts[0].match(/^v\d+$/) && parts.length > 1) {
            parts.shift();
        }

        // Skip version if present
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
