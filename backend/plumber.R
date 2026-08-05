# plumber.R

# Entry point.

library(plumber)

pr <- plumb("api.R")
pr$run(host = "127.0.0.1", port = 8000)