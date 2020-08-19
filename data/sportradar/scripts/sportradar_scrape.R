library(jsonlite)
library(tidyverse)
library(here)

##DO NOT RUN WITHOUT CHECKING THE API KEY

season <- 2019
week <- "02"
season_type <- "REG"

schedule <- fromJSON(glue::glue("https://api.sportradar.us/nfl/official/trial/v5/en/games/{season}/{season_type}/{week]/schedule.json?api_key={sr_api_key}"), flatten = TRUE)

schedule %>% 
    pluck("week", "games") %>% 
    pull(id) -> week_games

weeks <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17")

sportradar_schedule <- function(season, week) {
    week_games <- fromJSON(glue::glue("https://api.sportradar.us/nfl/official/trial/v5/en/games/{season}/REG/{week}/schedule.json?api_key={sr_api_key}", sep = ""), flatten = TRUE)
    Sys.sleep(1) #need to break because the data API call rate is too fast
    week_games
}

all_2019 <- map2(.x = 2019, .y = weeks, sportradar_schedule)

write_sportradar_schedules <- function(week_file) {
    file_name <- week_file %>% pluck("week", "id")
    week_file %>% 
        write_json(x = ., path = here::here("sportradar", "schedules", glue::glue("{file_name}.json")))
}

map(all_2019, write_sportradar_schedules)

all_weeks %>% 
    map(pluck, "week", "games") %>% 
    bind_rows() %>% 
    pull(id) -> all_weeks_ids

sportradar_pbp <- function(game_id) {
    pbp_data <- fromJSON(glue::glue("https://api.sportradar.us/nfl/official/trial/v5/en/games/{game_id}/pbp.json?api_key={sr_api_key}"))
    Sys.sleep(1)
    pbp_data
}

sr_pbp_files <- map(all_weeks_ids, sportradar_pbp)

sportradar_participation <- function(game_id) {
    participation_data <- fromJSON(glue::glue("https://api.sportradar.us/nfl/official/trial/v5/en/plays/{game_id}/participation.json?api_key={sr_api_key}"))
    Sys.sleep(1)
    participation_data
}

sr_participation_files <- map(all_weeks_ids, sportradar_participation)

write_sportradar_pbp <- function(pbp_file) {
    file_name <- pbp_file %>% pluck("id")
    pbp_file %>% 
        write_json(x = ., path = here::here("sportradar", "play_by_play_files", glue::glue("{file_name}.json")))
}

map(sr_pbp_files, write_sportradar_pbp)

write_sportradar_participation <- function(participation_file) {
    file_name <- participation_file %>% pluck("id")
    participation_file %>% 
        write_json(x = ., path = here::here("sportradar", "participation_files", glue::glue("{file_name}.json")))
}

map(sr_participation_files, write_sportradar_participation)

sportradar_depth_charts <- function(season, week) {
    week_depth_chart <- fromJSON(glue::glue("https://api.sportradar.us/nfl/official/trial/v5/en/seasons/{season}/REG/{week}/depth_charts.json?api_key={sr_api_key}", sep = ""), flatten = TRUE)
    Sys.sleep(1)
    week_depth_chart
}

weeks <- c("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17")

sr_depth_charts <- map2(.x = 2019, .y = weeks, .f = sportradar_depth_charts)

write_sportradar_depth_charts <- function(week_file) {
    file_name <- week_file %>% pluck("week", "id")
    week_file %>% 
        write_json(x = ., path = here::here("sportradar", "depth_charts", glue::glue("{file_name}.json")))
}

map(sr_depth_charts, write_sportradar_depth_charts)

