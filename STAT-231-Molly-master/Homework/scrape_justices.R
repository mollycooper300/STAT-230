library(tidyverse)
library(rvest)
justices_url <- "https://en.wikipedia.org/wiki/List_of_justices_of_the_Supreme_Court_of_the_United_States"
table <- justices_url %>%               
  read_html() %>%
  html_nodes("table") %>%
  html_table(fill = TRUE) 
justices <- table[[2]]

out_path <- "/Users/mollycooper/Git Hub/STAT-231-Molly/Homework"
write_csv(x = justices, path = paste0(out_path,"/justices.csv"))  
          
          





