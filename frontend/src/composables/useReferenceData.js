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

// Capitalizza solo la prima lettera di una stringa, lasciando il resto
// invariato (es. "plural number" -> "Plural number"). Usato per mostrare i
// valori di vocabolario del termine, che nel database restano tutti minuscoli.
function capitalize(text) {
  if (!text) return text
  return text.charAt(0).toUpperCase() + text.slice(1)
}

export function useReferenceData() {

  // Scarica tutte le liste di riferimento in un'unica chiamata e le mette in
  // cache. Protetta da doppie chiamate: se il caricamento è già avvenuto (o è
  // in corso da un altro componente nello stesso istante), non rifà la richiesta.
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

  // Risolve il codice lingua nel nome leggibile (es. "en" -> "English")
  function languageName(code) {
    const match = languages.value.find((lang) => lang.id === code)
    return match ? match.name : code
  }

  // Risolve il codice part of speech nell'etichetta leggibile (es. "NOUN" -> "Noun")
  function posLabel(code) {
    const match = posValues.value.find((item) => item.value === code)
    return match ? capitalize(match.label) : code
  }

  // Risolve il codice di genere grammaticale nell'etichetta leggibile (es. "Fem" -> "Feminine")
  function genderLabel(code) {
    const match = genderValues.value.find((item) => item.value === code)
    return match ? capitalize(match.label) : code
  }

  // Risolve il codice di numero grammaticale nell'etichetta leggibile (es. "Plur" -> "Plural number")
  function numberLabel(code) {
    const match = numberValues.value.find((item) => item.value === code)
    return match ? capitalize(match.label) : code
  }

  return {
    subjectFields, languages, usageValues, typeValues, posValues, genderValues, numberValues,
    loading, load, languageName, posLabel, genderLabel, numberLabel, capitalize,
  }
}