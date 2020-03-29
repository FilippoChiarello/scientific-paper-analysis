library(tidyverse)
library(tidystringdist)
library(rebus)

# import the full table
paper_table <- read_rds("data/wip/paper_table_full.rds") %>%
  filter(!is.na(abstract))
  # pay attention when remove papers.
  # 1) Check for the number of citations
  # 2) Check the distribution of missing values. It has to be statistically            similar to the rest of the data
  # 3) It has to be DOCUMENTED. If i filter and not saying i make the analysis less reproducible



paper_abstracts <- paper_table %>%
  # take only abstract and ID
  select(scopusID, abstract) %>%
  # preprocess the abstracts removing -, / and tolowercases
  mutate(abstract = str_replace_all(abstract, "-", " "),
         abstract = str_replace_all(abstract,fixed("/"), " "),
         # Pay attention for the POS
         abstract = str_to_lower(abstract))

# create sample abstract table

abstract_txt <- paper_abstracts %>%
  # tidy version of paper_abstracts$abstract or paper_abstracts[["abstract"]]
  pull(abstract) %>%
  # take 1000 random abstracts
  sample(1000) %>%
  # merge all of them togheter
  str_c(collapse = "\n")

# if i wanna take a look: write_lines(abstract_txt, "abstract.txt"), also searchable with regex

# Chunk the abstract ----------
# Create a domain lexicon. A domain lexicon is a list of (multi)words typical of the cosidered to domain. In order to do that collect all the keywords

social_robotics_lexicon <- paper_table %>%
  # extract keywords
  pull(keywords) %>%
  #strip the keywords on the | characte
  str_split(pattern = fixed("|")) %>%
  unlist() %>%
  #strip the keywords on and
  str_split(pattern = "\\band\\b") %>%
  unlist() %>%
  #strip the keywords or and
  str_split(pattern = "\\bor\\b") %>%
  unlist() %>%
  #strip the keywords vs and
  str_split(pattern = "\\bvs\\b") %>%
  # what else
  unlist() %>%
  #remove NA keywords
  .[!is.na(.)] %>%
  #remove all the - and / like above
  str_replace_all("-", " ") %>%
  str_replace_all(fixed("/"), " ") %>%
  #lower case
  str_to_lower() %>%
  #remove useless spaces
  str_trim() %>%
  unique()

# 1. acronyms V~
# 2. keyword length (k-word and n-word with k>n) V
# 3. keyword of the authors that do not represent the article (noise/signal problems)
# 4. hyperonims
# 5. synonims (also with grammatical variations) and equal concepts
# 6. singular and plural

# collect all the acronyms
social_robotics_acronym <- social_robotics_lexicon %>%
  .[str_detect(., fixed("("))]

# remove everything between (), also acronyms
social_robotics_lexicon <- social_robotics_lexicon %>%
  str_remove_all("\\(.*\\)") %>%
  str_trim() %>%
  unique()

# remove noise: rare keywords -------



# since i want to chunk the abstract (so find the multi words)
# i find all the multi word in my lexicon

social_robotics_multi <- social_robotics_lexicon %>%
  #same as social_robotics_lexicon[str_detect(social_robotics_lexicon, " ")]
  .[str_detect(., " ")]

social_robotics_multi <- social_robotics_multi %>%
  # i came back to a tidy structure
  enframe() %>%
  rename(multiword = value) %>%
  select(multiword) %>%
  #cleaning non recognized character
  filter(!str_detect(multiword, "[:punct:]")) %>%
  filter(!str_detect(multiword, " and ")) %>%
  filter(!str_detect(multiword, "^and ")) %>%
  filter(!str_detect(multiword, " or ")) %>%
  filter(!str_detect(multiword, "^or ")) %>%
  filter(!str_detect(multiword, " vs ")) %>%
  # count how many words are in the keyword
  mutate(n_word = str_count(multiword, "\\W+") + 1)  %>%
  # i tag everything that is lower than 5 (chunk 2,3,4)
  filter(n_word < 5) %>%
  # reorder in decreasing number or word
  arrange(-n_word) %>%
  select(multiword)

social_robotics_count <- social_robotics_multi %>%
  #create many regex (one for each keyword)
  mutate(multiword = str_c("\\b", multiword, "\\b")) %>%
  # i count how many times these appear in a sample of abstracts
  mutate(occurrency = str_count(abstract_txt, multiword))

social_robotics_multi <- social_robotics_count %>%
  # the tresh-hold can be decided (recall and precision)
  filter(occurrency > 0) %>%
  pull(multiword) %>%
  # remove the word boundaries
  str_remove_all(fixed("\\b"))

write_lines(social_robotics_multi, "data/wip/social_robotics_multi.txt")

