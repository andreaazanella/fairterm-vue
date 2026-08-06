<template>
  <Modal @close-request="handleCloseRequest">
    <div class="modal-header">
      <div class="card__header-main">
        <div class="card__header-icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
        </div>
        <div>
          <h2>Edit language</h2>
          <p class="card__subtitle">Edit this language section. The language itself can't be changed.</p>
        </div>
      </div>
      <button type="button" class="modal-close" @click="handleCloseRequest" aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-424 284-228q-15 15-35 15t-35-15q-15-15-15-35t15-35l196-196-196-196q-15-15-15-35t15-35q15-15 35-15t35 15l196 196 196-196q15-15 35-15t35 15q15 15 15 35t-15 35L536-480l196 196q15 15 15 35t-15 35q-15 15-35 15t-35-15L480-424Z"/></svg>
      </button>
    </div>

    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <div class="field">
      <label>Language</label>
      <div class="tag-list">
        <span class="tag tag--muted">{{ languageName(language.language) }}</span>
      </div>
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
        {{ saving ? 'Saving...' : 'Save changes' }}
      </button>
    </div>
  </Modal>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import Modal from '../ui/Modal.vue'
import { useReferenceData } from '../../composables/useReferenceData'
import { updateLanguage } from '../../services/languages'

const props = defineProps({
  conceptId: { type: String, required: true },
  language: { type: Object, required: true },
})

const emit = defineEmits(['close', 'saved'])

const { languageName } = useReferenceData()

const form = reactive({
  definition: props.language.definition || '',
  externalCrossReference: props.language.externalCrossReference || '',
  source: props.language.source || '',
  notes: props.language.notes || '',
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

  if (!form.definition) {
    errorMessage.value = 'Enter a definition.'
    return
  }

  saving.value = true
  try {
    const result = await updateLanguage(props.conceptId, props.language.language, {
      definition: form.definition,
      externalCrossReference: form.externalCrossReference || null,
      source: form.source || null,
      notes: form.notes || null,
    })
    emit('saved', result.languages)
  } catch (err) {
    errorMessage.value = 'Failed to save changes. Please try again.'
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>