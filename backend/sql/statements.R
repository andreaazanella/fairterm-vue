# statements.R

# Query parametrizzate, raggruppate per risorsa (concept/language/term) e,
# dentro ciascuna, per operazione (SELECT/INSERT/UPDATE/DELETE).

# Le funzioni equivalenti dell'app Shiny originale erano demtrp sql_statements.R.

# --- CONCEPTS ---------------------------------------------------------------

# --- SELECT ---

# Tutti i subject field disponibili.
sqlGetSubjectFields <- "
  SELECT name, description
  FROM subject_field
  ORDER BY name
"

# Concetti di un dominio, filtrati per utente corrente.
sqlGetConceptsByDomainUser <- "
  SELECT c.id, c.subdomain, c.updated_on
  FROM concept c
  INNER JOIN concept_subject cs ON c.id = cs.concept
  WHERE cs.subject_field = ? AND c.created_by = ?
  ORDER BY c.id
"

# Dettaglio di un concetto per id.
sqlGetConceptById <- "
  SELECT id, created_by, created_on, updated_by, updated_on,
         subdomain, superordinate, subordinate, comprehensive, partitive
  FROM concept
  WHERE id = ?
"

# Subject field associati a un concetto.
sqlGetSubjectFieldsForConcept <- "
  SELECT subject_field
  FROM concept_subject
  WHERE concept = ?
"

# Verifica se un id concetto è già in uso (per la generazione con retry).
sqlCheckConceptIdExists <- "
  SELECT COUNT(*) AS n
  FROM concept
  WHERE id = ?
"

# --- INSERT ---

# Crea un nuovo concetto.
sqlInsertConcept <- "
  INSERT INTO concept
    (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

# Associa un subject field a un concetto (una riga per ogni field, il concetto
# può averne più di uno).
sqlInsertConceptSubject <- "
  INSERT INTO concept_subject (concept, subject_field)
  VALUES (?, ?)
"

# --- UPDATE ---

# Aggiorna i campi di un concetto esistente (subject field escluso: si aggiorna
# a parte con delete+reinsert, vedi sotto).
sqlUpdateConcept <- "
  UPDATE concept
  SET updated_by = ?, updated_on = ?, subdomain = ?,
      superordinate = ?, subordinate = ?, comprehensive = ?, partitive = ?
  WHERE id = ?
"

# Elimina tutti i subject field di un concetto: usata da updateConcept per il
# pattern "sostituisci tutto l'insieme" (delete + re-insert) quando l'utente
# modifica quali subject field sono associati.
sqlDeleteConceptSubjects <- "
  DELETE FROM concept_subject
  WHERE concept = ?
"

# --- DELETE ---

# Elimina tutti i termini di un concetto (cascata da deleteConcept).
sqlDeleteTermsForConcept <- "DELETE FROM term WHERE concept = ?"

# Elimina tutte le sezioni lingua di un concetto (cascata da deleteConcept).
sqlDeleteConceptLanguagesForConcept <- "DELETE FROM concept_language WHERE concept = ?"

# Elimina il concetto stesso.
sqlDeleteConcept <- "DELETE FROM concept WHERE id = ?"

# Ripulisce il riferimento da altri concetti che puntavano a quello appena
# eliminato — una query per ciascuna delle 4 relazioni.
sqlClearSuperordinateReferences <- "UPDATE concept SET superordinate = '' WHERE superordinate = ?"
sqlClearSubordinateReferences <- "UPDATE concept SET subordinate = '' WHERE subordinate = ?"
sqlClearComprehensiveReferences <- "UPDATE concept SET comprehensive = '' WHERE comprehensive = ?"
sqlClearPartitiveReferences <- "UPDATE concept SET partitive = '' WHERE partitive = ?"

# --- LANGUAGES ---------------------------------------------------------------

# --- SELECT ---

# Tutte le lingue disponibili (codice ISO + nome).
sqlGetLanguages <- "
  SELECT id, name
  FROM language
  ORDER BY name
"

# Sezioni lingua di un concetto.
sqlGetLanguagesForConcept <- "
  SELECT concept, language, created_by, created_on, updated_by, updated_on,
         definition, external_cross_reference, source, notes
  FROM concept_language
  WHERE concept = ?
  ORDER BY language
"

# Verifica se una lingua è già associata a un concetto (controllo duplicati).
sqlGetConceptLanguage <- "
  SELECT concept, language
  FROM concept_language
  WHERE concept = ? AND language = ?
"

# --- INSERT ---

# Aggiunge una sezione lingua a un concetto.
sqlInsertConceptLanguage <- "
  INSERT INTO concept_language
    (concept, language, created_by, created_on, updated_by, updated_on, definition, external_cross_reference, source, notes)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

# --- UPDATE ---

# Aggiorna una sezione lingua esistente (il codice lingua non è modificabile,
# infatti non compare nella SET).
sqlUpdateConceptLanguage <- "
  UPDATE concept_language
  SET updated_by = ?, updated_on = ?, definition = ?, external_cross_reference = ?, source = ?, notes = ?
  WHERE concept = ? AND language = ?
"

# --- DELETE ---

# Elimina tutti i termini di una lingua (cascata da deleteConceptLanguage).
sqlDeleteTermsForLanguage <- "DELETE FROM term WHERE concept = ? AND language = ?"

# Elimina la sezione lingua stessa.
sqlDeleteConceptLanguage <- "DELETE FROM concept_language WHERE concept = ? AND language = ?"

# --- TERMS ---------------------------------------------------------------

# --- SELECT ---

# Termini di una coppia concetto+lingua.
sqlGetTermsForLanguage <- "
  SELECT id, concept, language, designation, usage, part_of_speech, grammatical_gender,
         grammatical_number, type, context, external_cross_reference, source, register,
         collocation, notes, created_by, created_on, updated_by, updated_on
  FROM term
  WHERE concept = ? AND language = ?
  ORDER BY id
"

# Verifica se un termine esiste per quella coppia concetto/lingua.
sqlGetTerm <- "
  SELECT id
  FROM term
  WHERE id = ? AND concept = ? AND language = ?
"

# Verifica se un id termine è già in uso (per la generazione con retry).
sqlCheckTermIdExists <- "
  SELECT COUNT(*) AS n
  FROM term
  WHERE id = ?
"

# --- INSERT ---

# Crea un nuovo termine.
sqlInsertTerm <- "
  INSERT INTO term
    (id, concept, language, designation, usage, part_of_speech, grammatical_gender,
     grammatical_number, type, context, external_cross_reference, source, register,
     collocation, notes, created_by, created_on, updated_by, updated_on)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

# --- UPDATE ---

# Aggiorna un termine esistente (concept e language non sono modificabili,
# infatti non compaiono nella SET, solo nella WHERE).
sqlUpdateTerm <- "
  UPDATE term
  SET designation = ?, usage = ?, part_of_speech = ?, grammatical_gender = ?,
      grammatical_number = ?, type = ?, context = ?, external_cross_reference = ?,
      source = ?, register = ?, collocation = ?, notes = ?, updated_by = ?, updated_on = ?
  WHERE id = ? AND concept = ? AND language = ?
"

# --- DELETE ---

# Elimina un termine.
sqlDeleteTerm <- "DELETE FROM term WHERE id = ? AND concept = ? AND language = ?"