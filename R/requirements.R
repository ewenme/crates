# setup -------------------------------------------------------------------

# install pacman if missing
if (!require("pacman")) install.packages("pacman")

# install/load packages
pacman::p_load("tidyverse", "fs", "rvest")

# create data directory
dir_create("data")