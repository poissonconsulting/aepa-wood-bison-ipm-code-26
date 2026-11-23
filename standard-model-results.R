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

sbf_set_sub("camera-aerial")
location_distance <- sbf_load_object("location_distance")

print(sbf_set_sub("camera-aerial", "default"))

analysis <- sbf_load_object("analysis")
data <- data_set(analysis)

seasons_long <-
  bpt_seasons() |>
  dplyr::group_by(.data$season) |>
  tidyr::expand(
    dayte = base::seq(.data$start_dayte, .data$end_dayte, "day")
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(dayte = dttr2::dtt_dayte(.data$dayte)) %>% 
  mutate(season = factor(season, levels = c("Calving", "Summer/Fall", "Winter")))

doy <- 
  xnew_data(data, annual, xcast(doy = 1:365)) %>% 
  mutate(
    year = as.integer(str_sub(annual, end = 4L)),
    date = dtt_doy_to_date(doy + 90, year)
  ) %>% 
  filter(date >= dtt_date("2018-04-01")) %>% 
  filter(date <= dtt_date("2024-03-31")) %>% 
  mutate(dayte = dtt_dayte(date)) %>% 
  select(-season) %>% 
  left_join(seasons_long, join_by(dayte))


f0 <- predict(analysis, doy, term = "eAbundanceF0Doy", sd = FALSE) %>% mutate(class = "F0")
f1 <- predict(analysis, doy, term = "eAbundanceF1Doy", sd = FALSE) %>% mutate(class = "F1")
fa <- predict(analysis, doy, term = "eAbundanceFADoy", sd = FALSE) %>% mutate(class = "FA")
m0 <- predict(analysis, doy, term = "eAbundanceM0Doy", sd = FALSE) %>% mutate(class = "M0")
m1 <- predict(analysis, doy, term = "eAbundanceM1Doy", sd = FALSE) %>% mutate(class = "M1")
bull <- predict(analysis, doy, term = "eAbundanceBullDoy", sd = FALSE) %>% mutate(class = "Bull")
all <- predict(analysis, doy, term = "eAbundanceDoy", sd = FALSE) %>% mutate(class = "All")

seasons <- 
  bpt_seasons() %>% 
  cross_join(tibble(year = unique(doy$year))) %>% 
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

aerial <- sbf_load_plot_data("annual-abundance", "data/aerial") %>% 
  mutate(type = "Population\nEstimate")

prop_calf <- sbf_load_plot_data("proportion-calves", "data/aerial") %>%
  mutate(type = "Proportion of\nCalves")

data %<>% 
  mutate(
    year = as.integer(str_sub(annual, end = 4L)),
    date = dtt_doy_to_date(doy + 90, year)
  )

abundance_panels <- bind_rows(
  all %>% mutate(panel = "All", class = "All"),
  fa %>% mutate(panel = "Female", class = "Sub-Adult & Adult"),
  f1 %>% mutate(panel = "Female", class = "Yearling"),
  f0 %>% mutate(panel = "Female", class = "Calf"),
  bull %>% mutate(panel = "Male", class = "Sub-Adult & Adult"),
  m1 %>% mutate(panel = "Male", class = "Yearling"),
  m0 %>% mutate(panel = "Male", class = "Calf")
) %>%
  mutate(
    panel = factor(panel, levels = c("All", "Female", "Male")),
    class = factor(class, levels = c("All", "Sub-Adult & Adult", "Yearling", "Calf"))
  )

shared_limits <- abundance_panels %>%
  filter(panel %in% c("Female", "Male")) %>%
  select(lower, estimate, upper) %>%
  unlist() %>%
  purrr::keep(~ is.finite(.x) & .x > 0) %>%
  range()

aerial_all <- aerial %>% mutate(panel = "All")

gp <- ggplot(abundance_panels, aes(x = date, colour = class)) +
  geom_rect(
    data = seasons,
    aes(
      xmin = start_date,
      xmax = end_date,
      ymin = 0,
      ymax = Inf,
      fill = season
    ),
    inherit.aes = FALSE,
    alpha = 0.3
  ) +
  geom_line(aes(y = lower), linetype = "dotted", linewidth = 0.5) +
  geom_line(aes(y = upper), linetype = "dotted", linewidth = 0.5) +
  geom_line(aes(y = estimate), linewidth = 0.5) +
  geom_pointrange(
    data = aerial_all,
    aes(x = date, y = estimate, ymin = lower, ymax = upper, alpha = type),
    inherit.aes = FALSE,
    colour = pois_cols("crimson"),
    size = 0.3
  ) +
  geom_rug(
    data = data,
    aes(x = date),
    inherit.aes = FALSE,
    linewidth = 0.3,
    length = unit(1.5, "mm")
  ) +
  geom_rug(
    data = prop_calf,
    aes(x = date),
    inherit.aes = FALSE,
    sides = "t",
    linewidth = 0.3,
    length = unit(1.5, "mm")
  ) +
  facet_wrap(vars(panel), ncol = 1, scales = "free_y") +
  facetted_pos_scales(
    y = list(
      scale_y_log10(labels = scales::label_number()),
      scale_y_log10(labels = scales::label_number(), limits = shared_limits),
      scale_y_log10(labels = scales::label_number(), limits = shared_limits)
    )
  ) +
  scale_colour_disc_poisson(order = c("black", "orchid", "blue", "red")) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  scale_alpha_manual(values = 1) +
  scale_x_date(
    expand = c(0.01, 0.01),
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  xlab("Date") +
  ylab("Abundance") +
  labs(colour = "Life Stage", fill = "Season", alpha = "Aerial Survey") +
  guides(
    fill = guide_legend(order = 1),
    colour = guide_legend(order = 2),
    alpha = guide_legend(order = 3)
  ) +
  NULL

sbf_open_window(4.5, 6)
sbf_print(gp)

sbf_save_plot(
  x_name = "standard-abundance-by-class-column"
)

# Survival Rates
surv_f0 <- predict(analysis, "annual", term = "eSurvF0AnnualIM", sd = FALSE) %>% mutate(class = "F0")
surv_f1 <- predict(analysis, "annual", term = "eSurvF1Annual", sd = FALSE) %>% mutate(class = "F1")
surv_fa <- predict(analysis, "annual", term = "eSurvFAAnnual", sd = FALSE) %>% mutate(class = "FA")
surv_m0 <- predict(analysis, "annual", term = "eSurvM0AnnualIM", sd = FALSE) %>% mutate(class = "M0")
surv_m1 <- predict(analysis, "annual", term = "eSurvM1Annual", sd = FALSE) %>% mutate(class = "M1")
surv_bull <- predict(analysis, "annual", term = "eSurvBullAnnual", sd = FALSE) %>% mutate(class = "Bull")

surv_rates <- bind_rows(surv_f0, surv_f1, surv_fa, surv_m0, surv_m1, surv_bull) %>% 
  mutate(
    class = factor(class, levels = c("F0", "F1", "FA", "M0", "M1", "Bull")),
    sex = if_else2(str_detect(class, "F"), "Female", "Male"),
    age = case_when(
      str_detect(class, "0") ~ "Calf",
      str_detect(class, "1") ~ "Yearling",
      TRUE ~ "Sub-Adults & Adults"
    ),
    age = factor(age, levels = c("Calf", "Yearling", "Sub-Adults & Adults"))
  )

gp <- ggplot(surv_rates) +
  geom_pointrange(
    aes(x = annual, y = estimate, ymin = lower, ymax = upper, shape = age, colour = sex),
    position = position_dodge(width = 0.5)
  ) +
  scale_colour_disc_poisson(order = c("red", "blue")) +
  scale_y_continuous(labels = percent) +
  expand_limits(y = c(0, 1)) +
  xlab("Study Year") +
  ylab("Survival Rate") +
  labs(colour = "Sex", shape = "Age") +
  guides(color = guide_legend(override.aes = list(shape = NA))) +
  NULL

sbf_open_window(6, 3.5)
sbf_print(gp)

sbf_save_plot(
  x_name = "standard-survival"
)

# Other rates
calf_cow <- predict(analysis, doy, term = "eCalfCowDoy", sd = FALSE)

gp <- ggplot(calf_cow) +
  geom_rect(
    data = seasons,
    aes(
      xmin = start_date, 
      xmax = end_date,
      ymin = 0,
      ymax = 1,
      fill = season
    ),
    alpha = 0.3
  ) + 
  geom_ribbon(aes(x = date, ymin = lower, ymax = upper), alpha = 0.3) +
  geom_line(aes(x = date, y = estimate)) +
  geom_rug(
    data = data,
    aes(x = date),
    linewidth = 0.3,
    length = unit(0.03, "npc")
  ) +
  geom_rug(
    data = prop_calf,
    aes(x = date),
    sides = "t",
    linewidth = 0.3,
    length = unit(0.03, "npc")
  ) +
  scale_x_date(expand = c(0.01, 0.01), date_breaks = "1 year", date_labels = "%Y") +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  xlab("Date") +
  ylab("Calf:Cow") +
  labs(fill = "Season") +
  NULL

sbf_open_window(4, 2)
sbf_print(gp)

sbf_save_plot(
  x_name = "standard-calf-cow"
)

# Annual calf:cow ratio evaluated on July 1
# of the calendar year, rather than the full within-year trend above.
july1_doy <- doy %>%
  filter(format(date, "%m-%d") == "07-01")

# mean across study years calculated for each MCMC sample
calf_cow_july1_mean <-
  mcmc_derive_data(analysis, july1_doy, term = "eCalfCowDoy")$mcmc %>%
  apply(c(1, 2), mean)

calf_cow_july1 <- tibble(
  description = "Mean calf:cow ratio on July 1",
  study_year = "All",
  estimate = median(calf_cow_july1_mean),
  lower = quantile(calf_cow_july1_mean, 0.025),
  upper = quantile(calf_cow_july1_mean, 0.975),
  cv = calculate_cv(calf_cow_july1_mean)
)

# March 31 and derived estimates
summarise_annual <- function(term) {
  predict(analysis, "annual", term = term, sd = FALSE) %>%
    left_join(cv_mcmc(analysis, "annual", term = str_c("^", term, "$")), join_by(annual)) %>%
    mutate(study_year = as.character(annual)) %>%
    select(study_year, estimate, lower, upper, cv)
}

summarise_scalar <- function(term) {
  predict(analysis, character(0), term = term, sd = FALSE) %>%
    select(estimate, lower, upper) %>%
    mutate(
      study_year = "All",
      cv = cv_mcmc(analysis, character(0), term = str_c("^", term, "$"))$cv
    )
}

mar31 <- bind_rows(
  summarise_annual("eAbundanceMar31") %>% mutate(indicator = "Herd abundance"),
  summarise_annual("calf_fa") %>% mutate(indicator = "Calf:cow ratio")
) %>%
  select(indicator, study_year, estimate, lower, upper, cv) %>%
  mutate(across(estimate:cv, \(x) signif(x, 3)))

mar31 %>% print(n = nrow(.))

sbf_save_excel(mar31, x_name = "standard-mar31-estimates")
sbf_save_table(
  mar31,
  x_name = "standard-mar31-estimates"
)

derived_terms <- tribble(
  ~term, ~by_year, ~description,
  "eMeanAbundanceMar31", FALSE, "Mean herd abundance on March 31",
  "eAbundanceChangeMar31", FALSE, "Proportional change in herd abundance on March 31 from the first to the final study year",
  "eMeanCalfCowMar31", FALSE, "Mean calf:cow ratio on March 31",
  "prop_calf", TRUE, "Proportion of calves in the herd on March 31",
  "eMeanSurvF0", FALSE, "Mean annual survival rate of female calves including initial mortality",
  "eMeanSurvM0", FALSE, "Mean annual survival rate of male calves including initial mortality",
  "eMeanSurvF1", FALSE, "Mean annual survival rate of female yearlings",
  "eMeanSurvM1", FALSE, "Mean annual survival rate of male yearlings",
  "eMeanSurvFA", FALSE, "Mean annual survival rate of cows",
  "eMeanSurvBull", FALSE, "Mean annual survival rate of bulls"
)

derived_summary <- derived_terms %>%
  mutate(
    estimates = map2(term, by_year, \(t, y) if (y) summarise_annual(t) else summarise_scalar(t))
  ) %>%
  unnest(estimates) %>%
  select(description, study_year, estimate, lower, upper, cv) %>%
  bind_rows(calf_cow_july1) %>%
  mutate(across(estimate:cv, \(x) signif(x, 3)))

derived_summary %>% print(n = nrow(.))

sbf_save_excel(derived_summary, x_name = "standard-derived-estimates")
sbf_save_table(
  derived_summary,
  x_name = "standard-derived-estimates"
)

# Covariance functions
distance <- seq(min(location_distance), max(location_distance), 0.1)
week <- 0:60

analysis$model$new_expr <- mcmcderive::expression_vectorize(rlang::expr(
  for (i in 1:nObs) {
    eCovarianceSummerFallKm[i] <- bEtaSummerFall^2 * exp(-(bRhoSummerFall^2) * distance[i]^2)
    eCovarianceSummerFallWeek[i] <- bEtaSummerFall^2 * exp(-(bRhoSummerFall^2) * (week[i] * bKmWeekSummerFall[i])^2)

    eCovarianceWinKm[i] <- bEtaWin^2 * exp(-(bRhoWin^2) * distance[i]^2)
    eCovarianceWinWeek[i] <- bEtaWin^2 * exp(-(bRhoWin^2) * (week[i] * bKmWeekWin[i])^2)
  }
))

distance_dat <- tibble(distance = distance) %>%
  cross_join(new_data(data))

covariance_distance <- bind_rows(
  predict(
    analysis,
    new_data = distance_dat,
    new_values = list(distance = distance),
    term = "eCovarianceSummerFallKm",
    sd = FALSE
  ) %>%
    mutate(season = "Summer/Fall"),
  predict(
    analysis,
    new_data = distance_dat,
    new_values = list(distance = distance),
    term = "eCovarianceWinKm",
    sd = FALSE
  ) %>%
    mutate(season = "Winter")
)

week_dat <- tibble(week = week) %>%
  cross_join(new_data(data %>% select(-week)))

covariance_week <- bind_rows(
  predict(analysis, new_data = week_dat, term = "eCovarianceSummerFallWeek", sd = FALSE) %>%
    mutate(season = "Summer/Fall"),
  predict(analysis, new_data = week_dat, term = "eCovarianceWinWeek", sd = FALSE) %>%
    mutate(season = "Winter")
)

gp1 <- ggplot(data = covariance_distance, aes(x = distance)) +
  geom_line(aes(y = estimate)) +
  geom_line(aes(y = lower), linetype = "dotted") +
  geom_line(aes(y = upper), linetype = "dotted") +
  facet_grid(rows = vars(season)) +
  xlab("Distance (km)") +
  ylab("Covariance") +
  theme(
    strip.text = element_blank(),
    strip.background = element_blank()
  ) +
  NULL

gp2 <- ggplot(data = covariance_week, aes(x = week)) +
  geom_line(aes(y = estimate)) +
  geom_line(aes(y = lower), linetype = "dotted") +
  geom_line(aes(y = upper), linetype = "dotted") +
  facet_grid(rows = vars(season)) +
  xlab("Time (weeks)") +
  ylab("Covariance") +
  theme(
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank()
  ) +
  NULL

gp <- cowplot::plot_grid(gp1, gp2)

sbf_open_window(4, 2)
sbf_print(gp)

sbf_save_plot(
  x_name = "standard-covariance"
)
