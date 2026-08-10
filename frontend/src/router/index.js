import { createRouter, createWebHistory } from 'vue-router'
import ConceptListView from '../views/ConceptListView.vue'
import ConceptCreateView from '../views/ConceptCreateView.vue'
import ConceptDetailView from '../views/ConceptDetailView.vue'

const routes = [
  // Redirect di default: la pagina "Concetti" è la home dell'app
  { path: '/', redirect: '/concepts' },
  // Lista concetti (non ancora implementata, solo segnaposto)
  { path: '/concepts', name: 'concept-list', component: ConceptListView },
  // Creazione di un nuovo concetto
  { path: '/concepts/new', name: 'concept-create', component: ConceptCreateView },
  // Dettaglio di un concetto esistente, id passato come prop
  { path: '/concepts/:id', name: 'concept-detail', component: ConceptDetailView, props: true },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router