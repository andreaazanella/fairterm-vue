<!--
  Multi-select senza dipendenze esterne. Riceve/emette un semplice array di
  stringhe (coerente con come subjectFields viaggia nel body delle API).
-->

<template>
  <div class="multiselect" ref="rootEl">

    <!-- Controllo principale: mostra placeholder o tag selezionati -->
    <div class="multiselect__control" tabindex="0" @click="open = !open" @keydown.enter="open = !open">
      <div class="multiselect__tags">
        <!-- Placeholder, visibile solo se non c'è nessuna selezione -->
        <span v-if="modelValue.length === 0" class="multiselect__placeholder">{{ placeholder }}</span>
        <!-- Valori selezionati, mostrati come tag rimovibili -->
        <span v-for="value in modelValue" :key="value" class="multiselect__tag">
          {{ displayLabel(value) }}
          <button type="button" class="multiselect__tag-remove" @click.stop="remove(value)" aria-label="Remove">×</button>
        </span>
      </div>
      <svg class="multiselect__chevron" viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 9l6 6 6-6" />
      </svg>
    </div>

    <!-- Dropdown con ricerca ed elenco opzioni -->
    <div v-if="open" class="multiselect__dropdown">
      <!-- Campo di ricerca, filtra le opzioni sotto -->
      <input
        type="search"
        class="multiselect__search"
        v-model="query"
        placeholder="Search..."
        @click.stop
      />
      <ul class="multiselect__options">
        <!-- Stato vuoto: nessuna opzione corrisponde alla ricerca -->
        <li v-if="filteredOptions.length === 0" class="multiselect__empty">No results found</li>
        <!-- Singola opzione, con checkbox visivo per lo stato selezionato -->
        <li
          v-for="option in filteredOptions"
          :key="option"
          class="multiselect__option"
          :class="{ 'multiselect__option--selected': modelValue.includes(option) }"
          @click="toggle(option)"
        >
          <span class="multiselect__checkbox" aria-hidden="true">
            <svg v-if="modelValue.includes(option)" viewBox="0 0 24 24" width="12" height="12" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20 6L9 17l-5-5" />
            </svg>
          </span>
          {{ displayLabel(option) }}
        </li>
      </ul>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const props = defineProps({
  modelValue: { type: Array, required: true },
  options: { type: Array, default: () => [] },
  placeholder: { type: String, default: 'Select...' },
  // Se true, mostra le opzioni con la prima lettera maiuscola (solo a schermo
  // il valore in modelValue resta quello grezzo passato in options)
  capitalize: { type: Boolean, default: false },
})

const emit = defineEmits(['update:modelValue'])

const open = ref(false)
const query = ref('')
const rootEl = ref(null)

// Filtra le opzioni in base alla query di ricerca
const filteredOptions = computed(() => {
  if (!query.value) return props.options
  const q = query.value.toLowerCase()
  return props.options.filter((option) => option.toLowerCase().includes(q))
})

// Aggiunge o rimuove un'opzione dall'array selezionato
function toggle(option) {
  const next = props.modelValue.includes(option)
    ? props.modelValue.filter((value) => value !== option)
    : [...props.modelValue, option]
  emit('update:modelValue', next)
}

// Rimuove un'opzione selezionata quando si clicca sulla "x" del tag
function remove(option) {
  emit('update:modelValue', props.modelValue.filter((value) => value !== option))
}

// Chiude il dropdown se si clicca fuori dal componente
function handleClickOutside(event) {
  if (rootEl.value && !rootEl.value.contains(event.target)) {
    open.value = false
  }
}

// Restituisce l'etichetta da mostrare a schermo, eventualmente con la prima lettera maiuscola
function displayLabel(option) {
  if (!props.capitalize) return option
  return option.charAt(0).toUpperCase() + option.slice(1)
}

onMounted(() => document.addEventListener('click', handleClickOutside))
onUnmounted(() => document.removeEventListener('click', handleClickOutside))
</script>

<style scoped>
.multiselect {
  position: relative;
}

.multiselect__control {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  min-height: 44px;
  padding: 6px 12px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  background: #fff;
  cursor: pointer;
}

.multiselect__control:focus {
  outline: 2px solid var(--color-accent);
  outline-offset: 1px;
}

.multiselect__tags {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  flex: 1;
}

.multiselect__placeholder {
  color: var(--color-muted);
  font-size: 14px;
  padding: 4px 0;
}

.multiselect__tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: var(--color-bg-subtle);
  border: 1px solid var(--color-border);
  border-radius: 6px;
  padding: 3px 6px 3px 10px;
  font-size: 13px;
}

.multiselect__tag-remove {
  border: none;
  background: none;
  cursor: pointer;
  font-size: 15px;
  line-height: 1;
  color: var(--color-muted);
  padding: 0 2px;
}

.multiselect__tag-remove:hover {
  color: var(--color-danger);
}

.multiselect__chevron {
  flex-shrink: 0;
  color: var(--color-muted);
}

.multiselect__dropdown {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  background: #fff;
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  box-shadow: 0 8px 24px rgba(43, 30, 23, 0.12);
  z-index: 20;
  max-height: 280px;
  display: flex;
  flex-direction: column;
}

.multiselect__search {
  margin: 8px;
  width: auto;
}

.multiselect__options {
  list-style: none;
  margin: 0;
  padding: 4px 0 8px;
  overflow-y: auto;
}

.multiselect__option {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px;
  font-size: 14px;
  cursor: pointer;
}

.multiselect__option:hover {
  background: var(--color-bg-subtle);
}

.multiselect__option--selected {
  font-weight: 600;
}

.multiselect__checkbox {
  width: 16px;
  height: 16px;
  border: 1px solid var(--color-border);
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  color: var(--color-accent);
}

.multiselect__empty {
  padding: 10px 14px;
  color: var(--color-muted);
  font-size: 13px;
}
</style>