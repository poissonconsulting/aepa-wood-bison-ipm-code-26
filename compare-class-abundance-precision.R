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

options(mb.parallel = FALSE)

seasons_long <-
  bpt_seasons() |>
  dplyr::group_by(.data$season) |>
  tidyr::expand(
    dayte = base::seq(.data$start_dayte, .data$end_dayte, "day")
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(dayte = dttr2::dtt_dayte(.data$dayte)) %>%
  mutate(season = factor(season, levels = c("Calving", "Summer/Fall", "Winter")))

class_terms <- tibble(
  term = c(
    "eAbundanceF0Doy", "eAbundanceF1Doy", "eAbundanceFADoy",
    "eAbundanceM0Doy", "eAbundanceM1Doy", "eAbundanceM2Doy",
    "eAbundanceM3Doy", "eAbundanceMADoy"
  ),
  class_label = c("F0", "F1", "FA", "M0", "M1", "M2", "M3", "MA")
)

scenarios <- tibble(
  sub = c("camera-aerial/default", "camera/default", "aerial/default"),
  scenario = c("Camera + Aerial", "Camera Only", "Aerial Only")
)

cv_class <- vector("list", nrow(scenarios))

for (i in seq_len(nrow(scenarios))) {
  print(sbf_set_sub(scenarios$sub[i]))
  analysis <- sbf_load_object("analysis")
  data <- data_set(analysis)

  doy <-
    xnew_data(data, annual, xcast(doy = round(seq(1, 365, length.out = 52)))) %>%
    mutate(
      year = as.integer(str_sub(annual, end = 4L)),
      date = dtt_doy_to_date(doy + 90, year)
    ) %>%
    filter(date >= dtt_date("2018-04-01")) %>%
    filter(date <= dtt_date("2024-03-31")) %>%
    mutate(dayte = dtt_dayte(date)) %>%
    select(-season) %>%
    left_join(seasons_long, join_by(dayte))

  class_cv_list <- vector("list", nrow(class_terms))
  for (j in seq_len(nrow(class_terms))) {
    class_cv_list[[j]] <-
      cv_mcmc(analysis, doy, term = class_terms$term[j]) %>%
      select(date, cv) %>%
      mutate(class_label = class_terms$class_label[j])
  }

  cv_class[[i]] <-
    bind_rows(class_cv_list) %>%
    mutate(scenario = scenarios$scenario[i])
}

cv_class <- bind_rows(cv_class) %>%
  mutate(
    class_label = factor(class_label, levels = class_terms$class_label),
    scenario = factor(scenario, levels = scenarios$scenario)
  )

sbf_set_sub("compare")

seasons <-
  bpt_seasons() %>%
  cross_join(tibble(year = unique(cv_class$date %>% dtt_year()))) %>%
  rowwise() %>%
  mutate(
    start_year = dtt_year(start_dayte),
    end_year = dtt_year(end_dayte),
    year_diff = end_year - start_year,
    start_date = dtt_date(str_c(year, str_sub(start_dayte, start = 5L))),
    end_date = dtt_date(str_c(year + year_diff, str_sub(end_dayte, start = 5L))),
  ) %>%
  select(season, start_date, end_date) %>%
  filter(end_date >= "2018-04-01" & start_date <= "2024-03-31")

gp <- ggplot() +
  geom_rect(
    data = seasons,
    aes(
      xmin = start_date,
      xmax = end_date,
      ymin = -Inf,
      ymax = Inf,
      fill = season
    ),
    alpha = 0.3
  ) +
  facet_wrap(~class_label, nrow = 4) +
  geom_line(
    data = cv_class,
    aes(x = date, y = cv, colour = scenario),
    alpha = 0.8
  ) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  scale_colour_disc_poisson() +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  expand_limits(y = c(0, 1)) +
  scale_x_date(
    expand = c(0.01, 0.01),
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  xlab("Date") +
  ylab("Coefficient of Variation") +
  labs(
    colour = "Data Source",
    fill = "Season"
  ) +
  NULL

sbf_open_window(6, 6)
sbf_print(gp)

sbf_save_plot(
  x_name = "compare-class-abundance-cv"
)
