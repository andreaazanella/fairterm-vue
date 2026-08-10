import axios from 'axios'

// Istanza axios condivisa da tutti i services: baseURL da variabile
// d'ambiente, con fallback al backend locale se non impostata
const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000',
})

export default api