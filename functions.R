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

bisonpictools_manipulate_data_analysis <- function(
    event_data,
    location_data,
    census_data,
    proportion_calf_data) {
  data <- bpt_check_data(
    event = event_data,
    location = location_data,
    census = census_data,
    proportion_calf = proportion_calf_data,
    complete = TRUE,
    join = TRUE,
    check_study_years = FALSE
  )
  
  census_data <- data$census |>
    dplyr::mutate(
      date = dttr2::dtt_date_from_ints(
        year = .data$census_year,
        month = .data$census_month,
        day = .data$census_day
      ),
      census_study_year = dttr2::dtt_study_year(date, start = 4L),
      doy = dttr2::dtt_doy(.data$date) -
        dttr2::dtt_doy(dttr2::dtt_date_from_ints(.data$census_year, 4L, 1L)),
      leap_year = as.integer(
        dttr2::dtt_leap_year(.data$date) &
          (.data$date >= dttr2::dtt_date_from_ints(
            year = .data$census_year,
            month = 3L,
            day = 1L
          )
          )
      ),
      doy = dplyr::if_else(.data$doy < 0, .data$doy + 366 + .data$leap_year, .data$doy),
      census_doy = base::as.integer(.data$doy),
    ) |>
    dplyr::select(
      "census", "census_cv", "census_study_year", "census_doy"
    )
  
  prop_calf_data <- data$proportion_calf |>
    dplyr::rename(
      prop_calf = "proportion_calf",
      prop_calf_cv = "proportion_calf_cv",
    ) |>
    dplyr::mutate(
      date = dttr2::dtt_date_from_ints(
        year = .data$proportion_calf_year,
        month = .data$proportion_calf_month,
        day = .data$proportion_calf_day
      ),
      prop_calf_study_year = dttr2::dtt_study_year(date, start = 4L),
      doy = dttr2::dtt_doy(.data$date) -
        dttr2::dtt_doy(dttr2::dtt_date_from_ints(.data$proportion_calf_year, 4L, 1L)),
      leap_year = as.integer(
        dttr2::dtt_leap_year(.data$date) &
          (.data$date >= dttr2::dtt_date_from_ints(
            year = .data$proportion_calf_year,
            month = 3L,
            day = 1L
          )
          )
      ),
      doy = dplyr::if_else(.data$doy < 0, .data$doy + 366 + .data$leap_year, .data$doy),
      prop_calf_doy = base::as.integer(.data$doy),
    ) |>
    dplyr::select(
      "prop_calf", "prop_calf_cv", "prop_calf_study_year", "prop_calf_doy"
    )
  
  seasons_long <-
    bpt_seasons() |>
    dplyr::group_by(.data$season) |>
    tidyr::expand(
      dayte = base::seq(.data$start_dayte, .data$end_dayte, "day")
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(dayte = dttr2::dtt_dayte(.data$dayte))
  
  data <-
    data$event |>
    dplyr::mutate(
      groupsize_total = .data$fa + .data$f1 + .data$f0 + .data$ma +
        .data$m3 + .data$m2 + .data$m1 + .data$m0 + .data$ua +
        .data$u1 + .data$u0,
      calf = .data$f0 + .data$m0 + .data$u0,
      yearling = .data$f1 + .data$m1 + .data$u1,
      adult = .data$fa + .data$m2 + .data$m3 + .data$ma + .data$ua,
      datetime_start = dttr2::dtt_date_time_from_ints(
        year = .data$start_year,
        month = .data$start_month,
        day = .data$start_day,
        hour = .data$start_hour,
        minute = .data$start_minute
      ),
      year = dttr2::dtt_year(.data$datetime_start),
      annual = dttr2::dtt_study_year(
        .data$datetime_start,
        start = 4L,
        full = TRUE
      ),
      dayte = dttr2::dtt_dayte(.data$datetime_start),
      day = base::as.integer(dttr2::dtt_date(.data$datetime_start)),
      day = .data$day - base::min(.data$day),
      week = base::as.integer(.data$day %/% 7 + 1),
      weekfac = base::factor(.data$week),
      doy = dttr2::dtt_doy(.data$datetime_start) -
        dttr2::dtt_doy(dttr2::dtt_date("2019-04-01")),
      doy = dplyr::if_else(.data$doy < 0, .data$doy + 365, .data$doy),
      doy = base::as.integer(.data$doy),
      doy_fac = base::factor(.data$doy),
      month = dttr2::dtt_month(.data$datetime_start)
    ) |>
    dplyr::left_join(
      seasons_long,
      by = "dayte"
    ) |>
    dplyr::mutate(
      season = base::factor(
        .data$season,
        levels = c("Calving", "Summer/Fall", "Winter")
      )
    ) |>
    # Exclude calving season from analysis
    dplyr::filter(.data$season %in% c("Winter", "Summer/Fall")) |>
    dplyr::arrange(.data$datetime_start) |>
    dplyr::mutate(
      annual = base::factor(.data$annual),
      season = base::droplevels(.data$season),
      season_annual = stringr::str_c(
        base::as.character(.data$season),
        base::as.character(.data$annual),
        sep = " "
      ),
      season_annual = forcats::fct(.data$season_annual)
    ) |>
    dplyr::rename(location = "location_id") |>
    dplyr::arrange(.data$location, .data$weekfac) |>
    # Remove bachelor groups
    dplyr::filter(.data$groupsize_total > (.data$m2 + .data$m3 + .data$ma)) |>
    dplyr::mutate(
      location = base::factor(.data$location),
      location_weekfac = base::paste(.data$location, .data$week),
      location_weekfac = base::factor(.data$location_weekfac),
      id = base::factor(seq_len(dplyr::n()))
    ) |>
    dplyr::select(
      "f0", "f1", "m2", "m3", "ma", "fa", "m0", "m1", "u0", "u1", "ua",
      "calf", "yearling", "adult", "groupsize_total",
      "annual", "week", "weekfac", "season", "doy", "doy_fac",
      "location", "location_weekfac", "season_annual", "id"
    )
  
  chk::chk_not_any_na(data)
  
  data_list <- base::list(
    data = data,
    census_data = census_data,
    prop_calf_data = prop_calf_data
  )
  
  data_list
}

bisonpictools_modify_data <- function(
    data, levels_annual, census, census_cv, census_study_year, 
    census_day_of_year, proportion_calf, proportion_calf_cv, 
    proportion_calf_study_year, proportion_calf_day_of_year
  ) {
  
  chk::chk_list(data)
  df <- base::is.data.frame(data)
  if (df) {
    stop("Data must be in a list format as passed through embr::analyse()")
  }
  chk::chk_true(length(census) == length(census_cv) & length(census) == 
                  length(census_study_year) & length(census) == length(census_day_of_year))
  chk::chk_true(length(proportion_calf) == length(proportion_calf_cv) & 
                  length(proportion_calf) == length(proportion_calf_study_year) & 
                  length(proportion_calf) == length(proportion_calf_day_of_year))
  chk::chk_integer(census)
  chk::chk_numeric(census_cv)
  chk::chk_gt(census_cv, 0)
  chk::chk_character(census_study_year)
  chk::chk_subset(census_study_year, levels_annual)
  chk::chk_integer(census_day_of_year)
  chk::chk_subset(census_day_of_year, 1:366)
  chk::chk_numeric(proportion_calf)
  chk::chk_range(proportion_calf, range = c(0, 1), inclusive = TRUE)
  chk::chk_numeric(proportion_calf_cv)
  chk::chk_gt(proportion_calf_cv, 0)
  chk::chk_character(proportion_calf_study_year)
  chk::chk_subset(proportion_calf_study_year, levels_annual)
  chk::chk_integer(proportion_calf_day_of_year)
  chk::chk_subset(proportion_calf_day_of_year, 1:366)
  ncensus <- base::length(census)
  nprop_calf <- base::length(proportion_calf)
  sCensus <- census_cv * census
  sPropCalf <- proportion_calf_cv * proportion_calf
  annual_census <- base::array(base::as.integer(base::factor(census_study_year, 
                                                             levels = levels_annual)), dim = ncensus)
  annual_prop_calf <- base::array(base::as.integer(base::factor(proportion_calf_study_year, 
                                                                levels = levels_annual)), dim = nprop_calf)
  census <- base::array(census, dim = ncensus)
  sCensus <- base::array(sCensus, dim = ncensus)
  doy_census <- base::array(census_day_of_year, dim = ncensus)
  proportion_calf <- base::array(proportion_calf, dim = nprop_calf)
  sPropCalf <- base::array(sPropCalf, dim = nprop_calf)
  doy_prop_calf <- base::array(proportion_calf_day_of_year, 
                               dim = nprop_calf)
  data$ncensus <- ncensus
  data$census <- census
  data$sCensus <- sCensus
  data$annual_census <- annual_census
  data$doy_census <- doy_census
  data$nprop_calf <- nprop_calf
  data$prop_calf <- proportion_calf
  data$sPropCalf <- sPropCalf
  data$annual_prop_calf <- annual_prop_calf
  data$doy_prop_calf <- doy_prop_calf
  
  data
}

get_variable_comp <- function(x) {
    case_when(
      str_detect(x, "bInitialAbundance") ~ "Initial Abundance",
      str_detect(x, "no-covariance") ~ "No Covariance",
      str_detect(x, "bPropVecInit") ~ "Initial Proportions",
      str_detect(x, "bSurvival") ~ "Cow Survival Rate",
      str_detect(x, "default") ~ "Default",
    )
}

get_scenario_comp <- function(x) {
  case_when(
    str_detect(x, "no-covariance") ~ "Default",
    str_detect(x, "bInitialAbundance-200") ~ "200 Individuals",
    str_detect(x, "bInitialAbundance-600") ~ "600 Individuals",
    str_detect(x, "bPropVecInit-default-more-certain") ~ "More Certain",
    str_detect(x, "bPropVecInit-prop-equal-certain") ~ "Equal Proportions",
    str_detect(x, "bPropVecInit-prop-equal-uncertain") ~ "Uncertain",
    str_detect(x, "bSurvival-fa80") ~ "80%",
    str_detect(x, "bSurvival-fa90") ~ "90%",
    str_detect(x, "default") ~ "Default",
  )
}

prop_difference <- function(x) {
  (x[2] - x[1]) / x[1]
}

binomial_se <- function(n, p) {
  sqrt((p * (1 - p)) / n)
}

calculate_cv <- function(x) {
  sd(x) / mean(x)
}

cv_mcmc <- function(analysis, new_data, term) {
  cv_mcmc <- mcmc_derive_data(object = analysis, new_data = new_data, term = term)
  cv_df <- cv_mcmc$data
  cv_mcmc <- cv_mcmc$mcmc
  cv_df %<>% select(where(~ n_distinct(.x, na.rm = TRUE) > 1))
  cv_summ <- array(aperm(cv_mcmc, c(2, 1, 3)), dim = c(prod(dim(cv_mcmc)[1:2]), dim(cv_mcmc)[3]))
  chk_equal(ncol(cv_summ), nrow(cv_df))
  cv_summ %>% 
    as_tibble(.name_repair =  ~ paste0("V", seq_along(.x))) %>% 
    pivot_longer(cols = everything()) %>% 
    mutate(.row = as.integer(str_extract(name, "\\d+"))) %>%
    left_join(
      cv_df %>% mutate(.row = row_number()),
      by = ".row"
    ) %>%
    select(-.row, -name) %>% 
    group_by(across(all_of(names(cv_df)))) %>% 
    summarize(cv = calculate_cv(value), .groups = "drop")
}

nfold_trans2 <- function() {
  trans <- function(x) prop2nfold(x)
  inv <- function(x) nfold2prop(x)
  trans_new("nfold", trans, inv, breaks = nfold_breaks(), domain = c(-1, Inf))
}
    
