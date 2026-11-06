library(tidyverse)

basics <- read_tsv("https://datasets.imdbws.com/title.basics.tsv.gz",
                   na = "\\N", quote = "", show_col_types = FALSE,
                   col_select = c(tconst, titleType, primaryTitle,
                                  startYear, runtimeMinutes, genres))

ratings <- read_tsv("https://datasets.imdbws.com/title.ratings.tsv.gz",
                    na = "\\N", show_col_types = FALSE)

movies <- basics |>
  filter(titleType == "movie") |>
  inner_join(ratings, by = "tconst") |>
  mutate(year = as.numeric(startYear)) |>
  filter(numVotes >= 1000, year >= 1970) |>
  mutate(horror = str_detect(genres, "Horror"),
         comedy = str_detect(genres, "Comedy")) |>
  filter(xor(horror, comedy)) |>
  mutate(genre = if_else(horror, "Horror", "Comedy")) |>
  select(title = primaryTitle, year, genre,
         rating = averageRating, votes = numVotes)

write_rds(movies, "movies.rds")
