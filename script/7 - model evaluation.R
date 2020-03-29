library(tidyverse)
library(topicmodels)
library(ldatuning)

papers_dtm <- read_rds("data/output_files/papers_dtm.rds")

# Set the number max of topics to evaluate in "to" (in this case equal to 5)
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

ggsave("data/images/model_evaluation.png")

