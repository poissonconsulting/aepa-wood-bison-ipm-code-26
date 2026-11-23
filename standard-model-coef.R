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

# Coefficient table for the standard model (Table S3 in the methods paper).
# Survival rates are on the probability scale and exclude the initial calf
# mortality, which is reported separately on the logit scale. Initial calf
# mortality in bInitialMortalityCalfAnnual[i] applies to calves born at the
# start of study year i + 1 (see new_expr_ipm in new-expr.R), so it is relabelled
# accordingly and the final element (calves born after the study) is dropped.

sbf_set_sub("camera-aerial", "default")
analysis <- sbf_load_object("analysis")
data <- data_set(analysis)

study_years <- levels(data$annual)
nyear <- length(study_years)

surv_terms <- c(
  bSurvF0Annual = "logit^-1(phi_F0,t)",
  bSurvM0Annual = "logit^-1(phi_M0,t)",
  bSurvF1Annual = "logit^-1(phi_F1,t)",
  bSurvM1Annual = "logit^-1(phi_M1,t)",
  bSurvFAAnnual = "logit^-1(phi_FA,t)",
  bSurvBullAnnual = "logit^-1(phi_Bull,t)"
)

surv_expr <- str_c(
  "e", names(surv_terms), " <- inv_logit(", names(surv_terms), ")",
  collapse = "\n"
)

surv <- mcmc_derive(analysis$mcmcr, surv_expr, silent = TRUE) %>%
  coef(sd = FALSE, directional_information = FALSE) %>%
  mutate(term = as.character(term), term = str_remove(term, "^e"))

coef <- coef(analysis, include_constant = FALSE, sd = FALSE, directional_information = FALSE) %>%
  mutate(term = as.character(term)) %>%
  filter(!str_detect(term, "^bSurv")) %>%
  bind_rows(surv) %>%
  mutate(
    par = str_remove(term, "\\[.*\\]$"),
    index = as.integer(str_extract(term, "(?<=\\[)\\d+(?=\\])"))
  )

stages <- c("F0", "F1", "FA", "M0", "M1", "M2", "M3", "MA")

labels <- tribble(
  ~par, ~parameter,
  "bPopulationAbundanceInit", "N_0",
  "bPropVecInit", "p_0",
  !!!flatten(map2(names(surv_terms), surv_terms, list)),
  "bInitialMortalityCalfAnnual", "m_t",
  "bFecundityReproductiveFA", "f",
  "bPropReproductiveFA", "p_f",
  "bMAProportion", "r",
  "bKmWeekSummerFall", "gamma_summer/fall",
  "bKmWeekWin", "gamma_winter",
  "bEtaSummerFall", "eta_summer/fall",
  "bEtaWin", "eta_winter",
  "bRhoSummerFall", "rho_summer/fall",
  "bRhoWin", "rho_winter",
  "bSigmaSummerFall", "sigma_summer/fall",
  "bSigmaWin", "sigma_winter"
) %>%
  mutate(order = row_number())

coef_s3 <- coef %>%
  inner_join(labels, join_by(par)) %>%
  filter(!(par == "bInitialMortalityCalfAnnual" & index == nyear)) %>%
  mutate(
    parameter = case_when(
      par == "bPropVecInit" ~ str_c(parameter, " ", stages[index]),
      par == "bMAProportion" ~ str_c(parameter, "_", c("summer/fall", "winter")[index]),
      .default = parameter
    ),
    study_year = case_when(
      par %in% c("bPopulationAbundanceInit", "bPropVecInit") ~ study_years[1],
      par == "bInitialMortalityCalfAnnual" ~ study_years[index + 1],
      par %in% names(surv_terms) ~ study_years[index],
      .default = "Constant"
    )
  ) %>%
  arrange(order, index) %>%
  select(parameter, study_year, estimate, lower, upper) %>%
  mutate(across(estimate:upper, \(x) signif(x, 3)))

coef_s3 %>% print(n = nrow(.))

sbf_save_excel(coef_s3, x_name = "coef-table-s3")
sbf_save_table(
  coef_s3,
  x_name = "coef-table-s3"
)
