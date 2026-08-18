-- reset-rich-test-data.sql
-- Dataset completo di test: 10 concetti, relazioni incrociate, lingue multiple,
-- termini con metadati ricchi (incluso il campo type multi-valore).
-- user, subject_field, language NON vengono toccate.

DELETE FROM concept;
DELETE FROM concept_subject;
DELETE FROM concept_language;
DELETE FROM term;

-- === CONCEPT ===
-- Rete di relazioni: 101<->102 (superordinate/subordinate), 102->103 (comprehensive),
-- 103->102 (partitive), 104->103 (superordinate), 105<->109 (superordinate/subordinate),
-- 108->101 (superordinate, concetto di user1). 106, 107, 110 restano isolati.
-- 107 = nessuna lingua. 110 = subdomain vuoto + una lingua senza termini.

INSERT INTO concept (id, created_by, created_on, updated_by, updated_on, subdomain, superordinate, subordinate, comprehensive, partitive) VALUES
('101', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'machine learning', '102', '', '', ''),
('102', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'artificial intelligence', '', '101', '103', ''),
('103', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'supervised learning', '', '', '', '102'),
('104', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'deep learning', '103', '', '', ''),
('105', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'natural language processing', '', '109', '', ''),
('106', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'open science', '', '', '', ''),
('107', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'data protection', '', '', '', ''),
('108', 'user1', '2026-08-18T10:00:00Z', 'user1', '2026-08-18T10:00:00Z', 'quantum computing', '101', '', '', ''),
('109', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'computational linguistics', '105', '', '', ''),
('110', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', '', '', '', '', '');

-- === CONCEPT_SUBJECT ===

INSERT INTO concept_subject (concept, subject_field) VALUES
('101', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('102', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('102', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('103', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('104', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('104', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('105', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('106', '6416 - research and intellectual property (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('107', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('107', '1236 - rights and freedoms (12 - LAW)'),
('108', '6411 - technology and technical regulations (64 - PRODUCTION, TECHNOLOGY AND RESEARCH)'),
('109', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)'),
('109', '3606 - natural and applied sciences (36 - SCIENCE)'),
('110', '3236 - information technology and data processing (32 - EDUCATION AND COMMUNICATIONS)');

-- === CONCEPT_LANGUAGE ===
-- 107 non compare: nessuna lingua associata (caso limite).
-- 110/en compare qui ma non avrà nessun termine sotto (vedi TERM).

INSERT INTO concept_language (concept, language, created_by, created_on, updated_by, updated_on, definition, external_cross_reference, source, notes) VALUES
('101', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A graphical structure used to represent decisions and their possible consequences, including chance event outcomes, resource costs, and utility.', 'https://en.wikipedia.org/wiki/Decision_tree', 'ISO/IEC 2382-1:1993, 2127', 'Widely used in operations research and machine learning.'),
('101', 'fr', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Structure graphique utilisée pour représenter des décisions et leurs conséquences possibles.', '', '', ''),
('101', 'it', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Struttura grafica usata per rappresentare decisioni e le loro possibili conseguenze.', '', '', ''),
('102', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A procedure that assigns a category label to new observations based on training data.', '', '', ''),
('102', 'fr', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Procédure qui attribue une étiquette de catégorie à de nouvelles observations.', '', '', ''),
('103', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A machine learning approach where models are trained on labeled data.', 'https://en.wikipedia.org/wiki/Supervised_learning', '', ''),
('104', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A subset of machine learning based on artificial neural networks with multiple layers.', '', '', 'Rapidly growing subfield since 2012.'),
('104', 'de', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Ein Teilbereich des maschinellen Lernens, der auf künstlichen neuronalen Netzen mit mehreren Schichten basiert.', '', '', ''),
('105', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A field of AI concerned with the interaction between computers and human language.', '', '', ''),
('105', 'fr', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Domaine de l''IA concernant l''interaction entre ordinateurs et langage humain.', '', '', ''),
('105', 'es', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Campo de la IA relacionado con la interacción entre ordenadores y el lenguaje humano.', '', '', ''),
('106', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'A movement to make scientific research and data openly accessible to society.', 'https://en.wikipedia.org/wiki/Open_science', '', ''),
('108', 'en', 'user1', '2026-08-18T10:00:00Z', 'user1', '2026-08-18T10:00:00Z', 'Computation that exploits quantum-mechanical phenomena to process information.', '', '', ''),
('109', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'An interdisciplinary field concerned with the computational modeling of natural language.', '', '', ''),
('109', 'it', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'Campo interdisciplinare che si occupa della modellazione computazionale del linguaggio naturale.', '', '', ''),
('110', 'en', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z', 'The systematic collection, description, and presentation of terms belonging to specialized subject fields.', '', 'ISO 30042:2019', '');

-- === TERM ===
-- Copre: tutti e 4 i valori di usage, type multi-valore (104_en_003, 105_en_002),
-- generi/numeri grammaticali variati, campi facoltativi valorizzati a campione.

INSERT INTO term (id, concept, language, designation, usage, part_of_speech, grammatical_gender, grammatical_number, type, context, external_cross_reference, source, register, collocation, notes, created_by, created_on, updated_by, updated_on) VALUES
('101_en_001', '101', 'en', 'decision tree', 'preferred term', 'NOUN', '', 'Sing', 'compound term', 'A decision tree can be visualized as a flowchart-like structure.', '', 'ISO/IEC 2382-1:1993, 2127', 'technical', 'build a decision tree, prune a decision tree', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('101_en_002', '101', 'en', 'decision-making tree', 'admitted term', 'NOUN', '', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('101_fr_001', '101', 'fr', 'arbre de décision', 'preferred term', 'NOUN', 'Mas', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('101_it_001', '101', 'it', 'albero decisionale', 'preferred term', 'NOUN', 'Mas', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('102_en_001', '102', 'en', 'classification algorithm', 'preferred term', 'NOUN', '', 'Sing', 'multi-word term', '', '', '', 'technical', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('102_en_002', '102', 'en', 'classifier', 'deprecated term', 'NOUN', '', 'Sing', 'simple term', 'Colloquially still used in older literature.', '', '', 'colloquial', '', 'Superseded by ''classification algorithm'' in formal ISO usage.', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('102_fr_001', '102', 'fr', 'algorithme de classification', 'preferred term', 'NOUN', 'Mas', 'Sing', 'multi-word term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('103_en_001', '103', 'en', 'supervised learning', 'preferred term', 'NOUN', '', 'Sing', 'compound term', '', '', '', 'technical', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('104_en_001', '104', 'en', 'deep learning', 'preferred term', 'NOUN', '', 'Sing', 'compound term', 'Deep learning has driven major advances in computer vision.', '', '', 'technical', 'deep learning model, deep learning architecture', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('104_en_002', '104', 'en', 'deep neural learning', 'obsolete term', 'NOUN', '', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('104_en_003', '104', 'en', 'DL', 'admitted term', 'NOUN', '', 'Sing', 'abbreviation;acronym;initialism', 'Common abbreviation in technical papers.', '', '', 'technical', '', 'Multi-type example: functions as abbreviation, acronym and initialism simultaneously.', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('104_de_001', '104', 'de', 'tiefes Lernen', 'preferred term', 'NOUN', 'Neut', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('105_en_001', '105', 'en', 'natural language processing', 'preferred term', 'NOUN', '', 'Sing', 'multi-word term', '', '', '', 'technical', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('105_en_002', '105', 'en', 'NLP', 'admitted term', 'NOUN', '', 'Sing', 'abbreviation;acronym', '', '', '', 'technical', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('105_fr_001', '105', 'fr', 'traitement automatique du langage naturel', 'preferred term', 'NOUN', 'Mas', 'Sing', 'multi-word term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('105_es_001', '105', 'es', 'procesamiento del lenguaje natural', 'preferred term', 'NOUN', 'Mas', 'Sing', 'multi-word term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('106_en_001', '106', 'en', 'open science', 'preferred term', 'NOUN', '', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('106_en_002', '106', 'en', 'open research', 'admitted term', 'NOUN', '', 'Sing', 'compound term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),

('108_en_001', '108', 'en', 'quantum computing', 'preferred term', 'NOUN', '', 'Sing', 'compound term', '', '', '', 'technical', '', '', 'user1', '2026-08-18T10:00:00Z', 'user1', '2026-08-18T10:00:00Z'),

('109_en_001', '109', 'en', 'computational linguistics', 'preferred term', 'NOUN', '', 'Plur', 'multi-word term', '', '', '', 'technical', '', 'Treated as singular despite plural form, similar to ''linguistics'' itself.', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('109_en_002', '109', 'en', 'language technology', 'admitted term', 'NOUN', '', 'Sing', 'multi-word term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z'),
('109_it_001', '109', 'it', 'linguistica computazionale', 'preferred term', 'NOUN', 'Fem', 'Sing', 'multi-word term', '', '', '', '', '', '', 'user0', '2026-08-18T10:00:00Z', 'user0', '2026-08-18T10:00:00Z');
