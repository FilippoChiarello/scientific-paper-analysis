library(tidyverse)
library(tidystringdist)
library(rebus)
library(tidygraph)

# read back the list of multi-words
social_robotics_multi <- read_lines("output_files/social_robotics_multi.txt")

# string distances: here i want to find kwywords that are written in a similar way

social_robotics_dist_table <- social_robotics_multi %>% 
  # a function from tidystringdist that creates a two column tibble with all the 
  # combination between the element of the input vector
  tidy_comb_all() %>% 
  # compute the distances using the wanted methods*
  tidy_stringdist(method = c("lv", "jw")) %>% 
  # select the treshold level for similarity
  filter(lv < 3 & jw < 0.14 )

# * Here i have a set of keywords. Many of them are similar and semantically equal. I want to find which of these keywords are written in similar way (orthograpic approach).

# compute the groups of similar keywords
chunk_clusters <- social_robotics_dist_table %>% 
  # rapresent the tibble as a graph. In tidy graph, a graph is a set of two tidytables
  as_tbl_graph(directed = F) %>%
  # in the tidy graph framework (a framework for working with graphs in a tidy way)
  # i need to specify on what i want to work on (nodes or edges)
  # https://www.data-imaginist.com/2017/introducing-tidygraph/
  activate(nodes) %>% 
  # all the clustering algo in tidygraph starts with group_. Here i use a dummy clustering that 
  # extracts all the connected components. 
  # https://en.wikipedia.org/wiki/Component_(graph_theory)
  mutate(componet = group_components()) %>% 
  # return to a tibble
  as_tibble()

selected_names <- chunk_clusters %>% 
  group_by(componet) %>% 
  # take the first element of each group
  slice(1) %>% 
  rename(tag = name) %>% 
  ungroup()


# associate a tag to every group of similar keywords
switch_table <- chunk_clusters %>% 
  # it joins by componet
  left_join(selected_names) %>% 
  select(-componet)
                  
switch_table <- social_robotics_multi %>% # all the multiwords, also the one that has no similarities
  # compute the difference between the starting list and the keywords that i've tagged as similar
  setdiff(switch_table[["name"]]) %>% # as output i have all the keywords that do not have mates
  # render it as a tibble
  enframe() %>% 
  select(-name) %>% # name is a dummy variable created by enframe. I remove it
  rename(name = value) %>% # here i have a one column table
  mutate(tag = name) %>% # copy the column in another column named tag
  rbind(switch_table) %>% # i can bind by rows because they have the SAME column
  mutate(tag = str_replace_all(tag, " ", "_")) # substitute the spaces with an underscore
    
write_rds(switch_table, "switch_table.rds")  

# Viz ---------------------------------------------------------------------

# here a visualisation that can help in order to choose the similarity treshold

social_robotics_multi %>% 
  tidy_comb_all() %>% 
  sample_n(100000) %>% 
  # compute the distances using the wanted methods*
  tidy_stringdist(method = c("lv", "jw")) %>% 
  filter(jw < 0.5, lv < 10) %>% 
  ggplot(aes(x = jw, y= lv)) +
  # ATTETION: jitter add some noise to the 
  geom_point(size = 0.4, alpha = 0.4)

# to see the correlation between all the variables. 
# PAY ATTENTION: long

library(GGally)

social_robotics_multi %>% 
  tidy_comb_all() %>% 
  sample_n(10000) %>% 
  # compute the distances using the wanted methods*
  tidy_stringdist(method = c("lv", "jaccard", "jw")) %>% 
  select(-1,-2) %>% 
  ggpairs()

