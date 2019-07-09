# setup -------------------------------------------------------------------

# install pacman if missing
if (!require("pacman")) install.packages("pacman")

# install/load packages
pacman::p_load("tidyverse", "rvest")

# functions ---------------------------------------------------------------

# get available sections
hardwax_sections <- function() {
  
  # construct url
  url <- "https://hardwax.com"
  
  html <- read_html(url)
  
  selections <- html %>% 
    html_nodes(".navlist:nth-child(5) a") %>% 
    html_attr("href") %>% 
    paste0(url, .)
  
  sections <- html %>% 
    html_nodes(".navlist:nth-child(7) a") %>% 
    html_attr("href") %>% 
    paste0(url, .)
  
  # remove merch
  sections <- sections[!sections %in% "https://hardwax.com/section/merchandise/"]
  
  c(selections, sections)
  
}

# get page range of a hardwax section
hardwax_page_range <- function(x) {
  
  # construct url
  url <- paste0(x, "?paginate_by=50")
  
  html <- read_html(url)
  
  # get page meta
  page_max <- html %>% 
    html_nodes(".fleft") %>% 
    html_nodes("a") %>% 
    tail(1) %>% 
    html_attr("href") %>% 
    str_extract("page=(\\d+)") %>% 
    str_remove("page=")
  
  if (is.na(page_max)) page_max <- 1
  
  1:as.numeric(page_max)
}

# scrape a hardwax section
hardwax_scrape_records <- function(section) {
  
  # get page range
  page_range <- hardwax_page_range(section)
  
  # iterate through pages, scraping records
  records <- map_dfr(page_range, function(x) {
    
    # construct url
    url <- paste0(section, "?page=", x, "&paginate_by=50")
    
    html <- read_html(url)
    
    # get artists
    artists <- html %>% 
      html_nodes(".linebig a") %>% 
      html_text()
    
    # get releases
    releases <- html %>% 
      html_nodes(".linebig") %>% 
      html_text() %>% 
      # strip out artists
      str_remove(coll(artists)) %>% 
      str_trim()
    
    # get labels
    labels <- html %>% 
      html_nodes(".linesmall:nth-child(2) a:nth-child(1)") %>% 
      html_text()
    
    # get cat no
    cat_nos <- html %>% 
      html_nodes(".linesmall:nth-child(2) a:nth-child(2)") %>% 
      html_text()
    
    # get record ID
    record_ids <- html %>% 
      html_nodes(".linesmall:nth-child(2) a:nth-child(2)") %>% 
      html_attr("href") %>% 
      str_extract("([0-9])([^//]*)")
    
    # get reviews
    reviews <- html %>% 
      html_nodes("p") %>%
      html_text()
    
    # rm colons from artists
    artists <- str_sub(artists, end = -2)
    
    Sys.sleep(1.5)
    
    tibble(
      artist = artists,
      release = releases,
      label = labels,
      cat_no = cat_nos,
      review = reviews,
      release_id = record_ids
    )
  })
}

# scraper ------------------------------------------------------------------

# get available sections
sections <- hardwax_sections()

# scrape records
records <- map_dfr(sections, hardwax_scrape_records)

# remove duplicates
records <- distinct(records, release_id, .keep_all = TRUE)

# export data
write_csv(records, "data/hardwax/hardwax-listings.csv")
