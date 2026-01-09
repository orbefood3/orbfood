<script lang="ts">
  export let size = "8"; // Tailwind size classes like 4, 6, 8, 12
  export let color = "primary"; // primary, gray, blue, etc.
</script>

<div class="flex justify-center items-center p-4">
  <div
    class="animate-spin rounded-full h-{size} w-{size} border-b-2 border-{color}-600"
  ></div>
</div>