<script lang="ts">
  import { supabase } from "../../services/supabase";
  import { onMount } from "svelte";
  import { fade, slide } from "svelte/transition";
  import {
    BarChart3,
    Store,
    Clock,
    FileText,
    Settings,
    Check,
    X,
    ShoppingBag,
    Eye,
    TrendingUp,
    Users,
  } from "lucide-svelte";

  // Shared Components
  // Shared Components
  import DashboardLayout from "../../components/layouts/DashboardLayout.svelte";

  // Feature Components
  import AdminStats from "./AdminStats.svelte";
  import AdminShops from "./AdminShops.svelte";
  import AdminBlog from "./AdminBlog.svelte";
  import AdminSettings from "./AdminSettings.svelte";
  import AdminUsers from "./AdminUsers.svelte";

  let activeView = "stats";
  let sidebarOpen = false;
  let shops: any[] = [];
  let loading = true;

  $: menuItems = [
    { id: "stats", label: "Dashboard", icon: BarChart3, badge: null },
    {
      id: "pending",
      label: "Verifikasi Toko",
      icon: Clock,
      badge: shops.length,
    },
    { id: "shops", label: "Semua Toko", icon: Store, badge: null },
    { id: "users", label: "Pengguna", icon: Users, badge: null },
    { id: "blog", label: "Blog & Artikel", icon: FileText, badge: null },
    { id: "settings", label: "Pengaturan", icon: Settings, badge: null },
  ];

  onMount(() => {
    fetchPendingShops();
  });

  async function fetchPendingShops() {
    loading = true;
    const { data } = await supabase
      .from("shops")
      .select("*")
      .eq("is_verified", false)
      .order("created_at", { ascending: false });
    shops = data || [];
    loading = false;
  }

  async function handleApprove(shop: any) {
    const confirmApprove = confirm(`Setujui toko ${shop.name}?`);
    if (!confirmApprove) return;

    const { error: shopError } = await supabase
      .from("shops")
      .update({ is_verified: true, is_active: true })
      .eq("id", shop.id);

    if (shopError) {
      alert("Error approving shop: " + shopError.message);
      return;
    }

    const { error: roleError } = await supabase
      .from("user_profiles")
      .update({ role: "shop" })
      .eq("id", shop.owner_id);

    if (roleError) {
      alert("Error updating role: " + roleError.message);
    } else {
      showToast("success", "Toko berhasil disetujui!");
      fetchPendingShops();
    }
  }

  async function handleReject(shop: any) {
    const confirmReject = confirm(`Tolak pengajuan ${shop.name}?`);
    if (!confirmReject) return;

    const { error } = await supabase.from("shops").delete().eq("id", shop.id);

    if (error) {
      alert("Error rejecting shop: " + error.message);
    } else {
      showToast("info", "Pengajuan ditolak");
      fetchPendingShops();
    }
  }

  async function handleLogout() {
    await supabase.auth.signOut();
  }

  // Simple toast notification
  let toasts: Array<{ id: number; type: string; message: string }> = [];
  let toastId = 0;

  function showToast(type: "success" | "error" | "info", message: string) {
    const id = toastId++;
    toasts = [...toasts, { id, type, message }];
    setTimeout(() => {
      toasts = toasts.filter((t) => t.id !== id);
    }, 3000);
  }
</script>

<DashboardLayout
  title="Admin Panel"
  activeTab={activeView}
  {menuItems}
  {sidebarOpen}
  profile={{ role: "Super Admin" }}
  on:tabChange={(e) => {
    activeView = e.detail;
    if (activeView === "pending") fetchPendingShops();
  }}
  on:logout={handleLogout}
  on:toggleSidebar={() => (sidebarOpen = !sidebarOpen)}
  on:closeSidebar={() => (sidebarOpen = false)}
