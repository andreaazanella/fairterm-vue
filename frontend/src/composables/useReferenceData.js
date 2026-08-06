import { ref } from 'vue'
import { fetchReferenceData } from '../services/referenceData'

// Stato a livello di modulo, non dentro la funzione: ogni componente che chiama
// useReferenceData() condivide la stessa cache invece di rifare la chiamata API.

const subjectFields = ref([])
const languages = ref([])
const usageValues = ref([])
const typeValues = ref([])
const posValues = ref([])
const genderValues = ref([])
const numberValues = ref([])
const loaded = ref(false)
const loading = ref(false)

export function useReferenceData() {
  async function load() {
    if (loaded.value || loading.value) return
    loading.value = true
    try {
      const data = await fetchReferenceData()
      subjectFields.value = data.subjectFields.map((field) => field.name)
      languages.value = data.languages // [{ id, name }, ...]
      usageValues.value = data.usageValues
      typeValues.value = data.typeValues
      posValues.value = data.posValues // [{ value, label }, ...]
      genderValues.value = data.genderValues
      numberValues.value = data.numberValues
      loaded.value = true
    } finally {
      loading.value = false
    }
  }

  function languageName(code) {
    const match = languages.value.find((lang) => lang.id === code)
    return match ? match.name : code
  }

  function posLabel(code) {
    const match = posValues.value.find((item) => item.value === code)
    return match ? match.label : code
  }

  function genderLabel(code) {
    const match = genderValues.value.find((item) => item.value === code)
    return match ? match.label : code
  }

  function numberLabel(code) {
    const match = numberValues.value.find((item) => item.value === code)
    return match ? match.label : code
  }

  return {
    subjectFields, languages, usageValues, typeValues, posValues, genderValues, numberValues,
    loading, load, languageName, posLabel, genderLabel, numberLabel,
  }
}