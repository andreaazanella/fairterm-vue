# FAIRterm 2.0 — API Spec (Plumber backend)

Bozza di lavoro. Riflette le decisioni prese finora nella progettazione UI/UX.
Endpoint annidati (nested): `GET /concepts/:id` restituisce concetto + lingue + termini
in un'unica risposta, per allinearsi a come la pagina "Concetto specifico" mostra tutto insieme.

Base path assunto: `/api`

---

## Reference data

Liste vocabolario statiche (subject field, lingue ISO, valori di usage/POS/gender/number/type).
Nell'app Shiny sono caricate una volta all'avvio da file `.rds`; qui diventano un unico
endpoint da richiamare una volta e tenere in cache lato frontend (composable, non Pinia).

### `GET /reference-data`

**Risposta 200**
```json
{
  "subjectFields": [
    { "name": "6411 - technology and technical regulations", "description": "64 - PRODUCTION, TECHNOLOGY AND RESEARCH" }
  ],
  "languages": [
    { "id": "en", "name": "English" },
    { "id": "fr", "name": "French" }
  ],
  "usageValues": ["preferred term", "admitted term", "deprecated term", "obsolete term"],
  "posValues": ["noun", "verb", "adjective", "..."],
  "genderValues": ["masculine", "feminine", "..."],
  "numberValues": ["singular", "plural", "..."],
  "typeValues": ["abbreviation", "acronym", "appellation", "borrowed term", "blend",
                 "complex term", "clipped term", "compound term", "initialism",
                 "multi-word term", "proper name", "simple term", "single-word term", "symbol"]
}
```

> ⚠️ **Aperto**: se `type` diventa multi-valore (vedi Open Questions), qui non cambia nulla —
> resta comunque la lista di valori possibili, cambia solo come viene salvato sul termine.

---

## Concepts

### `GET /concepts`

Lista concetti per la schermata "Concetti" (lista + ricerca). Filtra sempre per utente corrente.

**Query params**
| Nome | Tipo | Obbligatorio | Note |
|---|---|---|---|
| `subjectField` | string | no | filtra per dominio |
| `search` | string | no | ricerca testuale (su id o, se disponibile, sui termini collegati) |

**Risposta 200**
```json
[
  { "id": "742", "subjectField": "6411 - technology and technical regulations", "subdomain": "machine learning", "updatedOn": "2026-07-12T14:32:00Z" }
]
```

### `GET /concepts/:id`

Vista completa per la pagina "Concetto specifico" — concetto + relazioni + lingue + termini nidificati.

**Risposta 200**
```json
{
  "id": "742",
  "subjectField": "6411 - technology and technical regulations",
  "subdomain": "machine learning",
  "relations": {
    "superordinate": "156",
    "subordinate": null,
    "comprehensive": null,
    "partitive": null
  },
  "createdBy": "user0",
  "createdOn": "2026-07-10T09:00:00Z",
  "updatedBy": "user0",
  "updatedOn": "2026-07-12T14:32:00Z",
  "languages": [
    {
      "language": "en",
      "definition": "A graphical structure used to represent decisions and their possible consequences.",
      "externalCrossReference": null,
      "source": "ISO/IEC 2382-1:1993, 2127",
      "notes": "Utilizzato in ambito informatico e statistico.",
      "terms": [
        {
          "id": "742_en_318",
          "designation": "decision tree",
          "usage": "preferred term",
          "partOfSpeech": "noun",
          "grammaticalGender": null,
          "grammaticalNumber": "singular",
          "type": "compound term",
          "context": "A decision tree can be visualized as a flowchart-like structure.",
          "externalCrossReference": null,
          "source": "ISO/IEC 2382-1:1993, 2127",
          "register": null,
          "collocation": "build a decision tree, prune a decision tree",
          "notes": null
        }
      ]
    }
  ]
}
```

### `POST /concepts`

Crea un nuovo concetto (schermata "Nuovo concetto"). Un solo salvataggio, nessuno stato intermedio.

**Body**
```json
{
  "subjectField": "6411 - technology and technical regulations",
  "subdomain": "machine learning",
  "relations": { "superordinate": "156", "subordinate": null, "comprehensive": null, "partitive": null }
}
```

**Risposta 201** → stesso shape di `GET /concepts/:id` (senza `languages`, appena creato)

### `PUT /concepts/:id`

