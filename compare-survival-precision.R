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

survival_terms <- tibble(
  term = c(
    "eSurvF0AnnualIM", "eSurvF1Annual", "eSurvFAAnnual",
    "eSurvM0AnnualIM", "eSurvM1Annual", "eSurvBullAnnual"
  ),
  class_label = c("F0", "F1", "FA", "M0", "M1", "Bull")
)

scenarios <- tibble(
  sub = c("camera-aerial/default", "camera/default", "aerial/default"),
  scenario = c("Camera + Aerial", "Camera Only", "Aerial Only")
)

cv_survival <- vector("list", nrow(scenarios))

for (i in seq_len(nrow(scenarios))) {
  print(sbf_set_sub(scenarios$sub[i]))
  analysis <- sbf_load_object("analysis")
  data <- data_set(analysis)

  annual_data <- xnew_data(data, annual)

  class_cv_list <- vector("list", nrow(survival_terms))
  for (j in seq_len(nrow(survival_terms))) {
    class_cv_list[[j]] <-
      cv_mcmc(analysis, annual_data, term = survival_terms$term[j]) %>%
      select(annual, cv) %>%
      mutate(class_label = survival_terms$class_label[j])
  }

  cv_survival[[i]] <-
    bind_rows(class_cv_list) %>%
    mutate(scenario = scenarios$scenario[i])
}

cv_survival <- bind_rows(cv_survival) %>%
  mutate(
    class_label = factor(class_label, levels = survival_terms$class_label),
    scenario = factor(scenario, levels = scenarios$scenario)
  )

sbf_set_sub("compare")

gp <- ggplot(cv_survival) +
  facet_wrap(~class_label, nrow = 3) +
  geom_point(
    aes(x = annual, y = cv, colour = scenario),
    position = position_dodge(width = 0.5)
  ) +
  scale_colour_disc_poisson() +
  scale_y_continuous(labels = percent) +
  expand_limits(y = c(0, 1)) +
  guides(x = guide_axis(angle = 45)) +
  xlab("Study Year") +
  ylab("Coefficient of Variation") +
  labs(colour = "Data Source") +
  NULL

sbf_open_window(6, 5)
sbf_print(gp)

sbf_save_plot(
  x_name = "compare-survival-cv"
)
