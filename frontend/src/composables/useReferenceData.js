import { ref } from 'vue'
import { fetchReferenceData } from '../services/referenceData'

// Stato a livello di modulo, non dentro la funzione: ogni componente che chiama
// useReferenceData() condivide la stessa cache invece di rifare la chiamata API.
const subjectFields = ref([])
const loaded = ref(false)
const loading = ref(false)

export function useReferenceData() {
  async function load() {
    if (loaded.value || loading.value) return
    loading.value = true
    try {
      // Chiamata API per ottenere i dati di riferimento
      const data = await fetchReferenceData()
      subjectFields.value = data.subjectFields.map((field) => field.name)
      loaded.value = true
    } finally {
      loading.value = false
    }
  }

  return { subjectFields, loading, load }
}