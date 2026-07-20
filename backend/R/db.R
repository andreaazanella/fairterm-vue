# db.R

# Connessione al database equivalente del "pool" che nell'app Shiny.
# La funzione originale viveva dentro global.R (righe 18-26).

library(pool)
library(RSQLite)

createPool <- function(dbPath = "data/temp.db") {
  pool::dbPool(
    drv = RSQLite::SQLite(),
    dbname = dbPath
  )
}