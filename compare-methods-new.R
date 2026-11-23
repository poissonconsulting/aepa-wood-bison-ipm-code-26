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
sensitivity_values <- sbf_load_data("sensitivity_values") %>% 
  filter(variable != "default")

seasons_long <-
  bpt_seasons() |>
  dplyr::group_by(.data$season) |>
  tidyr::expand(
    dayte = base::seq(.data$start_dayte, .data$end_dayte, "day")
  ) |>
  dplyr::ungroup() |>
  dplyr::mutate(dayte = dttr2::dtt_dayte(.data$dayte)) %>% 
  mutate(season = factor(season, levels = c("Calving", "Summer/Fall", "Winter")))

make_doy <- function(data) {
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
}

compare_to_ref <- function(ref_samples, cur_samples) {
  combine_samples(
    ref_samples,
    cur_samples,
    fun = prop_difference,
    join_by(
      f0, f1, m2, m3, ma, fa, m0, m1, u0, u1, ua, calf, yearling, adult, 
      groupsize_total, annual, week, weekfac, doy, doy_fac, location, 
      location_weekfac, season_annual, id, year, date, dayte, season, class
    )
  ) %>% 
    coef()
}

save_perc_diff_plots <- function(abundance, calf_cow) {
  gp <- ggplot(data = abundance) +
    geom_line(
      aes(x = date, y = estimate),
      alpha = 0.9
    ) +
    NULL

  sbf_open_window(4, 3) 
  sbf_print(gp)

  sbf_save_plot(
    x_name = "abundance-perc-diff"
  )

  gp <- ggplot(data = calf_cow) +
    geom_line(
      aes(x = date, y = estimate),
      alpha = 0.9
    ) +
    NULL

  sbf_open_window(4, 3) 
  sbf_print(gp)

  sbf_save_plot(
    x_name = "calf-cow-perc-diff"
  )
}

ref <- sbf_load_object(x_name = "analysis", sub = "camera-aerial/default")

data_scenarios <- c("camera", "aerial")

for (dat in data_scenarios) {
  print(sbf_set_sub(dat, "default"))
  analysis <- sbf_load_object("analysis")
  data <- data_set(analysis)

  sbf_set_sub("compare", dat, "default")

  doy <- make_doy(data)

  abundance <- compare_to_ref(
    mcmc_derive_data(ref, doy, term = "eAbundanceDoy") %>% 
      mutate(class = "All"),
    mcmc_derive_data(analysis, doy, term = "eAbundanceDoy") %>% 
      mutate(
        class = "All",
        scenario = "Default",
        variable = str_c(str_to_title(dat), " Data Only")
      )
  )

  calf_cow <- compare_to_ref(
    mcmc_derive_data(ref, doy, term = "eCalfCowDoy") %>% 
      mutate(class = "All"),
    mcmc_derive_data(analysis, doy, term = "eCalfCowDoy") %>% 
      mutate(
        class = "All",
        scenario = "Default",
        variable = str_c(str_to_title(dat), " Data Only")
      )
  )

  save_perc_diff_plots(abundance, calf_cow)
}

# All camera-aerial scenarios share the standard model's data, so its derived
# samples are calculated once and reused
doy_ref <- make_doy(data_set(ref))
ref_all_abundance <- mcmc_derive_data(ref, doy_ref, term = "eAbundanceDoy") %>% 
  mutate(class = "All")
ref_all_calf_cow <- mcmc_derive_data(ref, doy_ref, term = "eCalfCowDoy") %>% 
  mutate(class = "All")

vars <- c(sensitivity_values$variable, "no-covariance")
for (var in vars) {
  print(sbf_set_sub("camera-aerial", var))
  analysis <- sbf_load_object("analysis")
  data <- data_set(analysis)

  sbf_set_sub("compare", "camera-aerial", var)

  doy <- make_doy(data)
  chk_identical(doy, doy_ref)

  abundance <- compare_to_ref(
    ref_all_abundance,
    mcmc_derive_data(analysis, doy, term = "eAbundanceDoy") %>% 
      mutate(
        class = "All",
        scenario = get_scenario_comp(var),
        variable = get_variable_comp(var)
      )
  )

  calf_cow <- compare_to_ref(
    ref_all_calf_cow,
    mcmc_derive_data(analysis, doy, term = "eCalfCowDoy") %>% 
      mutate(
        class = "All",
        scenario = get_scenario_comp(var),
        variable = get_variable_comp(var)
      )
  )

  save_perc_diff_plots(abundance, calf_cow)
}

