library(tidyverse)
library(rvest)
funny_html <- read_html("https://www.brainyquote.com/topics/funny-quotes")

quotes <- funny_html %>%
  html_nodes(".oncl_q") %>%
  html_text()

person <- funny_html %>%
  html_nodes(".oncl_a") %>%
  html_text()

# put in data frame with two variables (person and quote)
quotes_funny <- data.frame(person = person, quote = quotes
                         , stringsAsFactors = FALSE) %>%
  mutate(together = paste('"', as.character(quote), '" --'
                          , as.character(person), sep=""))

out_path <- "/Users/mollycooper/Git Hub/STAT-231-Molly/Homework"
write_csv(x = quotes_funny, path = paste0(out_path,"/quotes.csv"))

