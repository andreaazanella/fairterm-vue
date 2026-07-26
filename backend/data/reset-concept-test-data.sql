-- reset-concept-test-data.sql
-- Svuota e ripopola SOLO concept e concept_subject con 5 concetti di test verosimili.
-- user, subject_field, language non vengono toccate.
--
-- Eseguibile da DB Browser for SQLite: apri temp.db -> tab "Execute SQL" -> incolla -> Execute.

DELETE FROM concept;
DELETE FROM concept_subject;

-- 101: singolo subject field, ha un superordinate (-> 102)
INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
VALUES ('101', 'user0', '2026-07-18T15:00:00Z', 'user0', '2026-07-18T15:00:00Z', 'machine learning', '102', '', '', '');

-- 102: DUE subject field, ha un subordinate (-> 101)
INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
VALUES ('102', 'user0', '2026-07-18T15:00:00Z', 'user0', '2026-07-18T15:00:00Z', 'artificial intelligence', '', '101', '', '');

-- 103: DUE subject field, nessuna relazione
INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
VALUES ('103', 'user0', '2026-07-18T15:00:00Z', 'user0', '2026-07-18T15:00:00Z', 'data protection', '', '', '', '');

-- 104: singolo subject field, ha un comprehensive (-> 103)
INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
VALUES ('104', 'user0', '2026-07-18T15:00:00Z', 'user0', '2026-07-18T15:00:00Z', 'open science', '', '', '103', '');

-- 105: creato da user1 (per testare il filtro created_by), subdomain vuoto
INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive)
VALUES ('105', 'user1', '2026-07-18T15:00:00Z', 'user1', '2026-07-18T15:00:00Z', '', '', '', '', '');

INSERT INTO concept_subject (concept, subject_field) VALUES
  ('101', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
  ('102', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
  ('102', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
  ('103', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
  ('103', '1236 - rights and freedoms (12 - LAW)'),
  ('104', '6416 - research and intellectual property (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
  ('105', '3606 - natural and applied sciences (36 - SCIENCE)');