sbf_close_windows()
sbf_set_sub("compare")

seasons <- 
  bpt_seasons() %>% 
  cross_join(tibble(year = unique(abundance$year))) %>% 
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
  mutate(type = "Population Estimate")

prop_calf <- sbf_load_plot_data("proportion-calves", "data/aerial") %>%
  mutate(type = "Proportion of\nCalves")

data %<>% 
  mutate(
    year = as.integer(str_sub(annual, end = 4L)),
    date = dtt_doy_to_date(doy + 90, year)
  )

exclude_colours <- "(No Covariance)|(Camera Data Only)|(Aerial Data Only)"

# last day of the final study year for which camera data were available
camera_last_date <- dtt_date("2022-03-31")

# Median estimate ----
## Abundance ----
compare_abundance <-
  sbf_load_plots_data_recursive(x_name = "^abundance-perc-diff$") %>%
  unnest(cols = plots_data) %>%
  mutate(
    var_label = str_c(variable, "\n", scenario),
    scenario = factor(scenario),
    scenario = fct_relevel(scenario, "Default"),
    linetype_grp = if_else2(
      variable == "Camera Data Only" & date > camera_last_date,
      "Forecast",
      "Observed"
    )
  )

# duplicate the boundary date so the dashed segment connects to the solid one
compare_abundance <- bind_rows(
  compare_abundance,
  compare_abundance %>%
    filter(variable == "Camera Data Only", date == camera_last_date) %>%
    mutate(linetype_grp = "Forecast")
)


