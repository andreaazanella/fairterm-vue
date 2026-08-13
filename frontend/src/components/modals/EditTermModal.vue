<template>
  <Modal @close-request="handleCloseRequest">
    <!-- Header del modale: icona, titolo, sottotitolo con termine e lingua, bottone chiudi -->
    <div class="modal-header">
      <div class="card__header-main">
        <div class="card__header-icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
        </div>
        <div>
          <h2>Edit term</h2>
          <p class="card__subtitle">Editing "{{ term.designation }}" ({{ languageName(languageCode) }}).</p>
        </div>
      </div>
      <button type="button" class="modal-close" @click="handleCloseRequest" aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-424 284-228q-15 15-35 15t-35-15q-15-15-15-35t15-35l196-196-196-196q-15-15-15-35t15-35q15-15 35-15t35 15l196 196 196-196q15-15 35-15t35 15q15 15 15 35t-15 35L536-480l196 196q15 15 15 35t-15 35q-15 15-35 15t-35-15L480-424Z"/></svg>
      </button>
    </div>

    <!-- Messaggio di errore -->
    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <!-- Designation e Usage, entrambi obbligatori -->
    <div class="relations-grid">
      <div class="field">
        <label>Designation <span class="required">*</span></label>
        <input type="text" v-model="form.designation" placeholder="Enter the term" />
      </div>
      <div class="field">
        <label>Usage <span class="required">*</span></label>
        <select class="dropdown" v-model="form.usage" required>
          <option value="">Select usage</option>
          <option v-for="value in usageValues" :key="value" :value="value">{{ capitalize(value) }}</option>
        </select>
      </div>
    </div>

    <!-- Part of speech, gender, number: facoltativi, "required" solo per lo stile del placeholder -->
    <div class="relations-grid">
      <div class="field">
        <label>Part of speech</label>
        <select class="dropdown" v-model="form.partOfSpeech" required>
          <option value="">Select part of speech</option>
          <option v-for="pos in posValues" :key="pos.value" :value="pos.value">{{ capitalize(pos.label) }}</option>
        </select>
      </div>
      <div class="field">
        <label>Grammatical gender</label>
        <select class="dropdown" v-model="form.grammaticalGender" required>
          <option value="">Select gender</option>
          <option v-for="g in genderValues" :key="g.value" :value="g.value">{{ capitalize(g.label) }}</option>
        </select>
      </div>
      <div class="field">
        <label>Grammatical number</label>
        <select class="dropdown" v-model="form.grammaticalNumber" required>
          <option value="">Select number</option>
          <option v-for="n in numberValues" :key="n.value" :value="n.value">{{ capitalize(n.label) }}</option>
        </select>
      </div>
    </div>

    <!-- Type: multi-valore, salvato nel DB come stringa unica separata da ";" -->
    <div class="field">
      <label>Type</label>
      <MultiSelect
        v-model="form.type"
        :options="typeValues"
        placeholder="Select one or more types"
        capitalize
      />
    </div>

    <!-- Context -->
    <div class="field">
      <label>Context</label>
      <textarea v-model="form.context" rows="2" placeholder="Enter a usage example"></textarea>
    </div>

    <!-- External cross reference e Source -->
    <div class="relations-grid">
      <div class="field">
        <label>External cross reference</label>
        <input type="text" v-model="form.externalCrossReference" placeholder="e.g. https://... or a reference code" />
      </div>
      <div class="field">
        <label>Source</label>
        <input type="text" v-model="form.source" placeholder="e.g. ISO/IEC 2382-1:1993, 2127" />
      </div>
    </div>

    <!-- Register e Collocation, entrambi testo libero -->
    <div class="relations-grid">
      <div class="field">
        <label>Register</label>
        <input type="text" v-model="form.register" placeholder="e.g. technical, colloquial" />
      </div>
      <div class="field">
        <label>Collocation</label>
        <input type="text" v-model="form.collocation" placeholder="e.g. build a decision tree" />
      </div>
    </div>

    <!-- Notes -->
    <div class="field">
      <label>Notes</label>
      <textarea v-model="form.notes" rows="2" placeholder="Optional notes"></textarea>
    </div>

    <!-- Azioni: annulla / salva -->
    <div class="modal-footer">
      <button type="button" class="btn btn--ghost" @click="handleCloseRequest">Cancel</button>
      <button type="button" class="btn btn--primary" :disabled="saving" @click="handleSave">
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M840-680v480q0 33-23.5 56.5T760-120H200q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h480l160 160Zm-80 34L646-760H200v560h560v-446ZM565-275q35-35 35-85t-35-85q-35-35-85-35t-85 35q-35 35-35 85t35 85q35 35 85 35t85-35ZM240-560h360v-160H240v160Zm-40-86v446-560 114Z"/></svg>
        {{ saving ? 'Saving...' : 'Save changes' }}
      </button>
    </div>
  </Modal>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import Modal from '../ui/Modal.vue'
