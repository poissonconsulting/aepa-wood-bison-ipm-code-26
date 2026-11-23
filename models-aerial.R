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

sbf_set_sub("aerial")

description <- c(
  "`alpha_vec[c]`" = "Concentration parameter of the prior on the initial proportion of the `c`^th^ class",
  "`annual[i]`" = "Study year of the `i`^th^ event",
  "`annual_census[t]`" = "Study year of the `t`^th^ population estimate",
  "`annual_prop_calf[p]`" = "Study year of the `p`^th^ proportion of calves",
  "`bEtaSummerFall`" = "Square root of the maximum covariance between two location-weeks in the summer/fall season",
  "`bEtaWin`" = "Square root of the maximum covariance between two location-weeks in the winter season",
  "`bFecundityReproductiveFA`" = "Log odds of fecundity of sexually mature cows",
  "`bInitialMortalityCalfAnnual[a]`" = "Log odds of initial calf mortality for calves born at the end of the `a`^th^ study year",
  "`bKmWeekSummerFall`" = "Conversion factor between weeks and kilometres in the summer/fall season",
  "`bKmWeekWin`" = "Conversion factor between weeks and kilometres in the winter season",
  "`bMAProportion[s]`" = "Proportion of adult males present with mixed groups in the `s`^th^ season",
  "`bPopulationAbundanceInit`" = "Herd abundance at the start of the initial study year",
  "`bPopulationAnnual[c, a]`" = "Abundance of the `c`^th^ class on Apr. 1 of the `a`^th^ study year",
  "`bPopulationF0Init`" = "Abundance of female calves at the start of the initial study year",
  "`bPopulationF1Init`" = "Abundance of female yearlings at the start of the initial study year",
  "`bPopulationFAInit`" = "Abundance of cows at the start of the initial study year",
  "`bPopulationM0Init`" = "Abundance of male calves at the start of the initial study year",
  "`bPopulationM1Init`" = "Abundance of male yearlings at the start of the initial study year",
  "`bPopulationM2Init`" = "Abundance of male two-year-olds at the start of the initial study year",
  "`bPopulationM3Init`" = "Abundance of male three-year-olds at the start of the initial study year",
  "`bPopulationMAInit`" = "Abundance of male adults at the start of the initial study year",
  "`bPopulationMar31[c, a]`" = "Abundance of the `c`^th^ class on Mar. 31 of the `a`^th^ study year",
  "`bPropReproductiveFA`" = "Proportion of cows that are sexually mature",
  "`bPropVecAnnual[a, c]`" = "Proportion of the herd in the `c`^th^ class on Apr. 1 of the `a`^th^ study year",
  "`bPropVecEvent[i, c]`" = "Proportion of the herd in the `c`^th^ class on the day of the `i`^th^ event",
  "`bPropVecInit[c]`" = "Proportion of the herd in the `c`^th^ class at the start of the initial study year",
  "`bPropVecMar31[a, c]`" = "Proportion of the herd in the `c`^th^ class on Mar. 31 of the `a`^th^ study year",
  "`bRhoSummerFall`" = "Rate of decline of covariance with spatiotemporal distance in the summer/fall season",
  "`bRhoWin`" = "Rate of decline of covariance with spatiotemporal distance in the winter season",
  "`bSigmaSummerFall`" = "Standard deviation of the additional variation for events in the same location-week in the summer/fall season",
  "`bSigmaWin`" = "Standard deviation of the additional variation for events in the same location-week in the winter season",
  "`bSpaceTimeAdult[l, s]`" = "Spatiotemporal effect on the proportion of individuals aged two and older in a group at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeCalf[l, s]`" = "Spatiotemporal effect on the proportion of calves in a group at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeF0M0[l, s]`" = "Spatiotemporal effect on the proportion of female calves out of all calves at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeF1M1[l, s]`" = "Spatiotemporal effect on the proportion of female yearlings out of all yearlings at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeFABull[l, s]`" = "Spatiotemporal effect on the proportion of cows out of all individuals aged two and older at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeM2M3[l, s]`" = "Spatiotemporal effect on the proportion of male two-year-olds out of male two- and three-year-olds at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeMAFA[l, s]`" = "Spatiotemporal effect on the proportion of adult males out of adult males and cows at the `l`^th^ location-week in the `s`^th^ season",
  "`bSpaceTimeYearling[l, s]`" = "Spatiotemporal effect on the proportion of yearlings in a group at the `l`^th^ location-week in the `s`^th^ season",
  "`bSurvBullAnnual[a]`" = "Log odds of annual survival of bulls (males aged two and older) in the `a`^th^ study year",
  "`bSurvF0Annual[a]`" = "Log odds of annual survival of female calves in the `a`^th^ study year",
  "`bSurvF1Annual[a]`" = "Log odds of annual survival of female yearlings in the `a`^th^ study year",
  "`bSurvFAAnnual[a]`" = "Log odds of annual survival of cows in the `a`^th^ study year",
  "`bSurvM0Annual[a]`" = "Log odds of annual survival of male calves in the `a`^th^ study year",
  "`bSurvM1Annual[a]`" = "Log odds of annual survival of male yearlings in the `a`^th^ study year",
  "`census[t]`" = "The `t`^th^ aerial survey-based population estimate",
  "`doy[i]`" = "Day of the study year of the `i`^th^ event (day 1 is Apr. 1)",
  "`doy_census[t]`" = "Day of the study year of the `t`^th^ population estimate",
  "`doy_prop_calf[p]`" = "Day of the study year of the `p`^th^ proportion of calves",
  "`eAgeMatrix`" = "Deterministic aging matrix",
  "`eBirthMatrixAnnual[a]`" = "Birth matrix at the end of the `a`^th^ study year",
  "`eCovMatSummerFall[l, m]`" = "Covariance between the `l`^th^ and `m`^th^ location-weeks in the summer/fall season",
  "`eCovMatWin[l, m]`" = "Covariance between the `l`^th^ and `m`^th^ location-weeks in the winter season",
  "`eDistanceMatSummerFall[l, m]`" = "Spatiotemporal distance between the `l`^th^ and `m`^th^ location-weeks in the summer/fall season",
  "`eDistanceMatWin[l, m]`" = "Spatiotemporal distance between the `l`^th^ and `m`^th^ location-weeks in the winter season",
  "`eFecundityFA`" = "Fecundity of sexually mature cows",
  "`eInitialMortalityAnnual[a]`" = "Initial calf mortality for calves born at the end of the `a`^th^ study year",
  "`eLCovMatSummerFall[l, m]`" = "Cholesky factor of the covariance matrix in the summer/fall season",
  "`eLCovMatWin[l, m]`" = "Cholesky factor of the covariance matrix in the winter season",
  "`ePopulationCensus[c, t]`" = "Abundance of the `c`^th^ class on the date of the `t`^th^ population estimate",
  "`ePopulationEvent[c, i]`" = "Abundance of the `c`^th^ class on the day of the `i`^th^ event",
  "`ePopulationPropCalf[c, p]`" = "Abundance of the `c`^th^ class on the date of the `p`^th^ calf proportion estimate",
  "`ePropAdult[i]`" = "Expected value of the proportion of individuals aged two and older in a group in the `i`^th^ event",
  "`ePropCalf[i]`" = "Expected value of the proportion of calves in a group in the `i`^th^ event",
  "`ePropF0M0[i]`" = "Expected value of the proportion of female calves out of all calves in the `i`^th^ event",
  "`ePropF1M1[i]`" = "Expected value of the proportion of female yearlings out of all yearlings in the `i`^th^ event",
  "`ePropFABull[i]`" = "Expected value of the proportion of cows out of all individuals aged two and older in the `i`^th^ event",
  "`ePropM2M3[i]`" = "Expected value of the proportion of male two-year-olds out of male two- and three-year-olds in the `i`^th^ event",
  "`ePropMAFA[i]`" = "Expected value of the proportion of adult males out of adult males and cows in the `i`^th^ event",
  "`ePropVecPropCalf[p, c]`" = "Proportion of the herd in the `c`^th^ class on the date of the `p`^th^ calf proportion estimate",
  "`ePropYearling[i]`" = "Expected value of the proportion of yearlings in a group in the `i`^th^ event",
  "`eSurvBullAnnual[a]`" = "Annual survival of bulls (males aged two and older) in the `a`^th^ study year",
  "`eSurvBullCensus[t]`" = "Survival of bulls (males aged two and older) from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvBullEvent[i]`" = "Survival of bulls (males aged two and older) from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvBullPropCalf[p]`" = "Survival of bulls (males aged two and older) from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvF0Annual[a]`" = "Annual survival of female calves in the `a`^th^ study year",
  "`eSurvF0Census[t]`" = "Survival of female calves from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvF0Event[i]`" = "Survival of female calves from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvF0PropCalf[p]`" = "Survival of female calves from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvF1Annual[a]`" = "Annual survival of female yearlings in the `a`^th^ study year",
  "`eSurvF1Census[t]`" = "Survival of female yearlings from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvF1Event[i]`" = "Survival of female yearlings from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvF1PropCalf[p]`" = "Survival of female yearlings from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvFAAnnual[a]`" = "Annual survival of cows in the `a`^th^ study year",
  "`eSurvFACensus[t]`" = "Survival of cows from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvFAEvent[i]`" = "Survival of cows from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvFAPropCalf[p]`" = "Survival of cows from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvM0Annual[a]`" = "Annual survival of male calves in the `a`^th^ study year",
  "`eSurvM0Census[t]`" = "Survival of male calves from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvM0Event[i]`" = "Survival of male calves from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvM0PropCalf[p]`" = "Survival of male calves from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvM1Annual[a]`" = "Annual survival of male yearlings in the `a`^th^ study year",
  "`eSurvM1Census[t]`" = "Survival of male yearlings from Apr. 1 to the date of the `t`^th^ census estimate",
  "`eSurvM1Event[i]`" = "Survival of male yearlings from Apr. 1 to the day of year of the `i`^th^ event",
  "`eSurvM1PropCalf[p]`" = "Survival of male yearlings from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eSurvivalMatrixAnnual[a]`" = "Annual survival matrix for the `a`^th^ study year",
  "`eSurvivalMatrixCensus[t]`" = "Survival matrix from Apr. 1 to the date of the `t`^th^ population estimate",
  "`eSurvivalMatrixEvent[i]`" = "Survival matrix from Apr. 1 to the day of the `i`^th^ event",
  "`eSurvivalMatrixPropCalf[p]`" = "Survival matrix from Apr. 1 to the date of the `p`^th^ calf proportion estimate",
  "`eZSummerFallAdult[l]`" = "Standardized spatiotemporal effect on the proportion of individuals aged two and older in a group at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallCalf[l]`" = "Standardized spatiotemporal effect on the proportion of calves in a group at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallF0M0[l]`" = "Standardized spatiotemporal effect on the proportion of female calves out of all calves at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallF1M1[l]`" = "Standardized spatiotemporal effect on the proportion of female yearlings out of all yearlings at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallFABull[l]`" = "Standardized spatiotemporal effect on the proportion of cows out of all individuals aged two and older at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallM2M3[l]`" = "Standardized spatiotemporal effect on the proportion of male two-year-olds out of male two- and three-year-olds at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallMAFA[l]`" = "Standardized spatiotemporal effect on the proportion of adult males out of adult males and cows at the `l`^th^ location-week in the summer/fall season",
  "`eZSummerFallYearling[l]`" = "Standardized spatiotemporal effect on the proportion of yearlings in a group at the `l`^th^ location-week in the summer/fall season",
  "`eZWinAdult[l]`" = "Standardized spatiotemporal effect on the proportion of individuals aged two and older in a group at the `l`^th^ location-week in the winter season",
  "`eZWinCalf[l]`" = "Standardized spatiotemporal effect on the proportion of calves in a group at the `l`^th^ location-week in the winter season",
  "`eZWinF0M0[l]`" = "Standardized spatiotemporal effect on the proportion of female calves out of all calves at the `l`^th^ location-week in the winter season",
  "`eZWinF1M1[l]`" = "Standardized spatiotemporal effect on the proportion of female yearlings out of all yearlings at the `l`^th^ location-week in the winter season",
  "`eZWinFABull[l]`" = "Standardized spatiotemporal effect on the proportion of cows out of all individuals aged two and older at the `l`^th^ location-week in the winter season",
  "`eZWinM2M3[l]`" = "Standardized spatiotemporal effect on the proportion of male two-year-olds out of male two- and three-year-olds at the `l`^th^ location-week in the winter season",
  "`eZWinMAFA[l]`" = "Standardized spatiotemporal effect on the proportion of adult males out of adult males and cows at the `l`^th^ location-week in the winter season",
  "`eZWinYearling[l]`" = "Standardized spatiotemporal effect on the proportion of yearlings in a group at the `l`^th^ location-week in the winter season",
  "`location[i]`" = "Camera location of the `i`^th^ event",
  "`location_distance`" = "Distance matrix between camera locations (km)",
  "`location_weekfac[i]`" = "Camera location-week of the `i`^th^ event",
  "`lookup_location[l]`" = "Camera location of the `l`^th^ location-week",
  "`lookup_week[l]`" = "Week of the `l`^th^ location-week",
  "`mean_abundance_init`" = "Mean of the prior on the initial herd abundance",
  "`mean_surv_FA`" = "Mean of the prior on the log odds of cow survival",
  "`minimum_count_census[t]`" = "Minimum count in the study year of the `t`^th^ population estimate",
  "`nObs`" = "Number of camera events",
  "`nannual`" = "Number of study years",
  "`ncensus`" = "Number of aerial survey-based population estimates",
  "`nclass`" = "Number of sex-age classes",
  "`nlocation_weekfac`" = "Number of camera location-weeks",
  "`nlocation`" = "Number of camera locations",
  "`nprop_calf`" = "Number of aerial survey-based calf proportion estimates",
  "`nseason_annual`" = "Number of season-study year combinations",
  "`nseason`" = "Number of seasons",
  "`prop_calf[p]`" = "The `p`^th^ aerial survey-based proportion of calves",
  "`sCensus[t]`" = "Standard deviation of the `t`^th^ population estimate",
  "`sPropCalf[p]`" = "Standard deviation of the `p`^th^ proportion of calves",
  "`season[i]`" = "Season of the `i`^th^ event",
  "`season_annual[i]`" = "Season-study year of the `i`^th^ event"
)

