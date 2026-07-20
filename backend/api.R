# api.R

# Router Plumber.
# [Scope attuale: solo CONCEPT (visualizzazione concetto specifico, creazione, modifica)].

library(plumber)

source("R/db.R")
source("R/concepts.R")
source("sql/statements.R")

pool <- createPool()

# TODO: sostituire con l'utente autenticato reale quando il login sarà collegato
# (nell'app originale è hardcoded a "user0").
currentUser <- "user0"

#* @apiTitle FAIRterm 2.0 API
#* @apiDescription Endpoint REST per la sezione CONCEPT (subject field, subdomain, relazioni).

#* Abilita CORS per lo sviluppo locale.
#* @filter cors
function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", "Content-Type")
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* Liste vocabolario statiche.
#* Per ora solo i subject field (l'unico dato di riferimento che serve alle pagine CONCEPT),
#* languages/usage/POS/... verranno aggiunti qui quando lo scope si allargherà a lingue e termini.
#* @get /reference-data
function() {
  list(subjectFields = getSubjectFields(pool))
}

#* Lista concetti di un dominio (utente corrente).
#* Usata per popolare le select superordinate/subordinate/comprehensive/partitive
#* con gli altri concetti dello stesso subject field.
#* @param subjectField Il subject field da filtrare
#* @get /concepts
function(subjectField = "") {
  if (subjectField == "") {
    return(list())
  }
  getConcepts(pool, subjectField, currentUser)
}

#* Dettaglio di un concetto (senza lingue/termini per ora)
#* @param id L'ID del concetto
#* @get /concepts/<id>
function(id, res) {
  concept <- getConceptById(pool, id)
  if (is.null(concept)) {
    res$status <- 404
    return(list(error = "Concept not found"))
  }
  concept
}

#* Crea un nuovo concetto
#* @parser json
#* @post /concepts
function(req, res) {
  body <- req$body

  if (is.null(body$subjectFields) || length(body$subjectFields) == 0) {
    res$status <- 400
    return(list(error = "At least one subjectField is required"))
  }

  relations <- body$relations %||% list()

  created <- insertConcept(
    pool,
    subjectFields = body$subjectFields,
    subdomain = body$subdomain,
    superordinate = relations$superordinate,
    subordinate = relations$subordinate,
    comprehensive = relations$comprehensive,
    partitive = relations$partitive,
    user = currentUser
  )

  res$status <- 201
  created
}

#* Aggiorna un concetto esistente.
#* subjectField e ID non sono accettati nel body (per design non sono modificabili).
#* @param id L'ID del concetto
#* @parser json
#* @put /concepts/<id>
function(id, req, res) {
  body <- req$body

  if (is.null(body$subjectFields) || length(body$subjectFields) == 0) {
    res$status <- 400
    return(list(error = "At least one subjectField is required"))
  }

  relations <- body$relations %||% list()

  updated <- updateConcept(
    pool,
    id = id,
    subjectFields = body$subjectFields,
    subdomain = body$subdomain,
    superordinate = relations$superordinate,
    subordinate = relations$subordinate,
    comprehensive = relations$comprehensive,
    partitive = relations$partitive,
    user = currentUser
  )

  if (is.null(updated)) {
    res$status <- 404
    return(list(error = "Concept not found"))
  }

  updated
}