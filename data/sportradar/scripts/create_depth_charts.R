library(jsonlite)
library(tidyverse)
library(here)

week_file_names <- list.files(here("sportradar", "depth_charts"))

week_file_paths <- paste(here::here("sportradar", "depth_charts"), week_file_names, sep = "/")

week_files <- map(week_file_paths, read_json)

team_names <- week_files %>% 
    purrr::pluck(1, "teams") %>% 
    map(pluck, "alias") %>% 
    unlist()

depth_charts <- week_files %>% 
    map(discard, function(x) length(x) == 1) %>% 
    map(modify_at, "season", pluck, "year") %>% 
    map(modify_at, "week", pluck, "sequence") %>% 
    map(modify_at, "teams", map, modify_at, c("offense", "defense", "special_teams"), map, modify_at, "position.players", bind_rows) %>% 
    map(modify_at, "teams", map, modify_at, c("offense", "defense", "special_teams"), map, flatten_dfc) %>% 
    map(modify_at, "teams", map, modify_at, c("offense", "defense", "special_teams"), bind_rows) %>% 
    map(modify_at, "teams", set_names, team_names) %>% 
    map(modify_at, "teams", map, keep, is_tibble) %>% 
    map(modify_at, "teams", map, bind_rows, .id = "side_of_ball") %>% 
    map(modify_at, "teams", bind_rows, .id = "team") %>% 
    map(flatten_dfc) %>% 
    bind_rows()

write_csv(depth_charts, here("sportradar", "depth_charts.csv"))


    