import MultiSelect from '../ui/MultiSelect.vue'
import { useReferenceData } from '../../composables/useReferenceData'
import { updateTerm } from '../../services/terms'

const props = defineProps({
  conceptId: { type: String, required: true },
  languageCode: { type: String, required: true },
  term: { type: Object, required: true },
})

const emit = defineEmits(['close', 'saved'])

const { usageValues, typeValues, posValues, genderValues, numberValues, languageName, load, capitalize } = useReferenceData()
load()

// Form pre-compilato con i valori attuali del termine da modificare
const form = reactive({
  designation: props.term.designation || '',
  usage: props.term.usage || '',
  partOfSpeech: props.term.partOfSpeech || '',
  grammaticalGender: props.term.grammaticalGender || '',
  grammaticalNumber: props.term.grammaticalNumber || '',
  type: props.term.type ? props.term.type.split(';') : [],
  context: props.term.context || '',
  externalCrossReference: props.term.externalCrossReference || '',
  source: props.term.source || '',
  register: props.term.register || '',
  collocation: props.term.collocation || '',
  notes: props.term.notes || '',
})

let initialSnapshot = ''
onMounted(() => {
  initialSnapshot = JSON.stringify(form)
})

// Confronta lo stato attuale del form con lo snapshot iniziale, per sapere se
// ci sono modifiche non salvate al momento della chiusura
const isDirty = computed(() => JSON.stringify(form) !== initialSnapshot)

const errorMessage = ref('')
const saving = ref(false)

// Chiede conferma solo se ci sono modifiche non salvate, altrimenti chiude subito
function handleCloseRequest() {
  if (isDirty.value) {
    const discard = window.confirm('You have unsaved changes. Discard them?')
    if (!discard) return
  }
  emit('close')
}

// Valida i campi obbligatori, salva le modifiche e comunica al genitore i
// termini aggiornati di quella lingua
async function handleSave() {
  errorMessage.value = ''

  if (!form.designation) {
    errorMessage.value = 'Enter a designation.'
    return
  }
  if (!form.usage) {
    errorMessage.value = 'Select a usage.'
    return
  }

  saving.value = true
  try {
    const result = await updateTerm(props.conceptId, props.languageCode, props.term.id, {
      designation: form.designation,
      usage: form.usage,
      partOfSpeech: form.partOfSpeech || null,
      grammaticalGender: form.grammaticalGender || null,
      grammaticalNumber: form.grammaticalNumber || null,
      type: form.type.length > 0 ? form.type.join(';') : null,
      context: form.context || null,
      externalCrossReference: form.externalCrossReference || null,
      source: form.source || null,
      register: form.register || null,
      collocation: form.collocation || null,
      notes: form.notes || null,
    })
    emit('saved', result.terms)
  } catch (err) {
    errorMessage.value = 'Failed to save changes. Please try again.'
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>