<template>
  <div class="term-card" :style="{ borderLeft: `3px solid ${usageColor}` }">
    <!-- Header cliccabile: designation, badge usage, azioni, freccia espandi -->
    <div class="term-card__header" @click="expanded = !expanded">
      <span class="term-card__designation">{{ term.designation }}</span>
      <span v-if="term.usage" class="usage-badge" :class="usageBadgeClass">{{ usageLabel }}</span>
      <span class="term-card__spacer"></span>
      <!-- Bottone modifica -->
      <button type="button" class="term-card__edit" @click.stop="$emit('edit-request', term)" aria-label="Edit term">
        <svg xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 -960 960 960" width="18px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
      </button>
      <!-- Bottone elimina -->
      <button type="button" class="term-card__delete" @click.stop="handleDelete" aria-label="Delete term">
        <svg xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 -960 960 960" width="18px" fill="currentColor"><path d="M280-120q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520ZM360-280h80v-360h-80v360Zm160 0h80v-360h-80v360ZM280-720v520-520Z"/></svg>
      </button>
      <!-- Freccia espandi/comprimi -->
      <svg v-if="!expanded" xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-344 240-584l56-56 184 184 184-184 56 56-240 240Z"/></svg>
      <svg v-else xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z"/></svg>
    </div>

    <!-- Corpo espanso: tutti i dettagli del termine, in sola lettura -->
    <div v-if="expanded" class="term-card__body">
      <!-- Part of speech, gender, number, type -->
      <div class="relations-grid">
        <div class="field">
          <label>Part of speech</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.partOfSpeech }">
              {{ term.partOfSpeech ? posLabel(term.partOfSpeech) : 'None' }}
            </span>
          </div>
        </div>
        <div class="field">
          <label>Grammatical gender</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.grammaticalGender }">
              {{ term.grammaticalGender ? genderLabel(term.grammaticalGender) : 'None' }}
            </span>
          </div>
        </div>
        <div class="field">
          <label>Grammatical number</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.grammaticalNumber }">
              {{ term.grammaticalNumber ? numberLabel(term.grammaticalNumber) : 'None' }}
            </span>
          </div>
        </div>
        <div class="field">
          <label>Type</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.type }">{{ term.type || 'None' }}</span>
          </div>
        </div>
      </div>

      <!-- Context -->
      <div class="field">
        <label>Context</label>
        <div class="tag-list">
          <span class="tag" :class="{ 'tag--muted': !term.context }">{{ term.context || 'None' }}</span>
        </div>
      </div>

      <!-- External cross reference e Source -->
      <div class="relations-grid">
        <div class="field">
          <label>External cross reference</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.externalCrossReference }">{{ term.externalCrossReference || 'None' }}</span>
          </div>
        </div>
        <div class="field">
          <label>Source</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.source }">{{ term.source || 'None' }}</span>
          </div>
        </div>
      </div>

      <!-- Register e Collocation -->
      <div class="relations-grid">
        <div class="field">
          <label>Register</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.register }">{{ term.register || 'None' }}</span>
          </div>
        </div>
        <div class="field">
          <label>Collocation</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !term.collocation }">{{ term.collocation || 'None' }}</span>
          </div>
        </div>
      </div>

      <!-- Notes -->
      <div class="field">
        <label>Notes</label>
        <div class="tag-list">
          <span class="tag" :class="{ 'tag--muted': !term.notes }">{{ term.notes || 'None' }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useReferenceData } from '../../composables/useReferenceData'

const props = defineProps({
  term: { type: Object, required: true },
})

const emit = defineEmits(['edit-request', 'delete-request'])

const { posLabel, genderLabel, numberLabel, load } = useReferenceData()
load()

const expanded = ref(false)

// usage arriva come "preferred term"/"admitted term"/ecc.: nel badge viene mostrata
// solo la prima parola, il valore inviato all'API resta invariato.
const usageBadgeClass = computed(() => {
  if (!props.term.usage) return ''
  const key = props.term.usage.split(' ')[0]
  return `usage-badge--${key}`
})

const usageLabel = computed(() => {
  if (!props.term.usage) return ''
  const word = props.term.usage.split(' ')[0]
  return word.charAt(0).toUpperCase() + word.slice(1)
})

// Bordo sinistro colorato in base allo status, stesso principio del bordo
// per lingua in LanguageSection ma qui la mappatura è curata (solo 4 valori
// possibili, non 183 lingue) invece che calcolata da un hash.
const usageColors = {
  'preferred term': '#2E5A44',
  'admitted term': '#8C7A6B',
  'deprecated term': '#B8862E',
  'obsolete term': '#A69C8F',
}

const usageColor = computed(() => usageColors[props.term.usage] || 'var(--color-border)')

// Chiede conferma prima di emettere la richiesta di eliminazione
function handleDelete() {
  if (window.confirm(`Delete the term "${props.term.designation}"? This can't be undone.`)) {
    emit('delete-request', props.term)
  }
}
</script>