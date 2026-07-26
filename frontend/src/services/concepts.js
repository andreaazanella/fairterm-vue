import api from './api'

export async function listConcepts(subjectField) {
  const { data } = await api.get('/concepts', { params: { subjectField } })
  return data
}

export async function getConcept(id) {
  const { data } = await api.get(`/concepts/${id}`)
  return data
}

export async function createConcept(payload) {
  const { data } = await api.post('/concepts', payload)
  return data
}

export async function updateConcept(id, payload) {
  const { data } = await api.put(`/concepts/${id}`, payload)
  return data
}