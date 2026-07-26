# concepts.R

# Logica per la risorsa "concept" (SELECT/INSERT/UPDATE).
# [Scope attuale: solo campi di livello concetto (subject_field, subdomain, relazioni)].
# Le funzioni equivalenti dell'app Shiny originale erano sparse tra
# db_functions_select.R / db_functions_insert.R / db_functions_update.R.
# Qui sono raggruppate per risorsa.

library(DBI)

# Usa il valore di sinistra se non è NULL/vuoto, altrimenti quello di destra
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0 || (is.character(a) && a == "")) b else a
}

# Converte una stringa vuota/NA in NULL, per non restituire " " al frontend
# al posto di un vero "nessun valore"
naIfBlank <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x) || trimws(x) == "") NULL else x
}

# --- SELECT ---------------------------------------------------------------

getSubjectFields <- function(pool) {
  dbGetQuery(pool, sqlGetSubjectFields)
}

# Lista concetti di un dominio, filtrati per utente corrente.
# Usata sia per popolare le select "superordinate/subordinate/comprehensive/partitive"
# (altri concetti dello stesso dominio) sia per la pagina "Concepts".
getConcepts <- function(pool, subjectField, user) {
  dbGetQuery(pool, sqlGetConceptsByDomainUser, params = list(subjectField, user))
}
 
# Dettaglio di un concetto. Restituisce NULL se non esiste (l'endpoint la traduce in 404).
getConceptById <- function(pool, id) {

  concept <- dbGetQuery(pool, sqlGetConceptById, params = list(id))
  if (nrow(concept) == 0) return(NULL)

  subjectFields <- dbGetQuery(pool, sqlGetSubjectFieldsForConcept, params = list(id))

  list(
    id = concept$id[[1]],
    subjectFields = I(subjectFields$subject_field),
    subdomain = naIfBlank(concept$subdomain[[1]]),
    relations = list(
      superordinate = naIfBlank(concept$superordinate[[1]]),
      subordinate = naIfBlank(concept$subordinate[[1]]),
      comprehensive = naIfBlank(concept$comprehensive[[1]]),
      partitive = naIfBlank(concept$partitive[[1]])
    ),
    createdBy = concept$created_by[[1]],
    createdOn = concept$created_on[[1]],
    updatedBy = concept$updated_by[[1]],
    updatedOn = concept$updated_on[[1]]
  )
}

# --- INSERT ----------------------------------------------------------------

# Genera un ID.
# Stessa logica random 0-999 dell'app originale, ma con controllo
# di unicità su TUTTO il database invece che solo sul dominio corrente.
generateConceptId <- function(pool) {
  repeat {
    candidate <- as.character(floor(runif(1, min = 0, max = 1000)))
    exists <- dbGetQuery(pool, sqlCheckConceptIdExists, params = list(candidate))$n[[1]]
    if (exists == 0) return(candidate)
  }
}

# Inserisce un nuovo concetto.
# Restituisce il concetto appena creato (con tutti i campi, incluso id).
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

# Aggiorna un concetto esistente.
# Restituisce NULL se il concetto non esiste.
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