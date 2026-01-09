<script lang="ts">
  export let message = "Tidak ada data.";
  export let icon = "📄";
  export let actionLabel: string | undefined = undefined;
  export let onAction: (() => void) | undefined = undefined;
</script>

<div class="text-center p-12 border border-dashed border-gray-200 rounded-lg">
  <div class="text-4xl mb-4">{icon}</div>
  <p class="text-gray-500 mb-4">{message}</p>
  {#if actionLabel && onAction}
    <button
      on:click={onAction}
      class="px-4 py-2 bg-primary text-white rounded-lg text-sm font-medium hover:bg-primary/90 transition-colors"
    >
      {actionLabel}
    </button>
  {/if}
</div>
