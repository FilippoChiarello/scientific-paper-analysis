# This part is the most important one for topic modelling.
### Here i've made decisions based on __my case study__. ###
# Different case studies can have different approaches, expecially
# for the treshold decision

library(tidyverse)
library(tidytext)
library(plotly)
library(ggrepel)
library(rebus)


abstract_tokens <- read_rds("data/wip/abstract_tokens.rds")


# Keywords extraction ----------

# count how many documents under analysis
n_doc <- abstract_tokens %>%
  group_by(doc_id) %>%
  summarise(n()) %>%
  nrow()

# compute the percentage of articles in which the lemma appears
lemma_freq <- abstract_tokens %>%
  select(lemma, doc_id) %>%
  group_by(lemma, doc_id) %>%
  mutate(n_tot= n()) %>%
  filter(!duplicated(lemma, doc_id)) %>%
  ungroup() %>%
  # Number of documents in which the lemma appears
  count(lemma) %>%
  mutate(n = (n / n_doc)*100) %>%
  rename(tot_freq = n)

abstract_tokens <- abstract_tokens %>%
  # add the frequency column
  left_join(lemma_freq) %>%
  # add the string length column
  mutate(lemma_length = str_length(lemma))

# blacklist

black_list_scientific <- read_lines("data/dictionaries/black_list_scientific.txt") %>%
  or1()

black_list_scientific <- BOUNDARY %R% black_list_scientific %R% BOUNDARY

# corpus level tokens selection --------------------------

abstract_tokens_selected <- abstract_tokens %>%
  filter(tot_freq > 0.1) %>%  # filter rare words
  filter(tot_freq < 10) %>% # filter common words
  filter(lemma_length > 3) %>% # filter short words
  filter(str_detect(xpos, "NN|JJ")) %>%  # take only NN and JJ
  filter(!(str_detect(upos, "SYM"))) %>%  # remove SYM
  filter(!str_detect(lemma, black_list_scientific)) # not in blacklist

# Document lost
abstract_tokens_selected %>%
  group_by(doc_id) %>%
  summarise(n()) %>%
  nrow() - n_doc

# document level tokens selection --------------------------

# Viz to take the treshol on the number of words to consider

abstract_tokens_selected %>%
  count(doc_id) %>%
  ggplot(aes(y = n)) +
  geom_boxplot()

abstract_tokens_selected %>%
  count(doc_id, lemma, sort = TRUE) %>%
  bind_tf_idf(term = lemma, document = doc_id, n = n) %>%
  group_by(doc_id) %>%
  top_n(50, tf_idf) %>%
  count(doc_id) %>%
  ggplot(aes(y = n)) +
  geom_boxplot()

papers_corpus <- abstract_tokens_selected %>%
  count(doc_id, lemma, sort = TRUE) %>%
  bind_tf_idf(term = lemma, document = doc_id, n = n) %>%
  group_by(doc_id) %>%
  # take only the top K documents in terms of td/idf
  top_n(50, tf_idf) %>%
  ungroup()

papers_dtm <- papers_corpus %>%
  cast_dtm(doc_id, lemma, n) #create a document/term matrix

write_rds(papers_dtm, "data/output_files/papers_dtm.rds")
write_rds(papers_corpus, "data/output_files/papers_corpus.rds")



