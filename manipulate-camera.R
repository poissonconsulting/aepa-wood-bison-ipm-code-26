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

sbf_set_sub("data", "aerial")

data_list <-
  bisonpictools_manipulate_data_analysis(
    event_data = camera_event,
    location_data = camera_location,
    census_data = census_data,
    proportion_calf_data = proportion_calf_data
  )

data <- data_list$data

camera_location %<>% 
  filter(location_id %in% data$location)

location_distance <- bisonpictools::bpt_location_matrix(camera_location)

levels_annual <- sbf_load_object("levels_annual", sub = "aerial")

data %<>% 
  mutate(annual = factor(annual, levels = levels_annual))

# summary of data
mean_group_size <- data %>% pull(groupsize_total) %>% mean()

mean_age_dist <-
  data %>%
  select(calf, yearling, adult) %>% 
  rowwise() %>% 
  mutate(
    prop_calf = calf / (calf + yearling + adult),
    prop_yearling = yearling / (calf + yearling + adult),
    prop_adult = adult / (calf + yearling + adult),
  ) %>% 
  ungroup() %>% 
  summarize(
    mean_prop_calf = mean(prop_calf),
    mean_prop_yearling = mean(prop_yearling),
    mean_prop_adult = mean(prop_adult)
  )

mean_sex_dist <-
  data %>% 
  select(f0, f1, fa, m0, m1, m2, m3, ma) %>% 
  rowwise() %>% 
  mutate(
    prop_female = (f0 + f1 + fa) / (f0 + f1 + fa + m0 + m1 + m2 + m3 + ma),
    prop_female = if_else2((f0 + f1 + fa) == 0, 0, prop_female)
  ) %>% 
  ungroup() %>% 
  summarize(
    mean_prop_female = mean(prop_female)
  )

camera_event_dates <- dtt_date_from_ints(
  camera_event$start_year, camera_event$start_month, camera_event$start_day
)

camera_event_summary <-
  tibble(
    events_recorded = nrow(camera_event),
    first_event_date = min(camera_event_dates),
    last_event_date = max(camera_event_dates),
    events_modelled = nrow(data),
    locations_modelled = n_distinct(data$location),
    mean_group_size = mean_group_size
  ) %>%
  bind_cols(mean_age_dist, mean_sex_dist) %>%
  mutate(across(starts_with("mean"), \(x) signif(x, 3)))

sbf_set_sub("camera")
sbf_save_table(camera_event_summary, x_name = "camera-event-summary")
sbf_save_data(data)
sbf_save_object(levels_annual)
sbf_save_object(location_distance)
