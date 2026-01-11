<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";
  import { toasts } from "../../stores/toastStore";
  import { CheckCircle2, XCircle, Clock, Package } from "lucide-svelte";

  export let shopId: string | null = null;

  let orders: any[] = [];
  let loading = true;

  onMount(() => {
    if (shopId) fetchOrders();
  });

  $: if (shopId) {
    fetchOrders();
  } else {
    orders = [];
  }

  async function fetchOrders() {
    loading = true;
    let query = supabase
      .from("order_history")
      .select("*")
      .order("created_at", { ascending: false });

    if (shopId) {
      query = query.eq("shop_id", shopId);
    }

    const { data, error } = await query;
    if (error) {
      toasts.error("Gagal mengambil data pesanan");
    } else {
      orders = data || [];
    }
    loading = false;
  }

  async function updateStatus(orderId: string, status: string) {
    const { error } = await supabase
      .from("order_history")
      .update({ status })
      .eq("id", orderId);

    if (error) {
      toasts.error("Gagal mengupdate status: " + error.message);
    } else {
      toasts.success(
        `Pesanan berhasil di-${status === "completed" ? "selesaikan" : "batalkan"}`,
      );
      fetchOrders();
    }
  }

  function formatItems(items: any[] | null) {
    if (!items || items.length === 0) return "Tidak ada item";
    return items
      .map((i: any) => `${i.qty || i.quantity || 1}x ${i.name}`)
      .join(", ");
  }

  const statusMap: Record<string, { label: string; color: string; icon: any }> =
    {
      sent_to_wa: {
        label: "Diproses",
        color: "bg-blue-100 text-blue-700 border-blue-200",
        icon: Clock,
      },
      completed: {
        label: "Selesai",
        color: "bg-green-100 text-green-700 border-green-200",
        icon: CheckCircle2,
      },
      cancelled: {
        label: "Batal",
        color: "bg-red-100 text-red-700 border-red-200",
        icon: XCircle,
      },
      pending: {
        label: "Pending",
        color: "bg-gray-100 text-gray-700 border-gray-200",
        icon: Clock,
      },
    };
</script>

<div class="space-y-4">
  {#if loading}
    <div class="flex justify-center p-8">
      <div
        class="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"
      ></div>
    </div>
  {:else if orders.length === 0}
    <div
      class="text-center p-8 border border-dashed border-gray-200 rounded-lg"
    >
      <p class="text-gray-500">Belum ada pesanan untuk toko ini.</p>
    </div>
  {:else}
    <div class="border rounded-lg overflow-hidden">
      <table class="w-full text-sm">
        <thead class="bg-gray-50/50 border-b">
          <tr>
            <th
              class="h-10 px-4 text-left align-middle font-medium text-muted-foreground w-[100px]"
              >Tanggal</th
            >
            <th
              class="h-10 px-4 text-left align-middle font-medium text-muted-foreground"
              >Item</th
            >
            <th
              class="h-10 px-4 text-left align-middle font-medium text-muted-foreground"
              >Total</th
            >
            <th
              class="h-10 px-4 text-left align-middle font-medium text-muted-foreground"
              >Status</th
            >
          </tr>
        </thead>
        <tbody>
          {#each orders as order}
            {@const status = statusMap[order.status] || statusMap["pending"]}
            <tr
              class="hover:bg-gray-50/50 border-b last:border-0 transition-colors"
            >
              <td class="p-4 align-middle text-gray-500">
                <div class="font-medium text-gray-900">
                  {new Date(order.created_at).toLocaleDateString("id-ID", {
                    day: "numeric",
                    month: "short",
                  })}
                </div>
                <div class="text-[10px]">
                  {new Date(order.created_at).toLocaleTimeString("id-ID", {
                    hour: "2-digit",
                    minute: "2-digit",
                  })}
                </div>
              </td>
              <td class="p-4 align-middle">
                <div class="font-medium text-gray-900">
                  <div class="text-xs text-gray-500 line-clamp-1">
                    {formatItems(order.items)}
                  </div>
                </div>
              </td>
              <td class="p-4 align-middle font-bold text-gray-900">
                Rp {order.total_price?.toLocaleString("id-ID") || 0}
              </td>
              <td class="p-4 align-middle">
                <div class="flex items-center gap-2">
                  <span
                    class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[10px] font-bold border uppercase tracking-wider {status.color}"
                  >
                    <svelte:component this={status.icon} size={10} />
                    {status.label}
                  </span>

                  {#if order.status === "sent_to_wa"}
                    <div class="flex gap-1 ml-auto">
                      <button
                        on:click={() => updateStatus(order.id, "completed")}
                        class="p-1.5 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                        title="Selesaikan"
                      >
                        <CheckCircle2 size={16} />
                      </button>
                      <button
                        on:click={() => updateStatus(order.id, "cancelled")}
                        class="p-1.5 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                        title="Batalkan"
                      >
                        <XCircle size={16} />
                      </button>
                    </div>
                  {/if}
                </div>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>
