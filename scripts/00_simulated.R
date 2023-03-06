#### Preamble ####
# Purpose: This script prepares the tutorial
# Author: Joseph Chung
# Date: March 04 2023
# Contact: yj.chung@mail.utoronto.ca
# License:

# Simulated data

library(babynames)
library(dplyr)

set.seed(853)

simulated_dataset <-
  tibble(
    prime_minister = sample(
      x = babynames |> filter(prop > 0.01) |>
        select(name) |> unique() |>unlist(),
      size = 10,
      replace = FALSE
    ),
    birth_year = sample(
      x = c(1700:1990),
      size = 10,
      replace = TRUE
    ),
    years_lived = sample(
      x = c(50:100),
      size = 10,
      replace = TRUE
    ),
    death_year = birth_year + years_lived
  ) |>
  select(prime_minister, birth_year, death_year, years_lived) |>
  arrange(birth_year)

simulated_dataset