Aggiorna un concetto esistente (modale "Modifica concetto"). `subjectField` e `id` non sono accettati nel body — sono bloccati per design.

**Body**
```json
{
  "subdomain": "machine learning",
  "relations": { "superordinate": "156", "subordinate": "49281", "comprehensive": null, "partitive": null }
}
```

**Risposta 200** → concetto aggiornato

---

## Languages (annidate sotto un concetto)

### `POST /concepts/:id/languages`

Modale "Aggiungi lingua". La select delle lingue nel frontend va filtrata a monte escludendo quelle già associate al concetto — l'API può comunque restituire 409 come rete di sicurezza.

**Body**
```json
{
  "language": "fr",
  "definition": "Structure graphique utilisée pour représenter des décisions.",
  "externalCrossReference": null,
  "source": null,
  "notes": null
}
```

**Risposta 201** → oggetto lingua creato
**Risposta 409** → lingua già presente sul concetto

### `PUT /concepts/:id/languages/:languageCode`

Modale "Modifica lingua". Il codice lingua non è nel body — non modificabile.

**Body**
```json
{
  "definition": "...",
  "externalCrossReference": "...",
  "source": "...",
  "notes": "..."
}
```

**Risposta 200** → lingua aggiornata

### `DELETE /concepts/:id/languages/:languageCode`

Elimina la sezione lingua **e tutti i termini collegati** (cascade). La conferma "Sei sicuro? Verranno eliminati anche i N termini associati" è responsabilità del frontend prima della chiamata.

**Risposta 204**

---

## Terms (annidati sotto concetto + lingua)

### `POST /concepts/:id/languages/:languageCode/terms`

Modale "Aggiungi termine".

**Body**
```json
{
  "designation": "decision tree",
  "usage": "preferred term",
  "partOfSpeech": "noun",
  "grammaticalGender": null,
  "grammaticalNumber": "singular",
  "type": "compound term",
  "context": "A decision tree can be visualized as a flowchart-like structure.",
  "externalCrossReference": null,
  "source": "ISO/IEC 2382-1:1993, 2127",
  "register": null,
  "collocation": "build a decision tree, prune a decision tree",
  "notes": null
}
```

**Risposta 201** → termine creato (con `id` generato)

> ⚠️ **Aperto**: `designation`, `usage`, `source` sono nel mockup campi obbligatori (`*`).
> Il body sopra li tratta come required — da confermare col professore (vedi Open Questions).

### `PUT /concepts/:id/languages/:languageCode/terms/:termId`

Modale "Modifica termine". `concept` e `language` non sono nel body — non modificabili (per lo stesso motivo per cui non lo è `language` sulla lingua: spostare un termine tra lingue/concetti va gestito con elimina+ricrea, non con un update implicito).

**Body**: stessi campi di POST, tutti modificabili.

**Risposta 200** → termine aggiornato

### `DELETE /concepts/:id/languages/:languageCode/terms/:termId`

**Risposta 204**

---

## Open questions (da confermare col professore)

Raccolte qui man mano che sono emerse in fase di progettazione UI — vedi anche `docs/open-questions.md`.

1. **`type` sul termine**: nel DB è una singola colonna testo; il mockup "Aggiungi termine" lo disegna come multi-select. Se multi-valore è confermato, serve decidere tra stringa concatenata (rapido) o tabella ponte dedicata (più corretto).
2. **`register` sul termine**: nel DB è testo libero; il mockup lo tratta come vocabolario controllato (dropdown). Serve che il professore fornisca la lista di valori ammessi, che oggi non esiste in `global.R`.
3. **`source` sul termine come campo obbligatorio**: nell'app Shiny originale nessun campo del termine è obbligatorio. Renderlo required è una scelta di qualità dati (tracciabilità, spirito FAIR) da confermare esplicitamente, perché blocca l'inserimento se non rispettata.
4. **ID concetto**: oggi generato come numero random 0-999 (con controllo di unicità limitato al solo dominio caricato in quel momento — potenziale collisione cross-dominio). Proposta: formato leggibile tipo `C-XXXXXX` generato lato backend con garanzia di unicità globale.
5. **Sottotitolo con termine preferito sotto l'ID concetto**: idea accantonata per ora (nessuna regola su quale lingua/termine mostrare in caso di ambiguità o assenza di un termine "preferred"). Da riproporre se interessa in futuro.
