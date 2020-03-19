library(tidyverse)
library(rebus)
library(stringi)
library(udpipe)

switch_table <- read_rds("data/switch_table.rds")
paper_table <- read_rds("data/paper_table_full.rds") %>% 
  filter(!is.na(abstract))

paper_abstracts <- paper_table %>% 
  select(scopusID, abstract) %>% 
  mutate(abstract = str_replace_all(abstract, "-", " "),
         abstract = str_replace_all(abstract,fixed("/"), " "),
         abstract = str_to_lower(abstract))

# subsistute the multi-worlds ---------

n_multi_words <- nrow(switch_table)

n_papers <- nrow(paper_abstracts)

# DownLoad the linguistic model of EN
#udpipe::udpipe_download_model(language = "english")

# DownLoad the linguistic model of EN
switch_table <- switch_table %>% 
  mutate(token = str_replace_all(tag, "_", ""))

# Load the model in the workspace
en_model <- udpipe::udpipe_load_model("data/english-ud-2.0-170801.udpipe")

for(i in 1:n_papers){ # for each abstract
  
  print(str_c("papers done ----->  ", round(i/n_papers, digits = 4)*100, "%"))
  
  for(j in 1:n_multi_words){ # for each multiword
    
    # replace the multi word with spaces, with the multiword without spaces
    # why _fixed? because inside the keywords there are also character that can 
    # be interpreted as regex. Fixed does not consider them
    paper_abstracts[[i,2]] <- stri_replace_all_fixed(paper_abstracts[[i,2]], 
                                            switch_table[[j,1]],
                                            switch_table[[j,3]])
    
  }
  
  # pos tag the abstract
  abstract_tokens <- udpipe::udpipe_annotate(object = en_model, 
                                             x = paper_abstracts[[i,2]], 
                                             doc_id = paper_abstracts[[i,1]]) %>% 
    as_tibble() %>% 
    # add the information on the tagged token
    left_join(switch_table) %>% 
    mutate(token = ifelse(!is.na(tag), tag, token)) %>% 
    mutate(lemma = ifelse(!is.na(tag), tag, lemma)) %>% 
    select(-name, -tag)
  
  write_rds(abstract_tokens, str_c("data/chunked_pos_tagged/",paper_abstracts[[i,1]], ".rds", collapse = ""))
  
}

