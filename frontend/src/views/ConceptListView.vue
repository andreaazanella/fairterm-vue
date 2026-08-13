<template>
  <div class="page">
    <header class="page-header">
      <!-- Breadcrumb di navigazione -->
      <nav class="breadcrumb">
        <RouterLink to="/concepts" class="breadcrumb__current">Concepts</RouterLink>
      </nav>
    </header>

    <hr class="page__divider" />

    <!-- Titolo pagina -->
    <div class="title-row">
      <h1 class="concept-title">Concepts</h1>
    </div>

    <!-- Bozza: lista di tutti i concetti esistenti, senza stile, solo link -->
    <p v-if="loading">Loading...</p>
    <ul v-else>
      <li v-for="concept in concepts" :key="concept.id">
        <RouterLink :to="`/concepts/${concept.id}`">{{ concept.id }} — {{ concept.subdomain || 'no subdomain' }}</RouterLink>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useReferenceData } from '../composables/useReferenceData'
import { listConcepts } from '../services/concepts'

const { subjectFields, load } = useReferenceData()

const concepts = ref([])
const loading = ref(true)

// Bozza: il backend filtra sempre per subject field, quindi per avere "tutti"
// i concetti interroghiamo ogni subject field disponibile e uniamo i
// risultati, deduplicando per id (un concetto può appartenere a più domini).
// Nota: con 148 subject field questo significa fino a 148 chiamate parallele
// — accettabile per una bozza, da rivedere se la lista diventa definitiva.
async function loadAllConcepts() {
  loading.value = true
  await load()
  const results = await Promise.all(subjectFields.value.map(listConcepts))
  const merged = new Map()
  results.flat().forEach((concept) => merged.set(concept.id, concept))
  concepts.value = Array.from(merged.values())
  loading.value = false
}

onMounted(loadAllConcepts)
</script>