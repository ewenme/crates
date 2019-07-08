source("R/requirements.R")

# functions ---------------------------------------------------------------

honest_sections <- function() {
  
  url <- "https://honestjons.com"
  
  html <- read_html(url)
  
  categories <- html %>% 
    html_nodes(".nav_vertical ul:nth-child(1)") %>% 
    html_text() %>% 
    str_split(pattern = "\n\n\n", simplify = TRUE) %>% 
    str_remove_all(coll("\n")) %>% 
    str_replace_all(" / ", "_")
  
  categories <- categories[!categories %in% c("Latest 100 arrivals", "")]
  
  categories <- paste(url, "shop", "category", categories, "A-Z", sep = "/")
}

honest_page_range <- function(x) {
  
  # x <- sections[1]
  
  # read page
  html <- read_html(x)
  
  # get max page
  page_max <- html %>% 
    html_nodes("span:nth-child(13) a") %>% 
    html_text() %>% 
    str_trim()
  
  if (is.na(page_max)) page_max <- 1
  
  1:as.numeric(page_max)

  }

# scrape ------------------------------------------------------------------

# get available sections
sections <- honest_sections()
