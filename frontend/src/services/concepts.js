import api from './api'

// @GET /concepts
export async function listConcepts(subjectField) {
  const { data } = await api.get('/concepts', { params: { subjectField } })
  return data
}

// @GET /concepts/:id
export async function getConcept(id) {
  const { data } = await api.get(`/concepts/${id}`)
  return data
}

// @POST /concepts
export async function createConcept(payload) {
  const { data } = await api.post('/concepts', payload)
  return data
}

// @PUT /concepts/:id
export async function updateConcept(id, payload) {
  const { data } = await api.put(`/concepts/${id}`, payload)
  return data
}

// @DELETE /concepts/:id
export async function deleteConcept(id) {
  const { data } = await api.delete(`/concepts/${id}`)
  return data
}