description <- tibble(
  Parameter = names(description),
  Description = description
)

description %<>% arrange(Parameter)

sbf_save_table(description)

model <- model(
  code = read_file("aerial.stan"),
  modify_data = function(data) {
    data$nclass <- 8L
    data$nannual_minus_1 <- data$nannual - 1
    data <- bisonpictools_modify_data(
      data = data,
      levels_annual = levels_annual,
      census = census_data$census,
      census_cv = census_data$census_cv,
      census_study_year = census_data$census_study_year,
      census_day_of_year = census_data$census_doy,
      proportion_calf = proportion_calf_data$prop_calf,
      proportion_calf_cv = proportion_calf_data$prop_calf_cv,
      proportion_calf_study_year = proportion_calf_data$prop_calf_study_year,
      proportion_calf_day_of_year = proportion_calf_data$prop_calf_doy
    )
    data$location_distance <- location_distance
    x <- as.data.frame(data[c("location_weekfac", "location", "week")]) |>
      dplyr::distinct() |>
      dplyr::arrange(.data$location_weekfac)
    data$week <- NULL
    data$lookup_location <- x$location
    data$lookup_week <- x$week
    
    data$mean_abundance_init <- sens_curr$mean_abundance_init
    data$alpha_vec <- unlist(sens_curr$alpha_vec)
    data$mean_surv_FA <- sens_curr$mean_surv_FA
    
    data$minimum_count_census <- minimum_count_data$minimum_count
    
    data
  },
  new_expr = new_expr_ipm,
  new_expr_vec = TRUE,
  select_data = list(
    doy = c(1L, 366L),
    annual = factor(),
    season = factor(),
    season_annual = factor(),
    week = c(0L, 500L),
    location = factor(),
    weekfac = factor(),
    location_weekfac = factor(),
    id = factor()
  ),
  derived = c(
    "bPropVecMar31",
    "bPopulationAnnual",
    "bPopulationMar31",
    "bPropVecEvent",
    "bSpaceTimeF0M0",
    "bSpaceTimeF1M1",
    "bSpaceTimeFABull",
    "bSpaceTimeM2M3",
    "bSpaceTimeMAFA",
    "bSpaceTimeCalf",
    "bSpaceTimeYearling",
    "bSpaceTimeAdult"
  ),
  random_effects = list(
    eZSummerFallF0M0 = c("location", "weekfac"),
    eZSummerFallF1M1 = c("location", "weekfac"),
    eZSummerFallFABull = c("location", "weekfac"),
    eZSummerFallM2M3 = c("location", "weekfac"),
    eZSummerFallMAFA = c("location", "weekfac"),
    eZSummerFallCalf = c("location", "weekfac"),
    eZSummerFallYearling = c("location", "weekfac"),
    eZSummerFallAdult = c("location", "weekfac"),
    eZWinF0M0 = c("location", "weekfac"),
    eZWinF1M1 = c("location", "weekfac"),
    eZWinFABull = c("location", "weekfac"),
    eZWinM2M3 = c("location", "weekfac"),
    eZWinMAFA = c("location", "weekfac"),
    eZWinCalf = c("location", "weekfac"),
    eZWinYearling = c("location", "weekfac"),
    eZWinAdult = c("location", "weekfac")
  )
)

sbf_save_block(template(model), "template")
