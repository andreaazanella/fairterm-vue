# plumber.R
# Entry point.
#
# Da terminale (dalla cartella backend/):
#   Rscript plumber.R
#
# Oppure da RStudio, aprendo questo file e usando il bottone "Run API"
# (visibile automaticamente perché RStudio riconosce le annotazioni #* di api.R).

library(plumber)

pr <- plumb("api.R")
pr$run(host = "127.0.0.1", port = 8000)