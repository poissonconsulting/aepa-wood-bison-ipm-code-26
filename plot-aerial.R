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

sbf_set_sub("data", "aerial")

aerial_data <- sbf_load_data("aerial_data")

aerial_data %<>% 
  mutate(
    study_year = dtt_study_year(date, start = 4L),
    annual = factor(study_year),
    sd = estimate * cv,
    lower = truncnorm::qtruncnorm(0.025, a = 0, mean = estimate, sd = sd),
    upper = truncnorm::qtruncnorm(0.975, a = 0, mean = estimate, sd = sd)
  )

# Census
abundance <- aerial_data %>% filter(type == "census")

gp <- ggplot(abundance) +
  geom_pointrange(aes(x = annual, y = estimate, ymin = lower, ymax = upper)) +
  xlab("Study Year") +
  ylab("Abundance") +
  expand_limits(y = 0) +
  NULL

sbf_open_window(4, 2)
sbf_print(gp)

sbf_save_plot(
  x_name = "annual-abundance"
)

# Proportion of calves
prop_calf <- aerial_data %>% filter(type == "proportion_calf")

gp <- ggplot(prop_calf) +
  geom_pointrange(aes(x = annual, y = estimate, ymin = lower, ymax = upper)) +
  xlab("Study Year") +
  ylab("Proportion of Calves (%)") +
  scale_y_continuous(labels = scales::percent) +
  expand_limits(y = c(0, 1)) +
  NULL

sbf_open_window(4, 2)
sbf_print(gp)

sbf_save_plot(
  x_name = "proportion-calves"
)

# Minimum counts
minimum_count <- aerial_data %>% filter(type == "minimum_count")

gp <- ggplot(minimum_count) +
  geom_point(aes(x = annual, y = estimate)) +
  xlab("Study Year") +
  ylab("Minimum Count") +
  expand_limits(y = 0) +
  NULL

sbf_open_window(4, 2)
sbf_print(gp)
