library(tidyverse)

# Re-import the table

# list all files path in a folder
list_files <- list.files("data/input_data/output_query", full.names = T)

# prepare an empy tibble
paper_table <- tibble()

for (i in 1:length(list_files)){

    tmp_tib <- read_rds(list_files[[i]]) %>%
      as_tibble()

    paper_table <- rbind(paper_table, tmp_tib)

  }

#remove duplicates created by SCOPUS
paper_table <- paper_table %>%
  filter(!duplicated(scopusID))

write_rds(paper_table, "data/wip/paper_table_full.rds")


