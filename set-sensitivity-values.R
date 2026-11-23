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

# Both camera and camera-aerial models ----
bInitialAbundance <- 
  tribble(
      ~m, ~default, ~scenario,
     200,    FALSE,     "200",
     400,     TRUE,        NA,
     600,    FALSE,     "600"
  ) %>% 
  rename(
    mean_abundance_init = m
  )

bSurvival <- 
  tribble(
  ~mean_surv_FA, ~default, ~scenario,
    logit(0.94),     TRUE,        NA,
    logit(0.90),    FALSE,    "fa90",
    logit(0.80),    FALSE,    "fa80"
  )

bPropVecInit <- tribble(
  ~alpha_vec,                          ~default,              ~scenario,
  c(10, 5, 40, 10, 5, 5, 5, 20),           TRUE,                     NA,
  c(100, 50, 400, 100, 50, 50, 50, 200),   FALSE, "default-more-certain",
  rep(100, 8),                            FALSE,   "prop-equal-certain",
  rep(1, 8),                              FALSE, "prop-equal-uncertain"
)

sensitivity_values <-
  bind_rows(
    bInitialAbundance %>% 
      mutate(variable = str_c("bInitialAbundance", scenario, sep = "-")) %>%
      select(-default, -scenario) %>% 
      cross_join(bPropVecInit %>% filter(default) %>% select(-default, -scenario)) %>% 
      cross_join(bSurvival %>% filter(default) %>% select(-default, -scenario)),
    bPropVecInit %>% 
      mutate(variable = str_c("bPropVecInit", scenario, sep = "-")) %>% 
      select(-default, -scenario) %>% 
      cross_join(bInitialAbundance %>% filter(default) %>% select(-default, -scenario)) %>% 
      cross_join(bSurvival %>% filter(default) %>% select(-default, -scenario)),
    bSurvival %>% 
      mutate(variable = str_c("bSurvival", scenario, sep = "-")) %>% 
      select(-default, -scenario) %>% 
      cross_join(bInitialAbundance %>% filter(default) %>% select(-default, -scenario)) %>% 
      cross_join(bPropVecInit %>% filter(default) %>% select(-default, -scenario))
  ) %>% 
  group_by(
    mean_abundance_init, alpha_vec, mean_surv_FA
  ) %>% 
  add_count() %>% 
  mutate(
    variable = if_else2(n > 1, "default", variable)
  ) %>% 
  slice_head() %>% 
  ungroup() %>% 
  select(-n) %>% 
  relocate(variable, .before = everything()) %>% 
  arrange(variable)

sbf_set_sub("aerial")
sbf_save_data(sensitivity_values %>% filter(variable == "default"), x_name = "sensitivity_values")
sbf_set_sub("camera")
sbf_save_data(sensitivity_values %>% filter(variable == "default"), x_name = "sensitivity_values")
sbf_set_sub("camera-aerial")
sbf_save_data(sensitivity_values)
