export const CLOUDINARY_CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME;
export const CLOUDINARY_UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET;

/**
 * Uploads an image file to Cloudinary using an unsigned upload preset.
 * @param file The image file to upload.
 * @returns The secure URL of the uploaded image.
 */
export async function uploadImage(file: File): Promise<string> {
    if (!CLOUDINARY_CLOUD_NAME || !CLOUDINARY_UPLOAD_PRESET) {
        throw new Error("Cloudinary configuration is missing. Please check VITE_CLOUDINARY_CLOUD_NAME and VITE_CLOUDINARY_UPLOAD_PRESET in .env");
    }

    const formData = new FormData();
    formData.append("file", file);
    formData.append("upload_preset", CLOUDINARY_UPLOAD_PRESET);
    // Auto-format to WebP or best format for the browser
    // Cloudinary handles this automatically usually, but we can force or hint if needed.
    // Using f_auto,q_auto via URL transformation relies on delivery URL, 
    // but for upload we just send the file.

    // Note: We can add 'folder' if needed, e.g. formData.append("folder", "orbfood_menus");

    try {
        const response = await fetch(
            `https://api.cloudinary.com/v1_1/${CLOUDINARY_CLOUD_NAME}/image/upload`,
            {
                method: "POST",
                body: formData,
            }
        );

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.error?.message || "Upload failed");
        }

        const data = await response.json();
        return data.secure_url;
    } catch (error) {
        console.error("Cloudinary upload error:", error);
        throw error;
    }
}

/**
 * Generates an optimized image URL (WebP, auto quality).
 * Use this when displaying images if the original URL is raw.
 * @param url The original Cloudinary URL
 * @param width Optional width to resize to
 */
export function getOptimizedImageUrl(url: string, width?: number): string {
    if (!url || !url.includes("cloudinary.com")) return url;

    // Simple insertion of transformation parameters
    // Format: .../upload/{transformations}/v{version}/{public_id}
    // We want: .../upload/f_auto,q_auto{,w_width}/...

    const parts = url.split("/upload/");
    if (parts.length !== 2) return url;

    let transformation = "f_auto,q_auto";
    if (width) {
        transformation += `,w_${width}`;
    }

    return `${parts[0]}/upload/${transformation}/${parts[1]}`;
}

/**
 * Extracts the public ID from a Cloudinary URL.
 * Supports URLs with folders and version numbers.
 * @param url The Cloudinary image URL
 * @returns The public ID or null if not found
 */
export function getPublicIdFromUrl(url: string): string | null {
    if (!url || !url.includes("cloudinary.com")) return null;

    try {
        // Regex to match the part after /upload/ and optional version (v12345/...), until the extension
        // Example: .../upload/v12345678/folder/my_image.jpg -> folder/my_image
        // Example: .../upload/folder/my_image.jpg -> folder/my_image

        const splitUrl = url.split("/upload/");
        if (splitUrl.length < 2) return null;

        const afterUpload = splitUrl[1];
        const parts = afterUpload.split("/");

        // Remove version if present (starts with 'v' and followed by numbers)
        if (parts.length > 0 && parts[0].match(/^v\d+$/)) {
            parts.shift();
        }

        const publicIdWithExtension = parts.join("/");
        const publicId = publicIdWithExtension.substring(0, publicIdWithExtension.lastIndexOf("."));

        return publicId;
    } catch (e) {
        console.error("Error extracting public ID:", e);
        return null;
    }
}

return publicId;
    } catch (e) {
    console.error("Error extracting public ID:", e);
    return null;
}
}
