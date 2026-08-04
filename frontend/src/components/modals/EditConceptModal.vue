<template>
  <Modal @close-request="handleCloseRequest">
    <div class="modal-header">
      <div class="card__header-main">
        <div class="card__header-icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
        </div>
        <div>
          <h2>Edit concept</h2>
          <p class="card__subtitle">Edit the concept's information. Fields that can't be changed are disabled.</p>
        </div>
      </div>
      <button type="button" class="modal-close" @click="handleCloseRequest" aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" height="20px" viewBox="0 -960 960 960" width="20px" fill="currentColor"><path d="M480-424 284-228q-15 15-35 15t-35-15q-15-15-15-35t15-35l196-196-196-196q-15-15-15-35t15-35q15-15 35-15t35 15l196 196 196-196q15-15 35-15t35 15q15 15 15 35t-15 35L536-480l196 196q15 15 15 35t-15 35q-15 15-35 15t-35-15L480-424Z"/></svg>
      </button>
    </div>

    <p v-if="errorMessage" class="form-error">⚠️ {{ errorMessage }}</p>

    <div class="field">
      <label>Concept ID</label>
      <div class="tag-list">
        <span class="tag tag--muted">{{ concept.id }}</span>
      </div>
    </div>

    <div class="field">
      <label>Subject field <span class="required">*</span></label>
      <MultiSelect
        v-model="form.subjectFields"
        :options="subjectFieldOptions"
        placeholder="Select one or more subject fields"
      />
    </div>

    <div class="field">
      <label>Subdomain</label>
      <input type="text" v-model="form.subdomain" placeholder="Enter the subdomain (optional)"/>
    </div>

    <hr class="card__divider" />

    <div class="card__header">
      <div class="card__header-icon" aria-hidden="true">
        <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
          <path d="M121-121q-41-41-41-99t41-99q41-41 99-41 18 0 35 4.5t32 12.5l153-153v-110q-44-13-72-49.5T340-740q0-58 41-99t99-41q58 0 99 41t41 99q0 48-28 84.5T520-606v110l154 153q15-8 31.5-12.5T740-360q58 0 99 41t41 99q0 58-41 99t-99 41q-58 0-99-41t-41-99q0-18 4.5-35t12.5-32L480-424 343-287q8 15 12.5 32t4.5 35q0 58-41 99t-99 41q-58 0-99-41Zm661.5-56.5Q800-195 800-220t-17.5-42.5Q765-280 740-280t-42.5 17.5Q680-245 680-220t17.5 42.5Q715-160 740-160t42.5-17.5Zm-260-520Q540-715 540-740t-17.5-42.5Q505-800 480-800t-42.5 17.5Q420-765 420-740t17.5 42.5Q455-680 480-680t42.5-17.5Zm-260 520Q280-195 280-220t-17.5-42.5Q245-280 220-280t-42.5 17.5Q160-245 160-220t17.5 42.5Q195-160 220-160t42.5-17.5Z"/>
        </svg>
      </div>
      <div>
        <h2>Concept relations</h2>
        <p class="card__subtitle">Link this concept to other existing concepts</p>
      </div>
    </div>

    <div class="relations-grid">
      <div class="field">
        <label>Superordinate</label>
        <select class="dropdown" v-model="form.relations.superordinate" required>
          <option value="">Select a concept</option>
          <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
            {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
          </option>
        </select>
      </div>

      <div class="field">
        <label>Subordinate</label>
        <select class="dropdown" v-model="form.relations.subordinate" required>
          <option value="">Select a concept</option>
          <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
            {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
          </option>
        </select>
      </div>

      <div class="field">
        <label>Comprehensive</label>
        <select class="dropdown" v-model="form.relations.comprehensive" required>
          <option value="">Select a concept</option>
          <option v-for="c in relationCandidates" :key="c.id" :value="c.id">
            {{ c.id }} — {{ c.subdomain || 'no subdomain' }}
          </option>
        </select>
      </div>

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
import { reactive, ref, computed, watch, onMounted } from 'vue'
import Modal from '../ui/Modal.vue'
import MultiSelect from '../ui/MultiSelect.vue'
import { useReferenceData } from '../../composables/useReferenceData'
import { listConcepts, updateConcept } from '../../services/concepts'

const props = defineProps({
  concept: { type: Object, required: true },
})

const emit = defineEmits(['close', 'saved'])

const { subjectFields, load } = useReferenceData()
load()
const subjectFieldOptions = computed(() => subjectFields.value)

function relationsToForm(relations) {
  return {
    superordinate: relations.superordinate || '',
    subordinate: relations.subordinate || '',
    comprehensive: relations.comprehensive || '',
    partitive: relations.partitive || '',
  }
}

const form = reactive({
  subjectFields: [...props.concept.subjectFields],
  subdomain: props.concept.subdomain || '',
  relations: relationsToForm(props.concept.relations),
})

let initialSnapshot = ''
onMounted(() => {
  initialSnapshot = JSON.stringify(form)
})

const isDirty = computed(() => JSON.stringify(form) !== initialSnapshot)

const relationCandidates = ref([])
const errorMessage = ref('')
const saving = ref(false)

watch(
  () => form.subjectFields,
  async (fields) => {
    if (fields.length === 0) {
      relationCandidates.value = []
      return
    }
    const results = await Promise.all(fields.map(listConcepts))
    const merged = new Map()
    results.flat().forEach((c) => merged.set(c.id, c))
    merged.delete(props.concept.id)
    relationCandidates.value = Array.from(merged.values())
  },
  { deep: true, immediate: true }
)

function handleCloseRequest() {
  if (isDirty.value) {
    const discard = window.confirm('You have unsaved changes. Discard them?')
    if (!discard) return
  }
  emit('close')
}

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

    const updated = await updateConcept(props.concept.id, {
      subjectFields: form.subjectFields,
      subdomain: form.subdomain || null,
      relations,
    })

    emit('saved', updated)
  } catch (err) {
    errorMessage.value = 'Failed to save changes. Please try again.'
    console.error(err)
  } finally {
    saving.value = false
  }
}
</script>