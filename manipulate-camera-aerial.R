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

sbf_load_datas("camera")
sbf_load_datas("data/aerial")

bisonpictools::bpt_check_data(
  event = camera_event,
  location = camera_location,
  census = census_data,
  proportion_calf = proportion_calf_data
)

data_list <-
  # adapted in functions.R to allow census year to be outside of event data years
  bisonpictools_manipulate_data_analysis(
    event_data = camera_event,
    location_data = camera_location,
    census_data = census_data,
    proportion_calf_data = proportion_calf_data
  )

data <- data_list$data
census_data <- data_list$census_data
proportion_calf_data <- data_list$prop_calf_data

camera_location %<>% 
  filter(location_id %in% data$location)

location_distance <- bisonpictools::bpt_location_matrix(camera_location)

study_years <- sort(unique(c(levels(data$annual), census_data$census_study_year)))
min_study_year <- str_extract(study_years[1], "\\d{4}") %>% as.integer()
max_study_year <- str_extract(study_years[length(study_years)], "\\d{4}") %>% as.integer()
levels_annual <- dtt_study_year(dtt_date(str_c(seq(min_study_year, max_study_year), "-04-01")), start = 4L)

data %<>% 
  mutate(annual = factor(annual, levels = levels_annual))

minimum_count_data %<>% 
  mutate(annual = factor(study_year, levels = unique(census_data$census_study_year))) %>% 
  filter(!is.na(annual)) %>% 
  select(annual, minimum_count)

proportion_calf_data %<>% 
  filter(prop_calf_study_year %in% levels_annual)

sbf_set_sub("camera-aerial")
sbf_save_data(data)
sbf_save_data(census_data)
sbf_save_data(proportion_calf_data)
sbf_save_data(minimum_count_data)
sbf_save_object(levels_annual)
sbf_save_object(location_distance)
