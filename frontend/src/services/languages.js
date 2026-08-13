import api from './api'

// @POST /concepts/:conceptId/languages
export async function addLanguage(conceptId, payload) {
  const { data } = await api.post(`/concepts/${conceptId}/languages`, payload)
  return data
}

// @PUT /concepts/:conceptId/languages/:languageCode
export async function updateLanguage(conceptId, languageCode, payload) {
  const { data } = await api.put(`/concepts/${conceptId}/languages/${languageCode}`, payload)
  return data
}

// @DELETE /concepts/:conceptId/languages/:languageCode
export async function deleteLanguage(conceptId, languageCode) {
  const { data } = await api.delete(`/concepts/${conceptId}/languages/${languageCode}`)
  return data
}