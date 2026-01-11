// @ts-nocheck
import { serve } from "http/server.ts"
import { v2 as cloudinary } from "cloudinary"

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const formData = await req.formData()
        const file = formData.get('file') as File
        const folder = formData.get('folder') as string || 'general'

        if (!file) {
            return new Response(JSON.stringify({ error: 'No file uploaded' }), {
                headers: { ...corsHeaders, 'Content-Type': 'application/json' },
                status: 400,
            })
        }

        // Configure Cloudinary
        cloudinary.config({
            cloud_name: Deno.env.get('CLOUDINARY_CLOUD_NAME'),
            api_key: Deno.env.get('CLOUDINARY_API_KEY'),
            api_secret: Deno.env.get('CLOUDINARY_API_SECRET'),
            secure: true
        })

        // Convert file to arrayBuffer
        const arrayBuffer = await file.arrayBuffer()
        const base64 = btoa(new Uint8Array(arrayBuffer).reduce((data, byte) => data + String.fromCharCode(byte), ''))
        const dataUrl = `data:${file.type};base64,${base64}`

        // Upload to Cloudinary
        const result = await cloudinary.uploader.upload(dataUrl, {
            folder: `orbfood/${folder}`,
            resource_type: 'auto',
        })

        return new Response(JSON.stringify({ secure_url: result.secure_url }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })

    } catch (error: any) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 500,
        })
    }
})
