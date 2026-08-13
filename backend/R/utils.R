# utils.R

# Helper condivisi tra tutte le risorse (concept, language, term).

# Nuova funzione
# Usa il valore di sinistra se non è NULL/vuoto, altrimenti quello di destra
`%||%` <- function(a, b) {
  if (is.null(a) || length(a) == 0 || (is.character(a) && a == "")) b else a
}

# Nuova funzione
# Converte un valore NULL/vuoto in NA, altrimenti restituisce il valore stesso.
naIfBlank <- function(x) {
  if (is.null(x) || length(x) == 0 || is.na(x) || trimws(x) == "") NA_character_ else x
}