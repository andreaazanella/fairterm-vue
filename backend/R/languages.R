# languages.R

# Logica per la risorsa "language" (SELECT/INSERT/UPDATE).

# Le funzioni equivalenti dell'app Shiny originale erano sparse tra
# db_functions_select.R / db_functions_insert.R / db_functions_update.R.

# Qui sono raggruppate per risorsa.

# Legenda dei commenti sopra ogni funzione:
#   funzione Shiny -> funzione Vue   = portata dall'app originale, eventualmente rinominata
#   Nuova funzione                   = non esisteva nell'app Shiny originale

library(DBI)

# --- SELECT ---------------------------------------------------------------

# Nuova funzione
# Restituisce la lista di tutte le lingue disponibili (codice ISO + nome).
getLanguages <- function(pool) {
  dbGetQuery(pool, sqlGetLanguages)
}

# selectLanguagesGivenConcept -> getLanguagesForConcept
# Lista delle sezioni lingua associate a un concetto, con i rispettivi
# termini annidati dentro ciascuna (vedi terms = ... in fondo al list()).
getLanguagesForConcept <- function(pool, conceptId) {
  rows <- dbGetQuery(pool, sqlGetLanguagesForConcept, params = list(conceptId))

  lapply(seq_len(nrow(rows)), function(i) {
    list(
      language = jsonlite::unbox(rows$language[[i]]),
      definition = jsonlite::unbox(naIfBlank(rows$definition[[i]])),
      externalCrossReference = jsonlite::unbox(naIfBlank(rows$external_cross_reference[[i]])),
      source = jsonlite::unbox(naIfBlank(rows$source[[i]])),
      notes = jsonlite::unbox(naIfBlank(rows$notes[[i]])),
      createdBy = jsonlite::unbox(rows$created_by[[i]]),
      createdOn = jsonlite::unbox(rows$created_on[[i]]),
      updatedBy = jsonlite::unbox(rows$updated_by[[i]]),
      updatedOn = jsonlite::unbox(rows$updated_on[[i]]),
      terms = getTermsForLanguage(pool, conceptId, rows$language[[i]])
    )
  })
}

# Nuova funzione
# Controlla se una lingua è già associata a un concetto (evita duplicati in insert).
languageExistsForConcept <- function(pool, conceptId, languageCode) {
  existing <- dbGetQuery(pool, sqlGetConceptLanguage, params = list(conceptId, languageCode))
  nrow(existing) > 0
}

# --- INSERT ------------------------------------------------------------

# insertConceptLanguage -> insertConceptLanguage
# Aggiunge una sezione lingua a un concetto.
# Restituisce list(error = "language_exists") se già presente, altrimenti
# list(error = NULL, languages = ...) con tutte le lingue del concetto aggiornate.
insertConceptLanguage <- function(pool, conceptId, languageCode, definition, externalCrossReference, source, notes, user) {
  if (languageExistsForConcept(pool, conceptId, languageCode)) {
    return(list(error = "language_exists"))
  }

  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlInsertConceptLanguage, params = list(
    conceptId, languageCode, user, now, user, now,
    definition %||% "", externalCrossReference %||% "", source %||% "", notes %||% ""
  ))

  list(error = NULL, languages = getLanguagesForConcept(pool, conceptId))
}

# --- UPDATE ------------------------------------------------------------

# updateLanguage -> updateConceptLanguage
# Aggiorna una sezione lingua esistente (il codice lingua non è modificabile).
# Restituisce NULL se la lingua non è associata al concetto.
updateConceptLanguage <- function(pool, conceptId, languageCode, definition, externalCrossReference, source, notes, user) {
  if (!languageExistsForConcept(pool, conceptId, languageCode)) {
    return(NULL)
  }

  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlUpdateConceptLanguage, params = list(
    user, now, definition %||% "", externalCrossReference %||% "", source %||% "",
    notes %||% "", conceptId, languageCode
  ))

  getLanguagesForConcept(pool, conceptId)
}

# --- DELETE ------------------------------------------------------------

# Nuova funzione
# Elimina una sezione lingua e, in cascata, tutti i suoi termini.
# Restituisce FALSE se la lingua non è associata al concetto.
deleteConceptLanguage <- function(pool, conceptId, languageCode) {
  if (!languageExistsForConcept(pool, conceptId, languageCode)) return(FALSE)

  dbExecute(pool, sqlDeleteTermsForLanguage, params = list(conceptId, languageCode))
  dbExecute(pool, sqlDeleteConceptLanguage, params = list(conceptId, languageCode))

  TRUE
}