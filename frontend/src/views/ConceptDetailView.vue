<template>
  <div class="page">
    <header class="page-header">
      <h1>Concept {{ id }}</h1>
    </header>
    <p class="placeholder-note">Detail view not yet implemented — it will arrive in the next step.</p>
  </div>
</template>

<script setup>
defineProps({ id: { type: String, required: true } })
</script>