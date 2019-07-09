# setup -------------------------------------------------------------------

# install pacman if missing
if (!require("pacman")) install.packages("pacman")

# install/load packages
pacman::p_load("tidyverse", "rvest")

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

honest_scrape_records <- function(section) {
  
  # get page range
  page_range <- honest_page_range(section)
  
  # iterate through pages, scraping records
  records <- map_dfr(page_range, function(x) {
  
    # construct url
    url <- paste(section, x, sep = "/")
    
    html <- read_html(url)
    
    # get artists
    artists <- html %>% 
      html_nodes("h2") %>% 
      html_text()
    
    # get releases
    releases <- html %>% 
      html_nodes("h3") %>% 
      html_text() 
    
    # get labels
    labels <- html %>% 
      html_nodes("h4") %>% 
      html_text() 
    
    # get reviews
    reviews <- html %>% 
      html_nodes(".item_featured , .desc") %>% 
      html_node("p") %>% 
      html_text()
    
    Sys.sleep(1.5)
    
    tibble(
      artist = artists,
      release = releases,
      label = labels,
      review = reviews
    )
  })
}

# scrape ------------------------------------------------------------------

# get available sections
sections <- honest_sections()

# scrape records
records <- map_dfr(sections, honest_scrape_records)

# remove duplicates
records <- distinct(records, .keep_all = TRUE)

# export data
write_csv(records, "data/honest-jons/honest-jons-listings.csv")

