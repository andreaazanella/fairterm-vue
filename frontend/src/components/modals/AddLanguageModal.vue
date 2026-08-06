<template>
  <Modal @close-request="handleCloseRequest">
    <div class="modal-header">
      <div class="card__header-main">
        <div class="card__header-icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-80q-83 0-156-31.5T197-197q-54-54-85.5-127T80-480q0-83 31.5-156T197-763q54-54 127-85.5T480-880q83 0 156 31.5T763-763q54 54 85.5 127T880-480q0 83-31.5 156T763-197q-54 54-127 85.5T480-80Zm0-82q26-36 45-75t31-83H404q12 44 31 83t45 75Zm-104-16q-18-33-31.5-68.5T322-320H204q29 50 72.5 87t99.5 55Zm208 0q56-18 99.5-55t72.5-87H638q-9 38-22.5 73.5T584-178ZM170-400h136q-3-20-4.5-39.5T300-480q0-21 1.5-40.5T306-560H170q-5 20-7.5 39.5T160-480q0 21 2.5 40.5T170-400Zm216 0h188q3-20 4.5-39.5T580-480q0-21-1.5-40.5T574-560H386q-3 20-4.5 39.5T380-480q0 21 1.5 40.5T386-400Zm268 0h136q5-20 7.5-39.5T800-480q0-21-2.5-40.5T790-560H654q3 20 4.5 39.5T660-480q0 21-1.5 40.5T654-400Zm-16-240h118q-29-50-72.5-87T584-782q18 33 31.5 68.5T638-640Zm-234 0h152q-12-44-31-83t-45-75q-26 36-45 75t-31 83Zm-224 0h118q9-38 22.5-73.5T376-782q-56 18-99.5 55T204-640Z"/></svg>
        </div>
        <div>
          <h2>Add language</h2>
          <p class="card__subtitle">Add a new language section to this concept.</p>
        </div>
      </div>
      <button type="button" class="modal-close" @click="handleCloseRequest" aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-424 284-228q-15 15-35 15t-35-15q-15-15-15-35t15-35l196-196-196-196q-15-15-15-35t15-35q15-15 35-15t35 15l196 196 196-196q15-15 35-15t35 15q15 15 15 35t-15 35L536-480l196 196q15 15 15 35t-15 35q-15 15-35 15t-35-15L480-424Z"/></svg>
      </button>
    </div>

    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <div class="field">
      <label>Language <span class="required">*</span></label>
      <select class="dropdown" v-model="form.language" required>
        <option value="">Select a language</option>
        <option v-for="lang in availableLanguages" :key="lang.id" :value="lang.id">{{ lang.name }}</option>
      </select>
    </div>

    <div class="field">
      <label>Definition <span class="required">*</span></label>
      <textarea v-model="form.definition" rows="2" placeholder="Enter the definition"></textarea>
    </div>

    <div class="field">
      <label>External cross reference</label>
      <input type="text" v-model="form.externalCrossReference" placeholder="e.g. https://... or a reference code" />
    </div>

    <div class="field">
      <label>Source</label>
      <input type="text" v-model="form.source" placeholder="e.g. ISO/IEC 2382-1:1993, 2127" />
    </div>

    <div class="field">
      <label>Notes</label>
      <textarea v-model="form.notes" rows="2" placeholder="Optional notes"></textarea>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn--ghost" @click="handleCloseRequest">Cancel</button>
      <button type="button" class="btn btn--primary" :disabled="saving" @click="handleSave">
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M840-680v480q0 33-23.5 56.5T760-120H200q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h480l160 160Zm-80 34L646-760H200v560h560v-446ZM565-275q35-35 35-85t-35-85q-35-35-85-35t-85 35q-35 35-35 85t35 85q35 35 85 35t85-35ZM240-560h360v-160H240v160Zm-40-86v446-560 114Z"/></svg>
        {{ saving ? 'Saving...' : 'Add language' }}
      </button>
    </div>
  </Modal>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import Modal from '../ui/Modal.vue'
import { useReferenceData } from '../../composables/useReferenceData'
import { addLanguage } from '../../services/languages'

const props = defineProps({
  conceptId: { type: String, required: true },
  existingLanguageCodes: { type: Array, default: () => [] },
})

const emit = defineEmits(['close', 'saved'])

const { languages, load } = useReferenceData()
load()

// filtriamo a monte le lingue già associate al concetto, così l'errore 409
// del backend diventa un caso limite di sicurezza, non il percorso normale
const availableLanguages = computed(() =>
  languages.value.filter((lang) => !props.existingLanguageCodes.includes(lang.id))
)

const form = reactive({
  language: '',
  definition: '',
  externalCrossReference: '',
  source: '',
  notes: '',
})

let initialSnapshot = ''
onMounted(() => {
  initialSnapshot = JSON.stringify(form)
})

const isDirty = computed(() => JSON.stringify(form) !== initialSnapshot)

const errorMessage = ref('')
const saving = ref(false)

function handleCloseRequest() {
  if (isDirty.value) {
    const discard = window.confirm('You have unsaved changes. Discard them?')
    if (!discard) return
  }
  emit('close')
}

async function handleSave() {
  errorMessage.value = ''

  if (!form.language) {
    errorMessage.value = 'Select a language.'
    return
  }
  if (!form.definition) {
    errorMessage.value = 'Enter a definition.'
    return
  }

  saving.value = true
  try {
    const result = await addLanguage(props.conceptId, {
      language: form.language,
      definition: form.definition,
      externalCrossReference: form.externalCrossReference || null,
      source: form.source || null,
      notes: form.notes || null,
    })
    emit('saved', result.languages)
  } catch (err) {
    if (err.response?.status === 409) {
      errorMessage.value = 'This language is already associated with the concept.'
    } else {
      errorMessage.value = 'Failed to add the language. Please try again.'
    }
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>