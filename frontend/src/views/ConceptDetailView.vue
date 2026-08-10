<template>
  <div class="page">

    <!-- Stato di caricamento -->
    <div v-if="loading" class="page-state">
      <div class="page-state__spinner" aria-hidden="true"></div>
      <p>Loading concept...</p>
    </div>

    <!-- Concetto non trovato -->
    <div v-else-if="notFound" class="page-state">
      <p>Concept not found.</p>
      <RouterLink to="/concepts" class="btn btn--ghost">Back to Concepts</RouterLink>
    </div>

    <!-- Dettaglio del concetto -->
    <template v-else-if="concept">
      <header class="page-header">
        <!-- Breadcrumb di navigazione -->
        <nav class="breadcrumb">
          <RouterLink to="/concepts">Concepts</RouterLink>
          <span>></span>
          <span class="breadcrumb__current">Concept: {{ concept.id }}</span>
        </nav>
      </header>

      <hr class="page__divider" />

      <div class="title-row">
        <h1 class="concept-title">Concept: {{ concept.id }}</h1>
        <div class="page-header__actions">
          <!-- Bottone modifica -->
          <button type="button" class="btn btn--primary" @click="showEditModal = true">
            <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
            Edit concept
          </button>

          <!-- Bottone elimina -->
          <button type="button" class="btn btn--danger" @click="handleDeleteConcept">
            <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M280-120q-33 0-56.5-23.5T200-200v-520h-40v-80h200v-40h240v40h200v80h-40v520q0 33-23.5 56.5T680-120H280Zm400-600H280v520h400v-520ZM360-280h80v-360h-80v360Zm160 0h80v-360h-80v360ZM280-720v520-520Z"/></svg>
            Delete concept
          </button>
        </div>
      </div>

      <!-- Card: informazioni generali + relazioni concettuali -->
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
          <button type="button" class="btn btn--ghost btn--sm" @click="showDetails = !showDetails">
            {{ showDetails ? 'Hide details' : 'Show details' }}
            <svg v-if="!showDetails" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-344 240-584l56-56 184 184 184-184 56 56-240 240Z"/></svg>
            <svg v-else xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-528 296-344l-56-56 240-240 240 240-56 56-184-184Z"/></svg>
          </button>
        </div>

        <!-- Subject field -->
        <div class="field">
          <label>Subject field</label>
          <div class="tag-list">
            <span v-for="field in concept.subjectFields" :key="field" class="tag">{{ field }}</span>
          </div>
        </div>

        <!-- Subdomain -->
        <div class="field">
          <label>Subdomain</label>
          <div class="tag-list">
            <span class="tag" :class="{ 'tag--muted': !concept.subdomain }">
              {{ concept.subdomain || 'No subdomain' }}
            </span>
          </div>
        </div>

        <!-- Relazioni concettuali, visibili solo se "Show details" è attivo -->
        <template v-if="showDetails">
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
              <div class="tag-list">
                <span class="tag" :class="{ 'tag--muted': !concept.relations.superordinate }">
                  {{ relationLabel(concept.relations.superordinate) }}
                </span>
              </div>
            </div>

            <!-- Subordinate -->
            <div class="field">
              <label>Subordinate</label>
              <div class="tag-list">
                <span class="tag" :class="{ 'tag--muted': !concept.relations.subordinate }">
                  {{ relationLabel(concept.relations.subordinate) }}
                </span>
              </div>
            </div>

            <!-- Comprehensive -->
            <div class="field">
              <label>Comprehensive</label>
              <div class="tag-list">
                <span class="tag" :class="{ 'tag--muted': !concept.relations.comprehensive }">
                  {{ relationLabel(concept.relations.comprehensive) }}
                </span>
              </div>
            </div>

            <!-- Partitive -->
            <div class="field">
              <label>Partitive</label>
              <div class="tag-list">
                <span class="tag" :class="{ 'tag--muted': !concept.relations.partitive }">
                  {{ relationLabel(concept.relations.partitive) }}
                </span>
              </div>
            </div>
          </div>
        </template>

        <hr class="card__divider" />

        <!-- Riga di audit: data di creazione e ultimo aggiornamento -->
        <p class="meta-line">
          Created {{ formatDate(concept.createdOn) }} · Last updated {{ formatDate(concept.updatedOn) }}
        </p>
      </section>

      <!-- Card: lingue associate al concetto -->
      <section class="card">
        <div class="card__header card__header--split">
          <div class="card__header-main">
            <!-- Icona -->
            <div class="card__header-icon" aria-hidden="true">
              <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
                <path d="M480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-82q26-36 45-75t31-83H404q12 44 31 83t45 75Zm-104-16q-18-33-31.5-68.5T322-320H204q29 50 72.5 87t99.5 55Zm208 0q56-18 99.5-55t72.5-87H638q-9 38-22.5 73.5T584-178ZM170-400h136q-3-20-4.5-39.5T300-480q0-21 1.5-40.5T306-560H170q-5 20-7.5 39.5T160-480q0 21 2.5 40.5T170-400Zm216 0h188q3-20 4.5-39.5T580-480q0-21-1.5-40.5T574-560H386q-3 20-4.5 39.5T380-480q0 21 1.5 40.5T386-400Zm268 0h136q5-20 7.5-39.5T800-480q0-21-2.5-40.5T790-560H654q3 20 4.5 39.5T660-480q0 21-1.5 40.5T654-400Zm-16-240h118q-29-50-72.5-87T584-782q18 33 31.5 68.5T638-640Zm-234 0h152q-12-44-31-83t-45-75q-26 36-45 75t-31 83Zm-224 0h118q9-38 22.5-73.5T376-782q-56 18-99.5 55T204-640Z"/>
              </svg>
            </div>
            <!-- Titolo e sottotitolo -->
            <div>
              <h2>Associated languages ({{ concept.languages.length }})</h2>
              <p class="card__subtitle">Language sections and their terms</p>
            </div>
          </div>

          <!-- Bottone aggiungi lingua -->
          <button type="button" class="btn btn--ghost btn--sm" @click="showAddLanguageModal = true">
            <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M440-440H200v-80h240v-240h80v240h240v80H520v240h-80v-240Z"/></svg>
            Add language
          </button>
        </div>

        <!-- Stato vuoto: nessuna lingua ancora aggiunta -->
        <p v-if="concept.languages.length === 0" class="placeholder-note">
          No languages added yet.
        </p>

        <!-- Una sezione espandibile per ogni lingua, coi suoi termini annidati -->
        <LanguageSection
          v-for="lang in concept.languages"
          :key="lang.language"
          :language="lang"
          @edit-request="editingLanguage = $event"
          @add-term-request="handleAddTermRequest"
          @edit-term-request="handleEditTermRequest"
          @delete-language-request="handleDeleteLanguageRequest"
          @delete-term-request="handleDeleteTermRequest"
        />
      </section>
    </template>

    <!-- Modale: modifica concetto -->
    <EditConceptModal
      v-if="showEditModal && concept"
      :concept="concept"
      @close="showEditModal = false"
      @saved="handleSaved"
    />

    <!-- Modale: aggiungi lingua -->
    <AddLanguageModal
      v-if="showAddLanguageModal && concept"
      :concept-id="concept.id"
      :existing-language-codes="concept.languages.map((l) => l.language)"
      @close="showAddLanguageModal = false"
      @saved="handleLanguageSaved"
    />

    <!-- Modale: modifica lingua -->
    <EditLanguageModal
      v-if="editingLanguage"
      :concept-id="concept.id"
      :language="editingLanguage"
      @close="editingLanguage = null"
      @saved="handleLanguageSaved"
    />

    <!-- Modale: aggiungi termine -->
    <AddTermModal
      v-if="addTermLanguageCode"
      :concept-id="concept.id"
      :language-code="addTermLanguageCode"
      @close="addTermLanguageCode = null"
      @saved="handleTermSaved"
    />

    <!-- Modale: modifica termine -->
    <EditTermModal
      v-if="editingTerm"
      :concept-id="concept.id"
      :language-code="editingTermLanguageCode"
      :term="editingTerm"
      @close="editingTerm = null; editingTermLanguageCode = null"
      @saved="handleTermSaved"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { getConcept, deleteConcept } from '../services/concepts'
