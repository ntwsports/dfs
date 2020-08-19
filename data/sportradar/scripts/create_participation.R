library(rvest)
library(jsonlite)
library(tidyverse)
library(here)
source(here("helper_functions.R"))

game_files <- list.files(here("sportradar", "participation_files"))
game_file_paths <- paste(here("sportradar", "participation_files"), game_files, sep = "/")

participation_dfs <- map(game_file_paths, participation_to_df)

participation_dfs %>% 
    bind_rows() %>% 
    mutate(game_id = str_replace_all(game_id, "JAC", "JAX")) -> all_participation

write_csv(all_participation, here("sportradar", "participation_2019.csv")) 

