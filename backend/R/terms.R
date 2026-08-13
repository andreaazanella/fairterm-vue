# terms.R

# Logica per la risorsa "term" (SELECT/INSERT/UPDATE/DELETE).

# Le funzioni equivalenti dell'app Shiny originale erano sparse tra
# db_functions_select.R / db_functions_insert.R / db_functions_update.R.

# Qui sono raggruppate per risorsa.

# Legenda dei commenti sopra ogni funzione:
# funzione Shiny -> funzione Vue   = portata dall'app originale, eventualmente rinominata
# Nuova funzione                   = non esisteva nell'app Shiny originale

library(DBI)

# --- SELECT ---------------------------------------------------------------

# Nuova funzione
# Converte due vettori paralleli (codici, etichette) in una lista di oggetti
# {value, label} pronta per jsonlite, con unbox già applicato su ogni campo.
buildValueLabelList <- function(values, labels) {
  mapply(function(v, l) {
    list(value = jsonlite::unbox(v), label = jsonlite::unbox(l))
  }, values, labels, SIMPLIFY = FALSE, USE.NAMES = FALSE)
}

# Nuova funzione
# Liste di vocabolario statiche per i campi del termine.
getTermVocabularies <- function() {
  list(
    usageValues = c("preferred term", "admitted term", "deprecated term", "obsolete term"),
    typeValues = c("abbreviation", "acronym", "appellation", "borrowed term", "blend",
                   "complex term", "clipped term", "compound term", "initialism",
                   "multi-word term", "proper name", "simple term", "single-word term", "symbol"),
    posValues = buildValueLabelList(
      c("ADJ", "ADP", "ADV", "AUX", "CCONJ", "DET", "INTJ", "NOUN", "NUM",
        "PART", "PRON", "PROPN", "PUNCT", "SCONJ", "SYM", "VERB", "X"),
      c("adjective", "adposition", "adverb", "auxiliary", "coordinating conjunction",
        "determiner", "interjection", "noun", "numeral", "particle", "pronoun",
        "proper noun", "punctuation", "subordinating conjunction", "symbol", "verb", "other")
    ),
    genderValues = buildValueLabelList(
      c("Com", "Fem", "Mas", "Neut"),
      c("common", "feminine", "masculine", "neuter")
    ),
    numberValues = buildValueLabelList(
      c("Coll", "Count", "Dual", "Grpa", "Grpl", "Inv", "Pauc", "Plur", "Ptan", "Sing", "Tri"),
      c("collective/mass/singulare tantum", "count plural", "dual number", "greater paucal number",
        "greater plural number", "inverse number", "paucal number", "plural number",
        "plurale tantum", "singular number", "trial number")
    )
  )
}

# selectTermsGivenConcept -> getTermsForLanguage
# Nell'originale filtrava solo per concept (tutte le lingue insieme). Qui filtra
# anche per languageCode, perché i termini sono annidati dentro ogni sezione lingua.
getTermsForLanguage <- function(pool, conceptId, languageCode) {
  rows <- dbGetQuery(pool, sqlGetTermsForLanguage, params = list(conceptId, languageCode))

  lapply(seq_len(nrow(rows)), function(i) {
    list(
      id = jsonlite::unbox(rows$id[[i]]),
      designation = jsonlite::unbox(rows$designation[[i]]),
      usage = jsonlite::unbox(naIfBlank(rows$usage[[i]])),
      partOfSpeech = jsonlite::unbox(naIfBlank(rows$part_of_speech[[i]])),
      grammaticalGender = jsonlite::unbox(naIfBlank(rows$grammatical_gender[[i]])),
      grammaticalNumber = jsonlite::unbox(naIfBlank(rows$grammatical_number[[i]])),
      type = jsonlite::unbox(naIfBlank(rows$type[[i]])),
      context = jsonlite::unbox(naIfBlank(rows$context[[i]])),
      externalCrossReference = jsonlite::unbox(naIfBlank(rows$external_cross_reference[[i]])),
      source = jsonlite::unbox(naIfBlank(rows$source[[i]])),
      register = jsonlite::unbox(naIfBlank(rows$register[[i]])),
      collocation = jsonlite::unbox(naIfBlank(rows$collocation[[i]])),
      notes = jsonlite::unbox(naIfBlank(rows$notes[[i]])),
      createdBy = jsonlite::unbox(rows$created_by[[i]]),
      createdOn = jsonlite::unbox(rows$created_on[[i]]),
      updatedBy = jsonlite::unbox(rows$updated_by[[i]]),
      updatedOn = jsonlite::unbox(rows$updated_on[[i]])
    )
  })
}

