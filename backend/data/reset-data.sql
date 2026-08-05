-- reset-full-test-data.sql
-- Reset completo di concept, concept_subject, concept_language, term.
-- user, subject_field, language NON vengono toccate.
-- 6 concetti (101-105 di user0, 106 di user1), con lingue e termini
-- distribuiti in modo non uniforme per coprire i casi limite (concetti senza
-- lingue, con una lingua, con più lingue, termini singoli e multipli).

DELETE FROM concept;
DELETE FROM concept_subject;
DELETE FROM concept_language;
DELETE FROM term;

-- === CONCEPT ===

INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive) VALUES
('101', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z', 'machine learning', '102', '', '', ''),
('102', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z', 'artificial intelligence', '', '101', '', ''),
('103', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z', 'data protection', '', '', '', ''),
('104', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z', 'open science', '', '', '103', ''),
('105', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z', '', '', '', '', ''),
('106', 'user1', '2026-07-20T09:00:00Z', 'user1', '2026-07-20T09:00:00Z', 'quantum computing', '', '', '', '102');

-- === CONCEPT_SUBJECT ===

INSERT INTO concept_subject (concept, subject_field) VALUES
('101', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('102', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('102', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('103', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('103', '1236 - rights and freedoms (12 - LAW)'),
('104', '6416 - research and intellectual property (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('105', '3606 - natural and applied sciences (36 - SCIENCE)'),
('106', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)');

-- === CONCEPT_LANGUAGE ===
-- 103 e 105 restano SENZA lingue: casi limite per il frontend (sezione vuota).

INSERT INTO concept_language (concept, language, created_by, created_on, updated_by, updated_on, definition, external_cross_reference, source, notes) VALUES
('101', 'en', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z',
 'A graphical structure used to represent decisions and their possible consequences.', '', 'ISO/IEC 2382-1:1993, 2127', 'Used in computer science and statistics.'),
('101', 'fr', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z',
 'Structure graphique utilisée pour représenter des décisions.', '', '', ''),
('102', 'en', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z',
 'A procedure that assigns a category label to new observations based on training data.', '', '', ''),
('104', 'en', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z',
 'A movement to make scientific research and data openly accessible to society.', 'https://en.wikipedia.org/wiki/Open_science', '', ''),
('106', 'en', 'user1', '2026-07-20T09:00:00Z', 'user1', '2026-07-20T09:00:00Z',
 'Computation that exploits quantum-mechanical phenomena to process information.', '', '', '');

-- === TERM ===
-- id nel formato {concept}_{language}_{numero}, stessa convenzione dell'app originale.

INSERT INTO term (id, concept, language, designation, usage, part_of_speech, grammatical_gender, grammatical_number, type, context, external_cross_reference, source, register, collocation, notes, created_by, created_on, updated_by, updated_on) VALUES
('101_en_318', '101', 'en', 'decision tree', 'preferred term', 'noun', '', 'singular', 'compound term',
 'A decision tree can be visualized as a flowchart-like structure.', '', 'ISO/IEC 2382-1:1993, 2127', 'technical',
 'build a decision tree, prune a decision tree', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('101_en_552', '101', 'en', 'decision-making tree', 'admitted term', 'noun', '', 'singular', 'compound term',
 '', '', '', '', '', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('101_fr_104', '101', 'fr', 'arbre de décision', 'preferred term', 'noun', 'masculine', 'singular', 'compound term',
 '', '', '', '', '', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('102_en_771', '102', 'en', 'classification algorithm', 'preferred term', 'noun', '', 'singular', 'multi-word term',
 '', '', '', '', '', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('104_en_209', '104', 'en', 'open science', 'preferred term', 'noun', '', 'singular', 'compound term',
 '', '', '', '', '', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('104_en_640', '104', 'en', 'open research', 'admitted term', 'noun', '', 'singular', 'compound term',
 '', '', '', '', '', '', 'user0', '2026-07-20T09:00:00Z', 'user0', '2026-07-20T09:00:00Z'),
('106_en_053', '106', 'en', 'quantum computing', 'preferred term', 'noun', '', 'singular', 'compound term',
 '', '', '', '', '', '', 'user1', '2026-07-20T09:00:00Z', 'user1', '2026-07-20T09:00:00Z');