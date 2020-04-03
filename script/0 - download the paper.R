source("functions/scopusAPI.R")
library(tidyverse)

# import scopus paper -----------------------------------------------------

# create the query with the wanted content
interest_fields <- ''

# insert you Scopus API key

key <- ""

for (i in 1983:2020){

  print(i)

  # modifiable as you want https://dev.elsevier.com/tips/ScopusSearchTips.htm
  # attention: here is only on TITLE-ABS-KEY

    query <- str_c("PUBYEAR = ", i, " AND TITLE-ABS-KEY (", interest_fields, ")")

    # download an xml
    xml_output <- searchByString(string = query, outfile = "testdata.xml", key = key)

    # translate the xml in to a table
    paper_table <- extractXML(xml_output)

    # write each table with its own name. Here the name is changing per year: if someone decide
    # to make a cicle on other variable they has to be added here

    # the rds is the best format for inter-R data exange.
    write_rds(paper_table, path = str_c("data/input_data/output_query/social_robotics_", i, ".rds", collapse = ""))

  }




