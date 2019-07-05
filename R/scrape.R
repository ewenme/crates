# setup ------------------------------------------------

library(rvest)
library(tidyverse)

# functions --------------------------------------------

# scrape reviews
hardwax_scrape_reviews <- function(x, page_no) {
  
  # construct url
  url <- paste0("https://hardwax.com/", x, "/?page=", 
                page_no, "&paginate_by=50")
  
  html <- read_html(url)
  
  # get artists
  artists <- html %>% 
    html_nodes(".linebig") %>% 
    html_nodes("a") %>% 
    html_text()
  
  # get releases
  releases <- html %>% 
    html_nodes(".linebig") %>% 
    html_text() %>% 
    # strip out artists
    str_remove(artists) %>% 
    str_trim()
  
  # get labels
  labels <- html %>% 
    html_nodes(".linesmall:nth-child(2) a:nth-child(1)") %>% 
    html_text()
  
  # get reviews
  reviews <- html %>% 
    html_nodes("p") %>%
    html_text()
  
  # rm colons from artists
  artists <- str_sub(artists, end = -2)

  tibble(
    artist = artists,
    label = labels,
    release = releases,
    review = reviews
  )
}

# scrape releases
hardwax_scrape_releases <- function(x, page_no) {
  
  # construct url
  url <- paste0("https://hardwax.com/", x, "/?page=", 
                page_no, "&paginate_by=50")
  
  html <- read_html(url)
  
  # get artists
  artists <- html %>% 
    html_nodes(".linebig") %>% 
    html_nodes("a") %>% 
    html_text()
  
  # get releases
  releases <- html %>% 
    html_nodes(".linebig") %>% 
    html_text() %>% 
    # strip out artists
    str_remove(artists) %>% 
    str_trim()
  
  # get labels
  labels <- html %>% 
    html_nodes(".linesmall:nth-child(2) a:nth-child(1)") %>% 
    html_text()
  
  # get track IDs
  track_refs <- html %>% 
    html_nodes(".download_listen") %>% 
    html_attr("href") %>% 
    str_extract(pattern = "([^\\/]+(?=_))")
  
  # no. tracks on each record
  no_tracks <- rle(track_refs)$lengths
  
  # repeat artists by tracks
  track_artists <- rep(artists, no_tracks)
  track_labels <- rep(labels, no_tracks)
  track_releases <- rep(releases, no_tracks)
  
  # get tracks
  tracks <- html %>% 
    html_nodes(".download_listen") %>% 
    html_attr("title") %>% 
    # strip out artists
    str_remove(track_artists) %>% 
    str_trim()
  
  # rm colons from artists
  track_artists <- str_sub(track_artists, end = -2)
  
  tibble(
    artist = track_artists,
    label = track_labels,
    release = track_releases,
    track = tracks
  )
}

# get data ----------------------------------------------------------------

# scrape news
grime <- map_dfr(seq_along(1:2), hardwax_scrape_reviews, x = "grime")
