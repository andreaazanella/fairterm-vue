# FAIRterm 2.0 — Vue Migration

Migrazione di FAIRterm 2.0 da R Shiny a un'architettura disaccoppiata:
R + Plumber (backend REST) e Vue.js (frontend).

Tesi triennale — Andrea Zanella, Ingegneria Informatica, Università di Padova.
Relatore: Prof. Giorgio Maria Di Nunzio.

## Struttura

- `backend/` — API Plumber, logica R invariata
- `frontend/` — applicazione Vue 3 (Vite)
- `docs/` — specifica API, modello dati, decisioni architetturali

## Setup

### Backend
```bash
cd backend
# istruzioni Plumber da aggiungere
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```