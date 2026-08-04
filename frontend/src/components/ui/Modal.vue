<template>
  <div class="modal-overlay" @click.self="$emit('close-request')">
    <div class="modal-dialog" role="dialog" aria-modal="true">
      <slot />
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted } from 'vue'

const emit = defineEmits(['close-request'])

function handleKeydown(event) {
  if (event.key === 'Escape') emit('close-request')
}

onMounted(() => {
  document.addEventListener('keydown', handleKeydown)
  document.body.style.overflow = 'hidden'
})

onUnmounted(() => {
  document.removeEventListener('keydown', handleKeydown)
  document.body.style.overflow = ''
})
</script>