import { deleteLanguage } from '../services/languages'
import { deleteTerm } from '../services/terms'
import EditConceptModal from '../components/modals/EditConceptModal.vue'
import AddLanguageModal from '../components/modals/AddLanguageModal.vue'
import EditLanguageModal from '../components/modals/EditLanguageModal.vue'
import AddTermModal from '../components/modals/AddTermModal.vue'
import EditTermModal from '../components/modals/EditTermModal.vue'
import LanguageSection from '../components/concept/LanguageSection.vue'

const props = defineProps({ id: { type: String, required: true } })
const router = useRouter()

const concept = ref(null)
const loading = ref(true)
const notFound = ref(false)
const showDetails = ref(false)
const showEditModal = ref(false)
const showAddLanguageModal = ref(false)
const editingLanguage = ref(null)
const addTermLanguageCode = ref(null)
const editingTerm = ref(null)
const editingTermLanguageCode = ref(null)

// Cache locale: id concetto collegato -> subdomain risolto, popolata da loadRelationDetails
const relationDetails = reactive({})

// Etichetta da mostrare per una relazione: solo id finché il subdomain non è
// stato risolto (o se il concetto collegato non esiste più), altrimenti "id — subdomain"
function relationLabel(relatedId) {
  if (!relatedId) return 'None'
  const detail = relationDetails[relatedId]
  if (detail === undefined) return relatedId
  return detail ? `${relatedId} — ${detail}` : relatedId
}

