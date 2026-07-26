<template>
  <div class="app-shell">
    <Sidebar />
    <main class="app-main">
      <RouterView />
    </main>
  </div>
</template>

<script setup>
import { RouterView } from 'vue-router'
import Sidebar from './components/layout/Sidebar.vue'
</script>

<style scoped>
.app-shell {
  min-height: 100vh;
}

.app-main {
  margin-left: var(--sidebar-width);
  min-height: 100vh;
}
</style>
