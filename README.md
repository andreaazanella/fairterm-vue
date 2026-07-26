# FAIRterm 2.0 — Vue Migration

Migrazione di FAIRterm 2.0 da R Shiny a un'architettura disaccoppiata:
R + Plumber (backend REST) e Vue.js (frontend).

Tesi triennale — Andrea Zanella, Ingegneria Informatica, Università di Padova.
Relatore: Prof. Giorgio Maria Di Nunzio.

## Struttura

- `backend/` — API Plumber, logica R invariata
- `frontend/` — applicazione Vue 3
- `docs/` — specifica API, modello dati, decisioni architetturali

## Setup

### Backend (opzione da terminale)
```bash
cd backend
Rscript plumber.r
```

### Backend (opzione con Rstudio )
```bash
install.packages("plumber")   # solo la prima volta

setwd("path/to/fairterm-vue/backend")
library(plumber)
pr <- plumb("api.R")
pr$run(port = 8000)
```

### Frontend
```R
cd frontend
npm install     # solo la prima volta
npm run dev
```