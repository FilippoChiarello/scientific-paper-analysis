library(dplyr)
library(LDAvis)
library(ggrepel)
library(LDAvis)

topicmodels_json_ldavis <- function(fitted, corpus, doc_term){
  # Required packages

  # Find required quantities
  phi <- posterior(fitted)$terms %>% as.matrix
  theta <- posterior(fitted)$topics %>% as.matrix
  vocab <- colnames(phi)
  
  doc_length <- corpus %>% 
    count(doc_id) %>% 
    pull(n)
  
  # doc_length <- vector()
  # for (i in 1:length(corpus)) {
  #   temp <- paste(corpus[[i]]$content, collapse = ' ')
  #   doc_length <- c(doc_length, stri_count(temp, regex = '\\S+'))
  # }
  # 
  
  # temp_frequency <- inspect(doc_term)
  # freq_matrix <- data.frame(ST = colnames(temp_frequency),
  #                           Freq = colSums(temp_frequency))
  # rm(temp_frequency)
  
  term_frequency <- corpus %>% 
    ungroup() %>% 
    filter(!duplicated(lemma)) %>% 
    pull(n)
  
  # Convert to json
  json_lda <- LDAvis::createJSON(phi = phi, theta = theta,
                                 vocab = vocab,
                                 doc.length = doc_length,
                                 term.frequency = term_frequency)
  
  return(json_lda)
}