# Nuova funzione
# Controlla se un termine esiste per una data tripla (id, concept, language).
termExists <- function(pool, termId, conceptId, languageCode) {
  existing <- dbGetQuery(pool, sqlGetTerm, params = list(termId, conceptId, languageCode))
  nrow(existing) > 0
}

# --- INSERT ------------------------------------------------------------

# Nuova funzione
# Genera un id nel formato {concept}_{language}_{numero}, stessa convenzione
# usata nei dati dell'app originale, ma qui è una funzione a sé (nell'originale
# la generazione era inline in server.R).
generateTermId <- function(pool, conceptId, languageCode) {
  repeat {
    candidate <- paste0(conceptId, "_", languageCode, "_", floor(runif(1, min = 0, max = 1000)))
    exists <- dbGetQuery(pool, sqlCheckTermIdExists, params = list(candidate))$n[[1]]
    if (exists == 0) return(candidate)
  }
}

# insertTerm -> insertTerm
# Inserisce un nuovo termine sotto una coppia concetto+lingua.
# Restituisce tutti i termini di quella lingua, aggiornati.
insertTerm <- function(pool, conceptId, languageCode, designation, usage, partOfSpeech,
                        grammaticalGender, grammaticalNumber, type, context,
                        externalCrossReference, source, register, collocation, notes, user) {

  id <- generateTermId(pool, conceptId, languageCode)
  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlInsertTerm, params = list(
    id, conceptId, languageCode, designation, usage %||% "", partOfSpeech %||% "",
    grammaticalGender %||% "", grammaticalNumber %||% "", type %||% "",
    context %||% "", externalCrossReference %||% "", source %||% "",
    register %||% "", collocation %||% "", notes %||% "", user, now, user, now
  ))

  getTermsForLanguage(pool, conceptId, languageCode)
}

# --- UPDATE ------------------------------------------------------------

# updateTerm -> updateTerm
# Aggiorna un termine esistente.
# Restituisce NULL se il termine non esiste per quella coppia concetto/lingua.
updateTerm <- function(pool, termId, conceptId, languageCode, designation, usage, partOfSpeech,
                        grammaticalGender, grammaticalNumber, type, context,
                        externalCrossReference, source, register, collocation, notes, user) {

  if (!termExists(pool, termId, conceptId, languageCode)) return(NULL)

  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")

  dbExecute(pool, sqlUpdateTerm, params = list(
    designation, usage %||% "", partOfSpeech %||% "", grammaticalGender %||% "",
    grammaticalNumber %||% "", type %||% "", context %||% "", externalCrossReference %||% "",
    source %||% "", register %||% "", collocation %||% "", notes %||% "",
    user, now, termId, conceptId, languageCode
  ))

  getTermsForLanguage(pool, conceptId, languageCode)
}

# --- DELETE ------------------------------------------------------------

# Nuova funzione
# Elimina un termine. Restituisce FALSE se non esiste per quella coppia concetto/lingua.
deleteTerm <- function(pool, termId, conceptId, languageCode) {
  if (!termExists(pool, termId, conceptId, languageCode)) return(FALSE)

  dbExecute(pool, sqlDeleteTerm, params = list(termId, conceptId, languageCode))

  TRUE
}