>
  <div class="max-w-7xl mx-auto">
    {#if activeView === "stats"}
      <div class="space-y-6">
        <AdminStats />
      </div>
    {:else if activeView === "pending"}
      <div class="space-y-4">
        {#if loading}
          <div
            class="bg-white rounded-xl p-12 border border-gray-200 text-center"
          >
            <div
              class="animate-spin w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full mx-auto mb-4"
            ></div>
            <p class="text-gray-500">Memuat pengajuan...</p>
          </div>
        {:else if shops.length === 0}
          <div
            class="bg-white rounded-xl p-12 border border-gray-200 text-center"
          >
            <Clock class="mx-auto text-gray-300 mb-4" size={64} />
            <h3 class="text-xl font-bold text-gray-900 mb-2">
              Tidak Ada Pengajuan
            </h3>
            <p class="text-gray-500">Semua pengajuan toko sudah diproses</p>
          </div>
        {:else}
          <div
            class="bg-white rounded-xl border border-gray-200 overflow-hidden"
          >
            <div class="overflow-x-auto">
              <table class="w-full text-left border-collapse">
                <thead class="bg-gray-50 border-b border-gray-200">
                  <tr>
                    <th
                      class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                      >Nama Toko</th
                    >
                    <th
                      class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                      >Lokasi</th
                    >
                    <th
                      class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                      >WhatsApp</th
                    >
                    <th
                      class="px-6 py-4 text-xs font-semibold text-gray-600 uppercase tracking-wider"
                      >Jam Operasional</th
                    >
                    <th
                      class="px-6 py-4 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                      >Aksi</th
                    >
                  </tr>
                </thead>
                <tbody class="divide-y divide-gray-200">
                  {#each shops as shop}
                    <tr class="hover:bg-gray-50 transition-colors">
                      <td class="px-6 py-4 font-semibold text-gray-900"
                        >{shop.name}</td
                      >
                      <td class="px-6 py-4 text-sm text-gray-600"
                        >{shop.address || "-"}</td
                      >
                      <td class="px-6 py-4 text-sm text-gray-900"
                        >{shop.whatsapp}</td
                      >
                      <td class="px-6 py-4 text-sm text-gray-600">
                        {#if shop.open_time && shop.close_time}
                          {shop.open_time} - {shop.close_time}
                        {:else}
                          -
                        {/if}
                      </td>
                      <td class="px-6 py-4 text-right">
                        <div class="flex items-center justify-end gap-2">
                          <button
                            on:click={() => handleApprove(shop)}
                            class="flex items-center gap-2 px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white rounded-md font-medium text-xs transition-colors shadow-sm"
                          >
                            <Check size={14} /> Setujui
                          </button>
                          <button
                            on:click={() => handleReject(shop)}
                            class="flex items-center gap-2 px-3 py-1.5 bg-white hover:bg-red-50 text-red-600 border border-red-200 rounded-md font-medium text-xs transition-colors"
                          >
                            <X size={14} /> Tolak
                          </button>
                        </div>
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          </div>
        {/if}
      </div>
    {:else if activeView === "shops"}
      <AdminShops />
    {:else if activeView === "users"}
      <AdminUsers />
    {:else if activeView === "blog"}
      <AdminBlog />
    {:else if activeView === "settings"}
      <AdminSettings />
    {/if}
  </div>
</DashboardLayout>

<!-- Toast Notifications -->
{#if toasts.length > 0}
  <div class="fixed bottom-4 right-4 z-50 space-y-2">
    {#each toasts as toast (toast.id)}
      <div
        class="px-4 py-3 rounded-lg shadow-lg border flex items-center gap-3 min-w-[300px] {toast.type ===
        'success'
          ? 'bg-green-50 border-green-200 text-green-800'
          : toast.type === 'error'
            ? 'bg-red-50 border-red-200 text-red-800'
            : 'bg-blue-50 border-blue-200 text-blue-800'}"
        transition:slide={{ duration: 200 }}
      >
        <div class="flex-1 font-medium text-sm">{toast.message}</div>
        <button
          on:click={() => (toasts = toasts.filter((t) => t.id !== toast.id))}
          class="text-gray-400 hover:text-gray-600"
        >
          <X size={16} />
        </button>
      </div>
    {/each}
  </div>
{/if}

<style>
  /* Custom scrollbar */
  :global(.overflow-y-auto::-webkit-scrollbar) {
    width: 6px;
  }

  :global(.overflow-y-auto::-webkit-scrollbar-track) {
    background: transparent;
  }

  :global(.overflow-y-auto::-webkit-scrollbar-thumb) {
    background: #cbd5e1;
    border-radius: 3px;
  }

  :global(.overflow-y-auto::-webkit-scrollbar-thumb:hover) {
    background: #94a3b8;
  }
</style>
