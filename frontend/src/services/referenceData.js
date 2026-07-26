import api from './api'

export async function fetchReferenceData() {
  const { data } = await api.get('/reference-data')
  return data
}