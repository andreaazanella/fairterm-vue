<template>
  <div class="language-section" :style="{ borderLeft: `3px solid ${badgeColor}` }">
    <div class="language-section__header" @click="expanded = !expanded">
      <span class="lang-badge" :style="{ background: badgeColor }">{{ language.language.slice(0, 2) }}</span>
      <span class="language-section__name">{{ languageName(language.language) }}</span>
      <span class="language-section__count">
        {{ language.terms.length }} {{ language.terms.length === 1 ? 'term' : 'terms' }}
      </span>
      <button
        type="button"
        class="language-section__edit"
        @click.stop="$emit('edit-request', language)"
        aria-label="Edit language"
      >
        <svg xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 -960 960 960" width="18px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
      </button>
      <button
        type="button"
        class="language-section__delete"
        @click.stop="handleDelete"
        aria-label="Delete language"
      >
        <svg xmlns="http://www.w3.org/2000/svg" height="18px" viewBox="0 -960 960 960" width="18px" fill="currentColor"><path d="M280-120q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520ZM360-280h80v-360h-80v360Zm160 0h80v-360h-80v360ZM280-720v520-520Z"/></svg>
      </button>
      <svg v-if="!expanded" xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-344 240-584l56-56 184 184 184-184 56 56-240 240Z"/></svg>
      <svg v-else xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z"/></svg>
    </div>

    <div v-if="expanded" class="language-section__body">
      <div class="field">
        <label>Definition</label>
        <div class="tag-list">
          <span class="tag" :class="{ 'tag--muted': !language.definition }">
            {{ language.definition || 'None' }}
          </span>
        </div>
      </div>

      <div class="language-details-grid">
        <div class="field">
          <label>External cross reference</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !language.externalCrossReference }">
              {{ language.externalCrossReference || 'None' }}
            </span>
          </div>
        </div>

        <div class="field">
          <label>Source</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !language.source }">
              {{ language.source || 'None' }}
            </span>
          </div>
        </div>

        <div class="field">
          <label>Notes</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !language.notes }">
              {{ language.notes || 'None' }}
            </span>
          </div>
        </div>
      </div>

      <hr class="card__divider" />

      <div class="card__header card__header--split">
        <div class="card__header-main">
          <div class="card__header-icon" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor"><path d="M480-80 240-220v-280L40-620l440-260 440 260v360h-80v-315l-80 47v280L480-80Zm0-360 278-164-278-164-278 164 278 164Zm0 274 160-94v-188l-160 94-160-94v188l160 94Z"/></svg>
          </div>
          <div>
            <h2>Terms ({{ language.terms.length }})</h2>
            <p class="card__subtitle">Terms available in this language</p>
          </div>
        </div>
        <button type="button" class="btn btn--ghost btn--sm" @click="$emit('add-term-request', language.language)">
          <svg xmlns="http://www.w3.org/2000/svg" height="16px" viewBox="0 -960 960 960" width="16px" fill="currentColor"><path d="M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z"/></svg>
          Add term
        </button>
      </div>

      <p v-if="language.terms.length === 0" class="placeholder-note">No terms added yet.</p>

      <TermCard
        v-for="term in language.terms"
        :key="term.id"
        :term="term"
        @edit-request="$emit('edit-term-request', { term: $event, languageCode: language.language })"
        @delete-request="$emit('delete-term-request', { term: $event, languageCode: language.language })"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useReferenceData } from '../../composables/useReferenceData'
import TermCard from './TermCard.vue'

const props = defineProps({
  language: { type: Object, required: true },
})

const emit = defineEmits(['edit-request', 'add-term-request', 'edit-term-request', 'delete-language-request', 'delete-term-request'])

function handleDelete() {
  const termCount = props.language.terms.length
  const message = termCount > 0
    ? `Delete this language? This will also delete its ${termCount} term${termCount === 1 ? '' : 's'}. This can't be undone.`
    : `Delete this language? This can't be undone.`

  if (window.confirm(message)) {
    emit('delete-language-request', props.language.language)
  }
}

const { languageName, load } = useReferenceData()
load()

const expanded = ref(false)

// colore del badge derivato dal codice lingua, così non serve una mappatura
// manuale per le 183 lingue disponibili nel DB — solo deterministico, non
// scelto a mano per ogni lingua.
const badgePalette = ['#C2593F', '#2E5A44', '#3B5BA5', '#8C4A9C', '#B8862E', '#4A8C82']

const badgeColor = computed(() => {
  const sum = [...props.language.language].reduce((acc, ch) => acc + ch.charCodeAt(0), 0)
  return badgePalette[sum % badgePalette.length]
})
</script>