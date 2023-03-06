#### Preamble ####
#
#

# Setup environment
library(rvest)
library(tidyverse)
library(xml2)
library(tidyr)

# Scrape data
raw_data <-
  read_html("https://en.wikipedia.org/wiki/List_of_prime_ministers_of_Australia")
write_html(raw_data, "pms.html")

# Read in our saved data
raw_data <- read_html("pms.html")

# We can parse tags in order
parse_data_selector_gadget <-
  raw_data |>
  html_element(".wikitable") |>
  html_table()

head(parse_data_selector_gadget)

# Parse our data
parsed_data <-
  parse_data_selector_gadget |> 
  janitor::clean_names() |> 
  rename(raw_text = name_birth_death_constituency) |> 
  select(raw_text) |> 
  filter(raw_text != "Name(birth–death)Constituency" ) |> 
  distinct() 

head(parsed_data)

# Clean our data
initial_clean <-
  parsed_data |>
  separate(
    raw_text,
    into = c("name", "not_name"),
    sep = "\\(",
    extra = "merge"
  ) |> 
  mutate(date = str_extract(not_name, "[[:digit:]]{4}–[[:digit:]]{4}"),
         born = str_extract(not_name, "born[[:space:]][[:digit:]]{4}"),
  ) |> # Alive PMs have slightly different format and only have born
  select(name, date, born)

head(initial_clean)

# Clean up the columns
cleaned_data <-
  initial_clean |>
  # PMs who have died have their birth and death years 
  # separated by a hyphen, but we need to be careful with 
  # the hyphen as it seems to be a slightly odd type of 
  # hyphen and we need to copy/paste it.
  separate(date, into = c("birth", "died"), 
           sep = "–") |> 
  mutate(
    born = str_remove_all(born, "born[[:space:]]"),
    birth = if_else(!is.na(born), born, birth)
  ) |> # Alive PMs have slightly different format
  select(-born) |>
  rename(born = birth) |> 
  # Remove some HTML tags that remain
  # mutate(Name = str_remove(Name, "\n")) |> 
  # Change birth and death to integers
  mutate(across(c(born, died), as.integer)) |> 
  # Add column of the number of years they lived
  mutate(Age_at_Death = died - born) |> 
  # Some of the PMs had two goes at it.
  distinct() 

head(cleaned_data)

#### Save the data in our input folder
write.csv(x = cleaned_data,
          file = here::here("inputs/data/cleaned_data.csv"))

