import { createRouter, createWebHistory } from 'vue-router'
import ConceptListView from '../views/ConceptListView.vue'
import ConceptCreateView from '../views/ConceptCreateView.vue'
import ConceptDetailView from '../views/ConceptDetailView.vue'

const routes = [
  { path: '/', redirect: '/concepts' },
  { path: '/concepts', name: 'concept-list', component: ConceptListView },
  { path: '/concepts/new', name: 'concept-create', component: ConceptCreateView },
  { path: '/concepts/:id', name: 'concept-detail', component: ConceptDetailView, props: true },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router