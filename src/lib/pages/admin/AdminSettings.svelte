<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";

  let settings: any = {
    platform_name: "OrbFood",
    admin_whatsapp: "",
    platform_hours: "08.00 - 20.00",
    announcement_banner: "",
  };
  let loading = true;

  onMount(fetchSettings);

  async function fetchSettings() {
    loading = true;
    const { data } = await supabase
      .from("platform_settings")
      .select("*")
      .single();

    if (data) settings = data;
    loading = false;
  }

  async function saveSettings() {
    const { error } = await supabase
      .from("platform_settings")
      .upsert({ id: 1, ...settings });

    if (error) {
      alert("Error saving settings: " + error.message);
    } else {
      alert("Pengaturan disimpan!");
    }
  }
</script>

<div class="content-padding">
  {#if loading}
    <div class="flex justify-center p-12">
      <div
        class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
      ></div>
    </div>
  {:else}
    <div class="max-w-2xl mx-auto space-y-6">
      <div class="space-y-2">
        <h2 class="text-2xl font-bold tracking-tight text-gray-900">
          Pengaturan Platform
        </h2>
        <p class="text-gray-500 text-sm">Kelola konfigurasi dasar aplikasi.</p>
      </div>

      <div
        class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden"
      >
        <div class="p-6 space-y-6">
          <div class="space-y-4">
            <div class="grid gap-2">
              <label
                for="platform_name"
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >Nama Platform</label
              >
              <input
                id="platform_name"
                bind:value={settings.platform_name}
                class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                placeholder="Masukkan nama platform"
              />
            </div>

            <div class="grid gap-2">
              <label
                for="admin_whatsapp"
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >WhatsApp Admin</label
              >
              <input
                id="admin_whatsapp"
                bind:value={settings.admin_whatsapp}
                placeholder="628xxx"
                class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              />
              <p class="text-[0.8rem] text-gray-500">
                Nomor ini akan digunakan sebagai kontak bantuan utama.
              </p>
            </div>

            <div class="grid gap-2">
              <label
                for="platform_hours"
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >Jam Operasional Platform</label
              >
              <input
                id="platform_hours"
                bind:value={settings.platform_hours}
                class="flex h-10 w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              />
            </div>

            <div class="grid gap-2">
              <label
                for="announcement_banner"
                class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
                >Banner Pengumuman (Opsional)</label
              >
              <textarea
                id="announcement_banner"
                bind:value={settings.announcement_banner}
                placeholder="Teks pengumuman yang muncul di aplikasi"
                class="flex min-h-[80px] w-full rounded-md border border-gray-200 bg-white px-3 py-2 text-sm ring-offset-white placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              ></textarea>
            </div>
          </div>
        </div>
        <div class="flex items-center p-6 pt-0">
          <button
            on:click={saveSettings}
            class="inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-white transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-gray-950 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-gray-900 text-gray-50 hover:bg-gray-900/90 h-10 px-4 py-2 w-full"
          >
            Simpan Perubahan
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>

<style>
  .content-padding {
    padding: 24px;
    max-width: 1280px;
    margin: 0 auto;
  }
</style>
