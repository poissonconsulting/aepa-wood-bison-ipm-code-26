# Copyright 2026 Province of Alberta
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source("header.R")

dir <- "data"

files <- c("aerial_census.csv", "aerial_proportion_calf.csv")
missing <- files[!file.exists(file.path(dir, files))]
if (length(missing)) {
  warning(
    "Data file(s) not found in ", dir, "/: ", str_c(missing, collapse = ", "), ". ",
    "Download the data from https://doi.org/10.5281/zenodo.24407090 and save the files in ", dir, "/."
  )
}

aerial_census <- read_csv(file.path(dir, "aerial_census.csv"))
aerial_proportion_calf <- read_csv(file.path(dir, "aerial_proportion_calf.csv"))

census_data <-
  aerial_census %>%
  mutate(census_cv = census_se / census) %>%
  select(
    census_year = year, census_month = month, census_day = day,
    census, census_cv
  )

# the minimum counts are the sample sizes for the proportion of calves
proportion_calf_data <-
  aerial_proportion_calf %>%
  mutate(
    proportion_calf_sd = binomial_se(n = minimum_count, p = proportion_calf),
    proportion_calf_cv = proportion_calf_sd / proportion_calf
  ) %>%
  select(
    proportion_calf_year = year, proportion_calf_month = month,
    proportion_calf_day = day, proportion_calf, proportion_calf_cv
  )

minimum_count_data <-
  aerial_proportion_calf %>%
  select(
    minimum_count_year = year, minimum_count_month = month,
    minimum_count_day = day, minimum_count
  )

aerial_data <- 
  bind_rows(
    census_data %>% 
      rename_with(.fn = \(x) str_remove(x, "census_")) %>% 
      mutate(type = "census") %>% 
      rename(estimate = census),
    proportion_calf_data %>% 
      rename_with(.fn = \(x) str_remove(x, "proportion_calf_")) %>% 
      mutate(type = "proportion_calf") %>% 
      rename(estimate = proportion_calf),
    minimum_count_data %>% 
      rename_with(.fn = \(x) str_remove(x, "minimum_count_")) %>% 
      mutate(type = "minimum_count") %>% 
      rename(estimate = minimum_count)
  ) %>% 
  mutate(date = dtt_date_from_ints(year, month, day)) %>% 
  select(date, type, estimate, cv)

minimum_count_data %<>% 
  mutate(
    study_year = dtt_study_year(
      dtt_date_from_ints(minimum_count_year, minimum_count_month, minimum_count_day),
      start = 4L
    )
  ) %>% 
  select(study_year, minimum_count)

sbf_set_sub("data", "aerial")
sbf_save_data(census_data)
sbf_save_data(proportion_calf_data)
sbf_save_data(minimum_count_data)
sbf_save_data(aerial_data)
