library(tidyverse)
library(topicmodels)
library(ldatuning)

papers_dtm <- read_rds("data/papers_dtm.rds")

result <- FindTopicsNumber(
  papers_dtm,
  topics = seq(from = 2, to = 5, by = 1),
  metrics = c("Griffiths2004", "CaoJuan2009", "Arun2010", "Deveaud2014"),
  method = "Gibbs",
  control = list(seed = 77),
  mc.cores = 2L,
  verbose = TRUE
)

FindTopicsNumber_plot(result)


