<template>
  <!-- Overlay: click fuori dal dialog chiude il modale -->
  <div class="modal-overlay" @click.self="$emit('close-request')">
    <!-- Contenuto del modale, fornito da chi lo usa tramite slot -->
    <div class="modal-dialog" role="dialog" aria-modal="true">
      <slot />
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['close-request'])

// Esc chiude il modale, come il click sull'overlay
function handleKeydown(event) {
  if (event.key === 'Escape') emit('close-request')
}

// Blocca lo scroll della pagina sotto mentre il modale è aperto
onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
  document.body.style.overflow = 'hidden'
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
  document.body.style.overflow = ''
})
</script>