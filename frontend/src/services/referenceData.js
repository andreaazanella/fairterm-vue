import api from './api'

// @GET /reference-data
export async function fetchReferenceData() {
  const { data } = await api.get('/reference-data')
  return data
}