// Formatta una data ISO in "12 Jul 2026"
function formatDate(isoString) {
  if (!isoString) return '—'
  return new Date(isoString).toLocaleDateString('en-GB', {
    day: 'numeric', month: 'short', year: 'numeric',
  })
}

// Per ogni relazione valorizzata (superordinate/subordinate/ecc.), recupera il
// concetto collegato per risolverne il subdomain. Se il concetto è stato nel
// frattempo eliminato (404), la relazione resta comunque visibile ma senza
// subdomain risolto — gestito da relationLabel sopra.
async function loadRelationDetails(relations) {
  const ids = Object.values(relations).filter(Boolean)
  await Promise.all(
    ids.map(async (relatedId) => {
      try {
        const related = await getConcept(relatedId)
        relationDetails[relatedId] = related.subdomain || ''
      } catch {
        relationDetails[relatedId] = ''
      }
    })
  )
}

// Carica il concetto e risolve le sue relazioni. Richiamata sia al mount sia
// dopo ogni modifica (creazione lingua/termine, eliminazione, ecc.) per
// rimanere sempre sincronizzati con lo stato reale del backend.
async function loadConceptData() {
  loading.value = true
  notFound.value = false
  try {
    concept.value = await getConcept(props.id)
    await loadRelationDetails(concept.value.relations)
  } catch (err) {
    if (err.response?.status === 404) {
      notFound.value = true
    } else {
      console.error(err)
    }
  } finally {
    loading.value = false
  }
}

// Chiude il modale di modifica concetto e ricarica i dati
function handleSaved() {
  showEditModal.value = false
  loadConceptData()
}

// Chiude entrambi i modali lingua (aggiungi/modifica) e ricarica i dati
function handleLanguageSaved() {
  showAddLanguageModal.value = false
  editingLanguage.value = null
  loadConceptData()
}

// Apre il modale "Aggiungi termine" per la lingua da cui è stato richiesto
function handleAddTermRequest(languageCode) {
  addTermLanguageCode.value = languageCode
}

// Apre il modale "Modifica termine" con il termine e la lingua selezionati
function handleEditTermRequest({ term, languageCode }) {
  editingTerm.value = term
  editingTermLanguageCode.value = languageCode
}

// Chiude entrambi i modali termine (aggiungi/modifica) e ricarica i dati
function handleTermSaved() {
  addTermLanguageCode.value = null
  editingTerm.value = null
  editingTermLanguageCode.value = null
  loadConceptData()
}

// Elimina il concetto corrente. Il messaggio di conferma menziona quante
// sezioni lingua (e quindi termini) verrebbero eliminate in cascata, così
// l'utente sa cosa sta per succedere prima di confermare.
async function handleDeleteConcept() {
  const languageCount = concept.value.languages.length
  const message = languageCount > 0
    ? `Delete this concept? This will also delete its ${languageCount} language section${languageCount === 1 ? '' : 's'} and all their terms. This can't be undone.`
    : `Delete this concept? This can't be undone.`

  if (!window.confirm(message)) return

  try {
    await deleteConcept(concept.value.id)
    router.push('/concepts')
  } catch (err) {
    window.alert('Failed to delete the concept. Please try again.')
    console.error(err)
  }
}

// Elimina una sezione lingua (la conferma, con conteggio termini, è già
// gestita dentro LanguageSection prima di emettere questo evento)
async function handleDeleteLanguageRequest(languageCode) {
  try {
    await deleteLanguage(concept.value.id, languageCode)
    loadConceptData()
  } catch (err) {
    window.alert('Failed to delete the language. Please try again.')
    console.error(err)
  }
}

// Elimina un termine (conferma già gestita dentro TermCard)
async function handleDeleteTermRequest({ term, languageCode }) {
  try {
    await deleteTerm(concept.value.id, languageCode, term.id)
    loadConceptData()
  } catch (err) {
    window.alert('Failed to delete the term. Please try again.')
    console.error(err)
  }
}

onMounted(loadConceptData)
</script>