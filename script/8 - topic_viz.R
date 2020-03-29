source("functions/functions.R")
library(tidyverse)
library(tidytext)
library(ggrepel)
library(topicmodels)
library(LDAvis)
library(gistr)

papers_dtm <- read_rds("data/output_files/papers_dtm.rds")
papers_corpus <- read_rds("data/output_files/papers_corpus.rds")


papers_lda <- LDA(papers_dtm, k = 3, control = list(seed = 1234))

json_lda <- topicmodels_json_ldavis(fitted = papers_lda,
                                    corpus = papers_corpus,
                                    doc_term = papers_dtm
                                    )

# PAY ATTENTION: for visualize the results in dashboard you must have
# GitHub profile

serVis(json_lda, as.gist = T)

# Grafico PCA primi 3

# 3 topic
#https://bl.ocks.org/FilippoChiarello/raw/c8f0ec27ffab0c7a5a5a8efde71a8676


# Istogrammi sui 3 (3 X 1)

ap_topics <- tidy(papers_lda, matrix = "beta")
ap_topics

ap_top_terms <- ap_topics %>%
  mutate(topic = case_when(
    topic == 1 ~ 2,
    topic == 2 ~ 1,
    topic == 3 ~ 3
  )) %>%
  group_by(topic) %>%
  top_n(10, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

ap_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(term, beta)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  scale_x_reordered() +
  theme_bw()

# 6 topic
#https://bl.ocks.org/FilippoChiarello/raw/22c7a8b951ef56185ecf14bf6f506eb7

#9 topics
#https://bl.ocks.org/FilippoChiarello/raw/92192b889a0cd279e2bca8df417fee51/




