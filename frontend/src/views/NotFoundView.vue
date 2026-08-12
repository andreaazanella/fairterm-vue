<template>
  <div class="page">
    <!-- Stesso pattern visivo di "Concept not found" in ConceptDetailView -->
    <div class="page-state">
      <p>Page not found.</p>
      <RouterLink to="/concepts" class="btn btn--ghost">Back to Concepts</RouterLink>
    </div>
  </div>
</template>

<script setup>
import { RouterLink } from 'vue-router'
</script>