gp <- ggplot() +
  geom_rect(
    data = seasons,
    aes(
      xmin = start_date, 
      xmax = end_date,
      ymin = min(-0.3, compare_abundance$estimate),
      ymax = max(0.22, compare_abundance$estimate),
      fill = season
    ),
    alpha = 0.3
  ) + 
  facet_wrap(~variable, nrow = 3) +
  geom_rug(
    data = aerial, # aerial
    aes(x = date),
    linewidth = 0.3,
    sides = "t"
  ) +
  geom_rug(
    data = data, # camera
    aes(x = date),
    linewidth = 0.1
  ) +
  geom_hline(
    yintercept = 0,
    linewidth = 0.2,
    linetype = "dotted"
  ) +
  geom_line(
    data = compare_abundance %>%
      filter(str_detect(var_label, exclude_colours)) %>%
      select(date, estimate, scenario, variable, linetype_grp),
    aes(x = date, y = estimate, colour = scenario, linetype = linetype_grp),
    alpha = 0.8
  ) +
  geom_line(
    data = compare_abundance %>%
      filter(!str_detect(var_label, exclude_colours)) %>%
      select(date, estimate, scenario, variable, linetype_grp),
    aes(x = date, y = estimate, colour = scenario, linetype = linetype_grp),
    alpha = 0.8
  ) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  scale_colour_disc_poisson() +
  scale_linetype_manual(values = c(Observed = "solid", Forecast = "dashed"), guide = "none") +
  scale_y_continuous(
    transform = nfold_trans2(),
    labels = percent,
    expand = c(0, 0)
  ) +
  scale_x_date(
    expand = c(0.01, 0.01), 
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  xlab("Date") +
  ylab("Herd Abundance (% Difference from Standard Model)") +
  labs(
    colour = "Prior Scenario", 
    fill = "Season"
  ) +
  NULL

sbf_open_window(6) 
sbf_print(gp)

sbf_save_plot(
  x_name = "compare-perc-diff-abundance"
)

## Calf:cow ----
compare_calf_cow <-
  sbf_load_plots_data_recursive(x_name = "calf-cow-perc-diff$") %>%
  unnest(cols = plots_data) %>%
  mutate(
    var_label = str_c(variable, "\n", scenario),
    scenario = factor(scenario),
    scenario = fct_relevel(scenario, "Default"),
    linetype_grp = if_else2(
      variable == "Camera Data Only" & date > camera_last_date,
      "Forecast",
      "Observed"
    )
  )

# duplicate the boundary date so the dashed segment connects to the solid one
compare_calf_cow <- bind_rows(
  compare_calf_cow,
  compare_calf_cow %>%
    filter(variable == "Camera Data Only", date == camera_last_date) %>%
    mutate(linetype_grp = "Forecast")
)

gp <- ggplot() +
  geom_rect(
    data = seasons,
    aes(
      xmin = start_date, 
      xmax = end_date,
      ymin = -0.67,
      ymax = 2,
      fill = season
    ),
    alpha = 0.3
  ) + 
  facet_wrap(~variable, nrow = 3) +
  geom_rug(
    data = data, # camera
    aes(x = date),
    linewidth = 0.1
  ) +
  geom_rug(
    data = prop_calf, # aerial
    aes(x = date),
    sides = "t",
    linewidth = 0.3
  ) +
  geom_hline(
    yintercept = 0,
    linewidth = 0.2,
    linetype = "dotted"
  ) +
  geom_line(
    data = compare_calf_cow %>% filter(str_detect(var_label, exclude_colours)),
    aes(x = date, y = estimate, colour = scenario, linetype = linetype_grp),
    alpha = 0.8
  ) +
  geom_line(
    data = compare_calf_cow %>% filter(!str_detect(var_label, exclude_colours)),
    aes(x = date, y = estimate, colour = scenario, linetype = linetype_grp),
    alpha = 0.8
  ) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  scale_colour_disc_poisson() +
  scale_linetype_manual(values = c(Observed = "solid", Forecast = "dashed"), guide = "none") +
  scale_y_continuous(
    transform = nfold_trans2(),
    labels = percent,
    expand = c(0, 0)
  ) +
  scale_x_date(
    expand = c(0.01, 0.01),
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  xlab("Date") +
  ylab("Calf:Cow Ratio (% Difference from Standard Model)") +
  labs(
    colour = "Prior Scenario", 
    fill = "Season"
  ) +
  NULL

sbf_open_window(6) 
sbf_print(gp)

sbf_save_plot(
  x_name = "compare-perc-diff-calf-cow"
)
# CV ----
nocovar <- sbf_load_object(x_name = "analysis", sub = "camera-aerial/no-covariance")

data_nocovar <- data_set(nocovar)

doy_nocovar <- make_doy(data_nocovar)

## Abundance ----
ref_cv_abundance <- cv_mcmc(ref, doy_nocovar, term = "eAbundanceDoy") %>%
  select(date, cv) %>%
  rename(cv_ref = cv)
nocovar_cv_abundance <- cv_mcmc(nocovar, doy_nocovar, term = "eAbundanceDoy") %>%
  select(date, cv) %>%
  rename(cv_nocovar = cv)

cv_diff_abundance <- left_join(ref_cv_abundance, nocovar_cv_abundance, by = "date") %>%
  mutate(cv_perc_diff = (cv_nocovar - cv_ref) / cv_ref)

## Calf:Cow ----
ref_cv_calf_cow <- cv_mcmc(ref, doy_nocovar, term = "eCalfCowDoy") %>%
  select(date, cv) %>%
  rename(cv_ref = cv)
nocovar_cv_calf_cow <- cv_mcmc(nocovar, doy_nocovar, term = "eCalfCowDoy") %>%
  select(date, cv) %>%
  rename(cv_nocovar = cv)

cv_diff_calf_cow <- left_join(ref_cv_calf_cow, nocovar_cv_calf_cow, by = "date") %>%
  mutate(cv_perc_diff = (cv_nocovar - cv_ref) / cv_ref)

## Combined plot ----
variable_levels_cv <- c("Herd Abundance", "Calf:Cow Ratio")

cv_diff_combined <- bind_rows(
  cv_diff_abundance %>% mutate(variable = "Herd Abundance"),
  cv_diff_calf_cow %>% mutate(variable = "Calf:Cow Ratio")
) %>%
  mutate(variable = factor(variable, levels = variable_levels_cv))

top_rug_cv <- bind_rows(
  aerial %>% mutate(variable = "Herd Abundance"),
  prop_calf %>% mutate(variable = "Calf:Cow Ratio")
) %>%
  mutate(variable = factor(variable, levels = variable_levels_cv))

# pad below the lowest value (on the n-fold scale) so the bottom rug clears the line
cv_ymin <- nfold2prop(prop2nfold(min(cv_diff_combined$cv_perc_diff)) - 0.3)

gp <- ggplot() +
  geom_rect(
    data = seasons %>%
      cross_join(cv_diff_combined %>% distinct(variable)) %>%
      mutate(
        ymin = cv_ymin,
        ymax = 0.15
      ),
    aes(
      xmin = start_date, 
      xmax = end_date, 
      ymin = ymin,
      ymax = ymax,
      fill = season
    ),
    alpha = 0.3
  ) +
  facet_wrap(~variable, nrow = 2) +
  geom_rug(
    data = top_rug_cv,
    aes(x = date),
    linewidth = 0.3,
    sides = "t"
  ) +
  geom_rug(
    data = data,
    aes(x = date),
    linewidth = 0.1
  ) +
  geom_hline(
    yintercept = 0,
    linewidth = 0.2,
    linetype = "dotted"
  ) +
  geom_line(
    data = cv_diff_combined,
    aes(x = date, y = cv_perc_diff),
    alpha = 0.8
  ) +
  scale_fill_discrete(type = c("#63BB42", "#F7B500", "#7D7D7D")) +
  scale_y_continuous(
    transform = nfold_trans2(),
    labels = percent,
    expand = c(0, 0)
  ) +
  scale_x_date(
    expand = c(0.01, 0.01),
    date_breaks = "1 year",
    date_labels = "%Y"
  ) +
  xlab("Date") +
  ylab("CV (% Difference from Standard Model)") +
  labs(fill = "Season") +
  NULL

sbf_open_window(4)
sbf_print(gp)

sbf_save_plot(
  x_name = "compare-cv-diff"
)

# Values for text ----
# Percent differences from the standard model, over the whole study period
# and by study year
summarise_perc_diff <- function(x, ...) {
  x %>%
    group_by(variable, scenario, ...) %>%
    arrange(date, .by_group = TRUE) %>%
    summarise(
      min = min(estimate),
      max = max(estimate),
      first = first(estimate),
      last = last(estimate),
      .groups = "drop"
    ) %>%
    mutate(across(min:last, \(x) signif(100 * x, 3)))
}

perc_diff_summary <- bind_rows(
  summarise_perc_diff(compare_abundance) %>% mutate(quantity = "Herd abundance"),
  summarise_perc_diff(compare_calf_cow) %>% mutate(quantity = "Calf:cow ratio")
) %>%
  relocate(quantity)

perc_diff_summary_annual <- bind_rows(
  summarise_perc_diff(compare_abundance, annual) %>% mutate(quantity = "Herd abundance"),
  summarise_perc_diff(compare_calf_cow, annual) %>% mutate(quantity = "Calf:cow ratio")
) %>%
  relocate(quantity)

cv_perc_diff_summary <- cv_diff_combined %>%
  group_by(variable) %>%
  summarise(
    mean = mean(cv_perc_diff),
    min = min(cv_perc_diff),
    max = max(cv_perc_diff)
  ) %>%
  mutate(across(mean:max, \(x) signif(100 * x, 3)))

perc_diff_summary %>% print(n = nrow(.))
cv_perc_diff_summary %>% print()

sbf_set_sub("compare")
sbf_save_table(perc_diff_summary, x_name = "perc-diff-summary")
sbf_save_table(perc_diff_summary_annual, x_name = "perc-diff-summary-annual")
sbf_save_table(cv_perc_diff_summary, x_name = "cv-perc-diff-summary")
