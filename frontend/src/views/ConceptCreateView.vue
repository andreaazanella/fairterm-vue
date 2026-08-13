<template>
  <div class="page">
    <header class="page-header">
      <!-- Breadcrumb di navigazione -->
      <nav class="breadcrumb">
        <RouterLink to="/concepts">Concepts</RouterLink>
        <span>></span>
        <span class="breadcrumb__current">New Concept</span>
      </nav>
    </header>

    <hr class="page__divider" />

    <div class="title-row">
      <h1 class="concept-title">New Concept</h1>
      <div class="page-header__actions">
        <!-- Bottone annulla -->
        <RouterLink to="/concepts" class="btn btn--ghost">Cancel</RouterLink>
        <!-- Bottone salva -->
        <button class="btn btn--primary" :disabled="saving" @click="handleSave">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M840-680v480q0 33-23.5 56.5T760-120H200q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h480l160 160Zm-80 34L646-760H200v560h560v-446ZM565-275q35-35 35-85t-35-85q-35-35-85-35t-85 35q-35 35-35 85t35 85q35 35 85 35t85-35ZM240-560h360v-160H240v160Zm-40-86v446-560 114Z"/></svg>
          {{ saving ? 'Saving...' : 'Save Concept' }}
        </button>
      </div>
    </div>

    <!-- Messaggio di errore -->
    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <!-- Card: informazioni concetto + relazioni concettuali -->
    <section class="card">
      <div class="card__header card__header--split">
        <div class="card__header-main">
          <!-- Icona -->
          <div class="card__header-icon" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
              <path d="M491-339q70 0 119-45t49-109q0-57-36.5-96.5T534-629q-47 0-79.5 30T422-525q0 19 7.5 37t21.5 33l57-57q-3-2-4.5-5t-1.5-7q0-11 9-17.5t23-6.5q20 0 33 16.5t13 39.5q0 31-25.5 52.5T492-418q-47 0-79.5-38T380-549q0-29 11-55.5t31-46.5l-57-57q-32 31-49 72t-17 86q0 88 56 149.5T491-339ZM240-80v-172q-57-52-88.5-121.5T120-520q0-150 105-255t255-105q125 0 221.5 73.5T827-615l52 205q5 19-7 34.5T840-360h-80v120q0 33-23.5 56.5T680-160h-80v80h-80v-160h160v-200h108l-38-155q-23-91-98-148t-172-57q-116 0-198 81t-82 197q0 60 24.5 114t69.5 96l26 24v208h-80Zm254-360Z"/>
            </svg>
          </div>
          <!-- Titolo e sottotitolo -->
          <div>
            <h2>Concept information</h2>
            <p class="card__subtitle">Define the general context of the concept</p>
          </div>
        </div>
        <!-- Bottone mostra/nascondi relazioni -->
        <button type="button" class="btn btn--ghost btn--sm" @click="showRelations = !showRelations">
          {{ showRelations ? 'Hide details' : 'Show details' }}
          <svg v-if="!showRelations" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-344 240-584l56-56 184 184 184-184 56 56-240 240Z"/></svg>
          <svg v-else xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z"/></svg>
        </button>
      </div>

      <!-- Subject field -->
      <div class="field">
        <label>Subject field <span class="required">*</span></label>
        <MultiSelect
          v-model="form.subjectFields"
          :options="subjectFieldOptions"
          placeholder="Select one or more subject fields"
        />
      </div>

      <!-- Subdomain -->
      <div class="field">
        <label>Subdomain</label>
        <input type="text" v-model="form.subdomain" placeholder="Enter the subdomain (optional)" />
      </div>

      <!-- Relazioni concettuali, visibili solo se "Show details" è attivo -->
      <template v-if="showRelations">
        <hr class="card__divider" />

        <div class="card__header">
          <!-- Icona -->
          <div class="card__header-icon" aria-hidden="true">
            <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
              <path d="M121-121q-41-41-41-99t41-99q41-41 99-41 18 0 35 4.5t32 12.5l153-153v-110q-44-13-72-49.5T340-740q0-58 41-99t99-41q58 0 99 41t41 99q0 48-28 84.5T520-606v110l154 153q15-8 31.5-12.5T740-360q58 0 99 41t41 99q0 58-41 99t-99 41q-58 0-99-41t-41-99q0-18 4.5-35t12.5-32L480-424 343-287q8 15 12.5 32t4.5 35q0 58-41 99t-99 41q-58 0-99-41Zm661.5-56.5Q800-195 800-220t-17.5-42.5Q765-280 740-280t-42.5 17.5Q680-245 680-220t17.5 42.5Q715-160 740-160t42.5-17.5Zm-260-520Q540-715 540-740t-17.5-42.5Q505-800 480-800t-42.5 17.5Q420-765 420-740t17.5 42.5Q455-680 480-680t42.5-17.5Zm-260 520Q280-195 280-220t-17.5-42.5Q245-280 220-280t-42.5 17.5Q160-245 160-220t17.5 42.5Q195-160 220-160t42.5-17.5Z"/>
            </svg>
          </div>
          <!-- Titolo e sottotitolo -->
          <div>
            <h2>Concept relations</h2>
            <p class="card__subtitle">Link this concept to other existing concepts</p>
          </div>
        </div>

        <div class="relations-grid">
          <!-- Superordinate -->
          <div class="field">
            <label>Superordinate</label>
            <select class="dropdown" v-model="form.relations.superordinate" required>
              <option value="">Select a concept</option>
              <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
                {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
              </option>
            </select>
          </div>

          <!-- Subordinate -->
          <div class="field">
            <label>Subordinate</label>
            <select class="dropdown" v-model="form.relations.subordinate" required>
              <option value="">Select a concept</option>
              <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
                {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
              </option>
            </select>
          </div>

          <!-- Comprehensive -->
          <div class="field">
            <label>Comprehensive</label>
            <select class="dropdown"v-model="form.relations.comprehensive" required>
              <option value="">Select a concept</option>
              <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
                {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
              </option>
            </select>
          </div>

          <!-- Partitive -->
          <div class="field">
            <label>Partitive</label>
            <select class="dropdown" v-model="form.relations.partitive" required>
              <option value="">Select a concept</option>
              <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
                {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
              </option>
            </select>
          </div>
        </div>
      </template>
    </section>
  </div>
</template>

<script setup>
import { reactive, ref, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { RouterLink } from 'vue-router'
import MultiSelect from '../components/ui/MultiSelect.vue'
import { useReferenceData } from '../composables/useReferenceData'
import { listConcepts, createConcept } from '../services/concepts'

const router = useRouter()
const { subjectFields, load } = useReferenceData()
load()

const subjectFieldOptions = computed(() => subjectFields.value)

const showRelations = ref(false)

const form = reactive({
  subjectFields: [],
  subdomain: '',
  relations: {
    superordinate: '',
    subordinate: '',
    comprehensive: '',
    partitive: '',
  },
})

const relationCandidates = ref([])
const errorMessage = ref('')
const saving = ref(false)

// Ogni volta che cambia la selezione dei subject field, ricarica la lista di
// concetti candidati per le relazioni (uno per ogni subject field selezionato,
// poi uniti e deduplicati per id — un concetto può comparire in più domini)
watch(
  () => form.subjectFields,
  async (fields) => {
    if (fields.length === 0) {
      relationCandidates.value = []
      return
    }
    const results = await Promise.all(fields.map(listConcepts))
    const merged = new Map()
    results.flat().forEach((concept) => merged.set(concept.id, concept))
    relationCandidates.value = Array.from(merged.values())
  },
  { deep: true }
)

// Valida il form, invia solo le relazioni effettivamente valorizzate, crea il
// concetto e naviga alla sua pagina di dettaglio
async function handleSave() {
  errorMessage.value = ''

  if (form.subjectFields.length === 0) {
    errorMessage.value = 'Select at least one subject field.'
    return
  }

  saving.value = true
  try {
    const relations = {}
    for (const key of ['superordinate', 'subordinate', 'comprehensive', 'partitive']) {
      if (form.relations[key]) relations[key] = form.relations[key]
    }

    const created = await createConcept({
      subjectFields: form.subjectFields,
      subdomain: form.subdomain || null,
      relations,
    })

    router.push(`/concepts/${created.id}`)
  } catch (err) {
    errorMessage.value = 'Failed to save the concept. Please try again.'
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>