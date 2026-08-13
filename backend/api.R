# api.R

# Router Plumber.

# Scope attuale: CONCEPT (visualizzazione, creazione, modifica) e LANGUAGE/TERM
# annidati sotto un concetto (aggiunta e modifica).

library(plumber)

source("R/db.R")
source("R/utils.R")
source("R/concepts.R")
source("R/languages.R")
source("R/terms.R")
source("sql/statements.R")

pool <- createPool()

currentUser <- "user0"

#* @apiTitle FAIRterm 2.0 API
#* @apiDescription Endpoint REST per concept (subject field, subdomain, relazioni), language e term.

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

#* Elenco delle voci di riferimento statiche: subject field, lingue, e i cinque
#* vocabolari del termine (usage, type, part of speech, grammatical gender/number).
#* @get /reference-data
function() {
  vocab <- getTermVocabularies()
  list(
    subjectFields = getSubjectFields(pool),
    languages = getLanguages(pool),
    usageValues = vocab$usageValues,
    typeValues = vocab$typeValues,
    posValues = vocab$posValues,
    genderValues = vocab$genderValues,
    numberValues = vocab$numberValues
  )
}

# --- CONCEPTS ---------------------------------------------------------------

#* Elenco dei concetti di un dominio per l'utente corrente.
#* Viene usato per popolare le select superordinate, subordinate, comprehensive e partitive
#* con gli altri concetti dello stesso subject field.
#* @param subjectField Il subject field da filtrare.
#* @get /concepts
function(subjectField = "") {
  if (subjectField == "") {
    return(list())
  }
  getConcepts(pool, subjectField, currentUser)
}

#* Dettaglio di un concetto, con lingue e termini annidati.
#* @param id L'ID del concetto.
#* @get /concepts/<id>
function(id, res) {
  concept <- getConceptById(pool, id)
  if (is.null(concept)) {
    res$status <- 404
    return(list(error = "Concept not found"))
  }
  concept
}

#* Crea un nuovo concetto.
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
#* @param id L'ID del concetto.
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

#* Elimina un concetto (cascata su subject field, lingue, termini; ripulisce
#* anche i riferimenti da altri concetti che lo referenziavano).
#* @param id ID del concetto.
#* @delete /concepts/<id>
function(id, res) {
  deleted <- deleteConcept(pool, id)
  if (!deleted) {
    res$status <- 404
    return(list(error = "Concept not found"))
  }
  list(deleted = jsonlite::unbox(TRUE))
}

# --- LANGUAGES ---------------------------------------------------------------

#* Aggiunge una nuova lingua a un concetto.
#* @param id ID del concetto.
#* @parser json
#* @post /concepts/<id>/languages
function(id, req, res) {
  body <- req$body

  if (is.null(body$language) || body$language == "") {
    res$status <- 400
    return(list(error = "language is required"))
  }
  if (is.null(body$definition) || body$definition == "") {
    res$status <- 400
    return(list(error = "definition is required"))
  }

  concept <- getConceptById(pool, id)
  if (is.null(concept)) {
    res$status <- 404
    return(list(error = "Concept not found"))
  }

  result <- insertConceptLanguage(
    pool, id, body$language, body$definition,
    body$externalCrossReference, body$source, body$notes, currentUser
  )

  if (!is.null(result$error)) {
    res$status <- 409
    return(list(error = "This language is already associated with the concept"))
  }

  res$status <- 201
  list(languages = result$languages)
}

#* Aggiorna una lingua esistente associata a un concetto.
#* Restituisce 404 se la lingua non è associata al concetto.
#* @param id ID del concetto.
#* @param code Codice della lingua.
#* @parser json
#* @put /concepts/<id>/languages/<code>
function(id, code, req, res) {
  body <- req$body

  updated <- updateConceptLanguage(
    pool, id, code, body$definition, body$externalCrossReference, body$source, body$notes, currentUser
  )

  if (is.null(updated)) {
    res$status <- 404
    return(list(error = "Language not found for this concept"))
  }

  list(languages = updated)
}

#* Elimina una lingua associata a un concetto (cascata sui suoi termini).
#* @param id ID del concetto.
#* @param code Codice della lingua.
#* @delete /concepts/<id>/languages/<code>
function(id, code, res) {
  deleted <- deleteConceptLanguage(pool, id, code)
  if (!deleted) {
    res$status <- 404
    return(list(error = "Language not found for this concept"))
  }
  list(deleted = jsonlite::unbox(TRUE))
}

# --- TERMS ---------------------------------------------------------------

#* Aggiunge un nuovo termine a una sezione lingua.
#* @param id ID del concetto.
#* @param code Codice della lingua.
#* @parser json
#* @post /concepts/<id>/languages/<code>/terms
function(id, code, req, res) {
  body <- req$body

  if (is.null(body$designation) || body$designation == "") {
    res$status <- 400
    return(list(error = "designation is required"))
  }
  if (is.null(body$usage) || body$usage == "") {
    res$status <- 400
    return(list(error = "usage is required"))
  }

  terms <- insertTerm(
    pool, id, code, body$designation, body$usage, body$partOfSpeech,
    body$grammaticalGender, body$grammaticalNumber, body$type, body$context,
    body$externalCrossReference, body$source, body$register, body$collocation, body$notes,
    currentUser
  )

  res$status <- 201
  list(terms = terms)
}

#* Aggiorna un termine esistente. Concept e language non sono modificabili.
#* Restituisce 404 se il termine non è associato a questo concetto/lingua.
#* @param id ID del concetto.
#* @param code Codice della lingua.
#* @param termId ID del termine.
#* @parser json
#* @put /concepts/<id>/languages/<code>/terms/<termId>
function(id, code, termId, req, res) {
  body <- req$body

  if (is.null(body$designation) || body$designation == "") {
    res$status <- 400
    return(list(error = "designation is required"))
  }
  if (is.null(body$usage) || body$usage == "") {
    res$status <- 400
    return(list(error = "usage is required"))
  }

  updated <- updateTerm(
    pool, termId, id, code, body$designation, body$usage, body$partOfSpeech,
    body$grammaticalGender, body$grammaticalNumber, body$type, body$context,
    body$externalCrossReference, body$source, body$register, body$collocation, body$notes,
    currentUser
  )

  if (is.null(updated)) {
    res$status <- 404
    return(list(error = "Term not found for this concept/language"))
  }

  list(terms = updated)
}

#* Elimina un termine.
#* @param id ID del concetto.
#* @param code Codice della lingua.
#* @param termId ID del termine.
#* @delete /concepts/<id>/languages/<code>/terms/<termId>
function(id, code, termId, res) {
  deleted <- deleteTerm(pool, termId, id, code)
  if (!deleted) {
    res$status <- 404
    return(list(error = "Term not found for this concept/language"))
  }
  list(deleted = jsonlite::unbox(TRUE))
}