import api from './api'

// @POST /concepts/:conceptId/languages/:languageCode/terms
export async function addTerm(conceptId, languageCode, payload) {
  const { data } = await api.post(`/concepts/${conceptId}/languages/${languageCode}/terms`, payload)
  return data
}

// @PUT /concepts/:conceptId/languages/:languageCode/terms/:termId
export async function updateTerm(conceptId, languageCode, termId, payload) {
  const { data } = await api.put(`/concepts/${conceptId}/languages/${languageCode}/terms/${termId}`, payload)
  return data
}

// @DELETE /concepts/:conceptId/languages/:languageCode/terms/:termId
export async function deleteTerm(conceptId, languageCode, termId) {
  const { data } = await api.delete(`/concepts/${conceptId}/languages/${languageCode}/terms/${termId}`)
  return data
}