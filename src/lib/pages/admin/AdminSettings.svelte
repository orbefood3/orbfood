<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import PageWrapper from "../../components/ui/PageWrapper.svelte";

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

<PageWrapper>
  {#if loading}
    <div class="flex justify-center p-12">
      <div
        class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
      ></div>
    </div>
  {:else}
    <div class="max-w-3xl mx-auto space-y-6">
      <div class="space-y-2">
        <h2 class="text-2xl font-bold tracking-tight text-gray-900">
          Pengaturan Platform
        </h2>
        <p class="text-gray-500 text-sm">Kelola konfigurasi dasar aplikasi.</p>
      </div>

      <div
        class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden"
      >
        <div class="p-6 md:p-8 space-y-6">
          <div class="grid gap-5 md:grid-cols-2">
            <div class="grid gap-2 md:col-span-2">
              <label
                for="platform_name"
                class="text-sm font-semibold text-gray-700"
                >Nama Platform</label
              >
              <input
                id="platform_name"
                bind:value={settings.platform_name}
                class="h-11 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors"
                placeholder="Masukkan nama platform"
              />
            </div>

            <div class="grid gap-2">
              <label
                for="admin_whatsapp"
                class="text-sm font-semibold text-gray-700"
                >WhatsApp Admin</label
              >
              <input
                id="admin_whatsapp"
                bind:value={settings.admin_whatsapp}
                placeholder="628xxx"
                class="h-11 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors"
              />
              <p class="text-[0.8rem] text-gray-500">
                Nomor ini akan digunakan sebagai kontak bantuan utama.
              </p>
            </div>

            <div class="grid gap-2">
              <label
                for="platform_hours"
                class="text-sm font-semibold text-gray-700"
                >Jam Operasional Platform</label
              >
              <input
                id="platform_hours"
                bind:value={settings.platform_hours}
                class="h-11 w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors"
              />
            </div>

            <div class="grid gap-2 md:col-span-2">
              <label
                for="announcement_banner"
                class="text-sm font-semibold text-gray-700"
                >Banner Pengumuman (Opsional)</label
              >
              <textarea
                id="announcement_banner"
                bind:value={settings.announcement_banner}
                placeholder="Teks pengumuman yang muncul di aplikasi"
                class="min-h-[96px] w-full rounded-xl border border-gray-200 bg-white px-3 py-2 text-sm placeholder:text-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors"
              ></textarea>
            </div>
          </div>
        </div>
        <div class="flex items-center p-6 md:px-8 pt-0">
          <button
            on:click={saveSettings}
            class="inline-flex h-11 w-full items-center justify-center rounded-xl bg-gray-900 px-4 py-2 text-sm font-semibold text-white transition-colors hover:bg-gray-800 focus:outline-none focus:ring-2 focus:ring-gray-900/20"
          >
            Simpan Perubahan
          </button>
        </div>
      </div>
    </div>
  {/if}
</PageWrapper>
