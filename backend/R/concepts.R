# concepts.R

# Logica per la risorsa "concept" (SELECT/INSERT/UPDATE).

# Le funzioni equivalenti dell'app Shiny originale erano sparse tra
# db_functions_select.R / db_functions_insert.R / db_functions_update.R.

# Qui sono raggruppate per risorsa.

# Legenda dei commenti sopra ogni funzione:
#   funzione Shiny -> funzione Vue   = portata dall'app originale, eventualmente rinominata
#   Nuova funzione                   = non esisteva nell'app Shiny originale

library(DBI)

# --- SELECT ---------------------------------------------------------------

# Nuova funzione
# Restituisce la lista di tutti i subject field disponibili.
getSubjectFields <- function(pool) {
  dbGetQuery(pool, sqlGetSubjectFields)
}

# selectConceptsGivenDomain -> getConcepts
# Lista concetti di un dominio, filtrati per utente corrente.
# Usata sia per popolare le select "superordinate/subordinate/comprehensive/partitive"
# (altri concetti dello stesso dominio) sia per la pagina "Concepts".
getConcepts <- function(pool, subjectField, user) {
  dbGetQuery(pool, sqlGetConceptsByDomainUser, params = list(subjectField, user))
}

# Nuova funzione
# Dettaglio di un concetto. Restituisce NULL se non esiste (l'endpoint la traduce in 404).
getConceptById <- function(pool, id) {

  concept <- dbGetQuery(pool, sqlGetConceptById, params = list(id))
  if (nrow(concept) == 0) return(NULL)

  subjectFields <- dbGetQuery(pool, sqlGetSubjectFieldsForConcept, params = list(id))

  list(
    id = jsonlite::unbox(concept$id[[1]]),
    subjectFields = I(subjectFields$subject_field),
    subdomain = jsonlite::unbox(naIfBlank(concept$subdomain[[1]])),
    relations = list(
      superordinate = jsonlite::unbox(naIfBlank(concept$superordinate[[1]])),
      subordinate = jsonlite::unbox(naIfBlank(concept$subordinate[[1]])),
      comprehensive = jsonlite::unbox(naIfBlank(concept$comprehensive[[1]])),
      partitive = jsonlite::unbox(naIfBlank(concept$partitive[[1]]))
    ),
    createdBy = jsonlite::unbox(concept$created_by[[1]]),
    createdOn = jsonlite::unbox(concept$created_on[[1]]),
    updatedBy = jsonlite::unbox(concept$updated_by[[1]]),
    updatedOn = jsonlite::unbox(concept$updated_on[[1]]),
    languages = getLanguagesForConcept(pool, id)
  )
}

# --- INSERT ------------------------------------------------------------

# Nuova funzione
# Genera un id libero. Stessa logica random 0-999 dell'app originale (lì era
# inline in server.R, qui è una funzione a sé), ma con controllo di unicità
# su TUTTO il database invece che solo sul dominio corrente.
generateConceptId <- function(pool) {
  repeat {
    candidate <- as.character(floor(runif(1, min = 0, max = 1000)))
    exists <- dbGetQuery(pool, sqlCheckConceptIdExists, params = list(candidate))$n[[1]]
    if (exists == 0) return(candidate)
  }
}

# insertConcept -> insertConcept
# Inserisce un nuovo concetto. Restituisce il concetto appena creato
# (con tutti i campi, incluso l'id generato).
insertConcept <- function(pool, subjectFields, subdomain, superordinate, subordinate, comprehensive, partitive, user) {

  id <- generateConceptId(pool)
  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlInsertConcept, params = list(
    id, user, now, user, now,
    subdomain %||% "", superordinate %||% "", subordinate %||% "",
    comprehensive %||% "", partitive %||% ""
  ))

  for (subjectField in subjectFields) {
    dbExecute(pool, sqlInsertConceptSubject, params = list(id, subjectField))
  }

  getConceptById(pool, id)
}

# --- UPDATE ------------------------------------------------------------

# updateConcept -> updateConcept
# Aggiorna un concetto esistente. Restituisce NULL se il concetto non esiste.
updateConcept <- function(pool, id, subjectFields, subdomain, superordinate, subordinate, comprehensive, partitive, user) {

  existing <- getConceptById(pool, id)
  if (is.null(existing)) return(NULL)

  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlUpdateConcept, params = list(
    user, now, subdomain %||% "", superordinate %||% "", subordinate %||% "",
    comprehensive %||% "", partitive %||% "", id
  ))

  dbExecute(pool, sqlDeleteConceptSubjects, params = list(id))

  for (subjectField in subjectFields) {
    dbExecute(pool, sqlInsertConceptSubject, params = list(id, subjectField))
  }

  getConceptById(pool, id)
}

# --- DELETE ------------------------------------------------------------

# (non ancora implementata)