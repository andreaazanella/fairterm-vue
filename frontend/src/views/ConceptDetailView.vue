<template>
  <div class="page">

    <!-- Loading -->
    <div v-if="loading" class="page-state">
      <div class="page-state__spinner" aria-hidden="true"></div>
      <p>Loading concept...</p>
    </div>

    <!-- Not found -->
    <div v-else-if="notFound" class="page-state">
      <p>Concept not found.</p>
      <RouterLink to="/concepts" class="btn btn--ghost">Back to Concepts</RouterLink>
    </div>

    <!-- Concept detail -->
    <template v-else-if="concept">
      <header class="page-header">
        <!-- Breadcrumb navigation -->
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
          <!-- Edit button -->
          <button type="button" class="btn btn--primary">
            <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 -960 960 960" width="24px" fill="currentColor"><path d="M200-200h57l391-391-57-57-391 391v57Zm-80 80v-170l528-527q12-11 26.5-17t30.5-6q16 0 31 6t26 18l55 56q12 11 17.5 26t5.5 30q0 16-5.5 30.5T817-647L290-120H120Z"/></svg>
            Edit concept
          </button>
        </div>
      </div>

      <section class="card">
        <div class="card__header card__header--split">
          <div class="card__header-main">
            <!-- Icon -->
            <div class="card__header-icon" aria-hidden="true">
              <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
                <path d="M491-339q70 0 119-45t49-109q0-57-36.5-96.5T534-629q-47 0-79.5 30T422-525q0 19 7.5 37t21.5 33l57-57q-3-2-4.5-5t-1.5-7q0-11 9-17.5t23-6.5q20 0 33 16.5t13 39.5q0 31-25.5 52.5T492-418q-47 0-79.5-38T380-549q0-29 11-55.5t31-46.5l-57-57q-32 31-49 72t-17 86q0 88 56 149.5T491-339ZM240-80v-172q-57-52-88.5-121.5T120-520q0-150 105-255t255-105q125 0 221.5 73.5T827-615l52 205q5 19-7 34.5T840-360h-80v120q0 33-23.5 56.5T680-160h-80v80h-80v-160h160v-200h108l-38-155q-23-91-98-148t-172-57q-116 0-198 81t-82 197q0 60 24.5 114t69.5 96l26 24v208h-80Zm254-360Z"/>
              </svg>
            </div>
            <!-- Title and subtitle -->
            <div>
              <h2>Concept information</h2>
              <p class="card__subtitle">Define the general context of the concept</p>
            </div>
          </div>
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

        <template v-if="showDetails">
          <hr class="card__divider" />

          <div class="card__header">
            <!-- Icon -->
            <div class="card__header-icon" aria-hidden="true">
              <svg xmlns="http://www.w3.org/2000/svg" height="25px" viewBox="0 -960 960 960" width="25px" fill="currentColor">
                <path d="M121-121q-41-41-41-99t41-99q41-41 99-41 18 0 35 4.5t32 12.5l153-153v-110q-44-13-72-49.5T340-740q0-58 41-99t99-41q58 0 99 41t41 99q0 48-28 84.5T520-606v110l154 153q15-8 31.5-12.5T740-360q58 0 99 41t41 99q0 58-41 99t-99 41q-58 0-99-41t-41-99q0-18 4.5-35t12.5-32L480-424 343-287q8 15 12.5 32t4.5 35q0 58-41 99t-99 41q-58 0-99-41Zm661.5-56.5Q800-195 800-220t-17.5-42.5Q765-280 740-280t-42.5 17.5Q680-245 680-220t17.5 42.5Q715-160 740-160t42.5-17.5Zm-260-520Q540-715 540-740t-17.5-42.5Q505-800 480-800t-42.5 17.5Q420-765 420-740t17.5 42.5Q455-680 480-680t42.5-17.5Zm-260 520Q280-195 280-220t-17.5-42.5Q245-280 220-280t-42.5 17.5Q160-245 160-220t17.5 42.5Q195-160 220-160t42.5-17.5Z"/>
              </svg>
            </div>
            <!-- Title and subtitle -->
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
        <p class="meta-line">
          Created {{ formatDate(concept.createdOn) }} · Last updated {{ formatDate(concept.updatedOn) }}
        </p>
      </section>
    </template>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { getConcept } from '../services/concepts'

const props = defineProps({ id: { type: String, required: true } })

const concept = ref(null)
const loading = ref(true)
const notFound = ref(false)
const showDetails = ref(false)

const relationDetails = reactive({})

function relationLabel(relatedId) {
  if (!relatedId) return 'None'
  const detail = relationDetails[relatedId]
  if (detail === undefined) return relatedId
  return detail ? `${relatedId} — ${detail}` : relatedId
}

function formatDate(isoString) {
  if (!isoString) return '—'
  return new Date(isoString).toLocaleDateString('en-GB', {
    day: 'numeric', month: 'short', year: 'numeric',
  })
}

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

onMounted(async () => {
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
})
</script>