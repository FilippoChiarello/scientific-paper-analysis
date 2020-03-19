library(tidyverse)

file_list <- list.files("data/chunked_pos_tagged", full.names = T)

abstract_tokens <- tibble()

ln <- length(file_list)

for(i in 1:length(file_list)){
  
  print(str_c("papers done ----->  ", round(i/ln, digits = 4)*100, "%"))
  
  abstract_tokens <- rbind(abstract_tokens,
                           read_rds(file_list[i]))
  
}


write_rds(abstract_tokens, "data/abstract_tokens.rds")




