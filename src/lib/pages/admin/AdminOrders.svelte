<script lang="ts">
  import { onMount } from "svelte";
  import { supabase } from "../../services/supabase";

  export let shopId: string | null = null;

  let orders: any[] = [];
  let loading = true;

  $: if (shopId) {
    fetchOrders();
  } else if (!shopId) {
    // If used without shopId, maybe show recent orders or nothing?
    // User requested to hide global orders, so we might just wait for shopId.
    orders = [];
    loading = false;
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

    const { data } = await query;
    orders = data || [];
    loading = false;
  }
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
            <tr
              class="hover:bg-muted/50 border-b last:border-0 transition-colors"
            >
              <td class="p-4 align-middle">
                {new Date(order.created_at).toLocaleDateString("id-ID", {
                  day: "numeric",
                  month: "short",
                })}
              </td>
              <td class="p-4 align-middle">
                {order.items
                  ?.map((i) => `${i.quantity}x ${i.name}`)
                  .join(", ") || "Order items"}
              </td>
              <td class="p-4 align-middle font-medium">
                Rp {order.total_price?.toLocaleString("id-ID") || 0}
              </td>
              <td class="p-4 align-middle">
                <span
                  class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold
                  {order.status === 'completed'
                    ? 'border-transparent bg-green-100 text-green-800'
                    : order.status === 'cancelled'
                      ? 'border-transparent bg-red-100 text-red-800'
                      : 'border-transparent bg-blue-100 text-blue-800'}"
                >
                  {order.status || "Pending"}
                </span>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>
