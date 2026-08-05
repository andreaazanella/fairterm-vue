# statements.R

# Query parametrizzate.
# [Scope attuale: solo CONCEPT (subject_field, subdomain, relazioni)].
# Le query equivalenti dell'app Shiny originale erano dentro sql_statements.R.

sqlGetSubjectFields <- "
  SELECT name, description
  FROM subject_field
  ORDER BY name
"

# Concetti di un dominio, filtrati per utente corrente (stessa logica dell'app Shiny originale:
# selectConceptsGivenDomain filtrava per subject_field + created_by)
sqlGetConceptsByDomainUser <- "
  SELECT c.id, c.subdomain, c.updated_on
  FROM concept c
  INNER JOIN concept_subject cs ON c.id = cs.concept
  WHERE cs.subject_field = ? AND c.created_by = ?
  ORDER BY c.id
"

sqlGetConceptById <- "
  SELECT id, created_by, created_on, updated_by, updated_on,
         subdomain, superordinate, subordinate, comprehensive, partitive
  FROM concept
  WHERE id = ?
"

sqlGetSubjectFieldsForConcept <- "
  SELECT subject_field
  FROM concept_subject
  WHERE concept = ?
"

sqlInsertConcept <- "
  INSERT INTO concept
    (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

sqlInsertConceptSubject <- "
  INSERT INTO concept_subject (concept, subject_field)
  VALUES (?, ?)
"

# Elimina tutti i subject field di un concetto, usata da updateConcept per il
# pattern "sostituisci tutto l'insieme" (delete + re-insert) quando l'utente
# modifica quali subject field sono associati
sqlDeleteConceptSubjects <- "
  DELETE FROM concept_subject
  WHERE concept = ?
"

sqlUpdateConcept <- "
  UPDATE concept
  SET updated_by = ?, updated_on = ?, subdomain = ?,
      superordinate = ?, subordinate = ?, comprehensive = ?, partitive = ?
  WHERE id = ?
"

sqlCheckConceptIdExists <- "
  SELECT COUNT(*) AS n
  FROM concept
  WHERE id = ?
"

# query per la risorsa "language" (tabella concept_language)

sqlGetLanguages <- "
  SELECT id, name
  FROM language
  ORDER BY name
"

sqlGetLanguagesForConcept <- "
  SELECT concept, language, created_by, created_on, updated_by, updated_on,
         definition, external_cross_reference, source, notes
  FROM concept_language
  WHERE concept = ?
  ORDER BY language
"

sqlGetConceptLanguage <- "
  SELECT concept, language
  FROM concept_language
  WHERE concept = ? AND language = ?
"

sqlInsertConceptLanguage <- "
  INSERT INTO concept_language
    (concept, language, created_by, created_on, updated_by, updated_on, definition, external_cross_reference, source, notes)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

sqlUpdateConceptLanguage <- "
  UPDATE concept_language
  SET updated_by = ?, updated_on = ?, definition = ?, external_cross_reference = ?, source = ?, notes = ?
  WHERE concept = ? AND language = ?
"

# query per la risorsa "term" (tabella term)

sqlGetTermsForLanguage <- "
  SELECT id, concept, language, designation, usage, part_of_speech, grammatical_gender,
         grammatical_number, type, context, external_cross_reference, source, register,
         collocation, notes, created_by, created_on, updated_by, updated_on
  FROM term
  WHERE concept = ? AND language = ?
  ORDER BY id
"

sqlGetTerm <- "
  SELECT id
  FROM term
  WHERE id = ? AND concept = ? AND language = ?
"

sqlInsertTerm <- "
  INSERT INTO term
    (id, concept, language, designation, usage, part_of_speech, grammatical_gender,
     grammatical_number, type, context, external_cross_reference, source, register,
     collocation, notes, created_by, created_on, updated_by, updated_on)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
"

sqlUpdateTerm <- "
  UPDATE term
  SET designation = ?, usage = ?, part_of_speech = ?, grammatical_gender = ?,
      grammatical_number = ?, type = ?, context = ?, external_cross_reference = ?,
      source = ?, register = ?, collocation = ?, notes = ?, updated_by = ?, updated_on = ?
  WHERE id = ? AND concept = ? AND language = ?
"

sqlCheckTermIdExists <- "
  SELECT COUNT(*) AS n
  FROM term
  WHERE id = ?
"