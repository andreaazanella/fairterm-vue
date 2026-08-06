<template>
  <Modal @close-request="handleCloseRequest">
    <div class="modal-header">
      <div class="card__header-main">
        <div class="card__header-icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M480-80 240-220v-280L40-620l440-260 440 260v360h-80v-315l-80 47v280L480-80Zm0-360 278-164-278-164-278 164 278 164Zm0 274 160-94v-188l-160 94-160-94v188l160 94Z"/></svg>
        </div>
        <div>
          <h2>Add term</h2>
          <p class="card__subtitle">Add a new term to {{ languageName(languageCode) }}.</p>
        </div>
      </div>
      <button type="button" class="modal-close" @click="handleCloseRequest" aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-424 284-228q-15 15-35 15t-35-15q-15-15-15-35t15-35l196-196-196-196q-15-15-15-35t15-35q15-15 35-15t35 15l196 196 196-196q15-15 35-15t35 15q15 15 15 35t-15 35L536-480l196 196q15 15 15 35t-15 35q-15 15-35 15t-35-15L480-424Z"/></svg>
      </button>
    </div>

    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <div class="relations-grid">
      <div class="field">
        <label>Designation <span class="required">*</span></label>
        <input type="text" v-model="form.designation" placeholder="Enter the term" />
      </div>
      <div class="field">
        <label>Usage <span class="required">*</span></label>
        <select class="dropdown" v-model="form.usage" required>
          <option value="">Select usage</option>
          <option v-for="value in usageValues" :key="value" :value="value">{{ value }}</option>
        </select>
      </div>
    </div>

    <div class="relations-grid">
      <div class="field">
        <label>Part of speech</label>
        <select class="dropdown" v-model="form.partOfSpeech" required>
          <option value="">Select part of speech</option>
          <option v-for="pos in posValues" :key="pos.value" :value="pos.value">{{ pos.label }}</option>
        </select>
      </div>
      <div class="field">
        <label>Grammatical gender</label>
        <select class="dropdown" v-model="form.grammaticalGender" required>
          <option value="">Select gender</option>
          <option v-for="g in genderValues" :key="g.value" :value="g.value">{{ g.label }}</option>
        </select>
      </div>
      <div class="field">
        <label>Grammatical number</label>
        <select class="dropdown" v-model="form.grammaticalNumber" required>
          <option value="">Select number</option>
          <option v-for="n in numberValues" :key="n.value" :value="n.value">{{ n.label }}</option>
        </select>
      </div>
    </div>

    <div class="field">
      <label>Type</label>
      <select class="dropdown" v-model="form.type" required>
        <option value="">Select a type</option>
        <option v-for="value in typeValues" :key="value" :value="value">{{ value }}</option>
      </select>
    </div>

    <div class="field">
      <label>Context</label>
      <textarea v-model="form.context" rows="2" placeholder="Enter a usage example"></textarea>
    </div>

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

    <div class="field">
      <label>Notes</label>
      <textarea v-model="form.notes" rows="2" placeholder="Optional notes"></textarea>
    </div>

    <div class="modal-footer">
      <button type="button" class="btn btn--ghost" @click="handleCloseRequest">Cancel</button>
      <button type="button" class="btn btn--primary" :disabled="saving" @click="handleSave">
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M840-680v480q0 33-23.5 56.5T760-120H200q-33 0-56.5-23.5T120-200v-560q0-33 23.5-56.5T200-840h480l160 160Zm-80 34L646-760H200v560h560v-446ZM565-275q35-35 35-85t-35-85q-35-35-85-35t-85 35q-35 35-35 85t35 85q35 35 85 35t85-35ZM240-560h360v-160H240v160Zm-40-86v446-560 114Z"/></svg>
        {{ saving ? 'Saving...' : 'Add term' }}
      </button>
    </div>
  </Modal>
</template>

<script setup>
import { reactive, ref, computed, onMounted } from 'vue'
import Modal from '../ui/Modal.vue'
import { useReferenceData } from '../../composables/useReferenceData'
import { addTerm } from '../../services/terms'

const props = defineProps({
  conceptId: { type: String, required: true },
  languageCode: { type: String, required: true },
})

const emit = defineEmits(['close', 'saved'])

const { usageValues, typeValues, posValues, genderValues, numberValues, languageName, load } = useReferenceData()
load()

const form = reactive({
  designation: '',
  usage: '',
  partOfSpeech: '',
  grammaticalGender: '',
  grammaticalNumber: '',
  type: '',
  context: '',
  externalCrossReference: '',
  source: '',
  register: '',
  collocation: '',
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
    const result = await addTerm(props.conceptId, props.languageCode, {
      designation: form.designation,
      usage: form.usage,
      partOfSpeech: form.partOfSpeech || null,
      grammaticalGender: form.grammaticalGender || null,
      grammaticalNumber: form.grammaticalNumber || null,
      type: form.type || null,
      context: form.context || null,
      externalCrossReference: form.externalCrossReference || null,
      source: form.source || null,
      register: form.register || null,
      collocation: form.collocation || null,
      notes: form.notes || null,
    })
    emit('saved', result.terms)
  } catch (err) {
    errorMessage.value = 'Failed to add the term. Please try again.'
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>