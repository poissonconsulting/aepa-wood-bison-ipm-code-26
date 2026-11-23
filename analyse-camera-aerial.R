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

source("models-camera-aerial.R")

sbf_set_sub("camera-aerial")

sbf_load_datas()
levels_annual <- sbf_load_object("levels_annual")
location_distance <- sbf_load_object("location_distance")

# Thinning and adapt_delta increased where needed for convergence
mcmc_settings <- tribble(
  ~variable,                           ~nthin, ~adapt_delta,
  "bInitialAbundance-200",                15L,         0.80,
  "bInitialAbundance-600",                20L,         0.80,
  "bPropVecInit-default-more-certain",    15L,         0.80,
  "bPropVecInit-prop-equal-certain",      15L,         0.80,
  "bPropVecInit-prop-equal-uncertain",    30L,         0.95,
  "bSurvival-fa80",                       15L,         0.80,
  "bSurvival-fa90",                       25L,         0.95,
  "default",                              15L,         0.80
)

for (var in sensitivity_values$variable) {
  print(sbf_set_sub("camera-aerial", var))
  
  sens_curr <- 
    sensitivity_values %>% 
    filter(variable == var)
  
  settings <-
    mcmc_settings %>%
    filter(variable == var)

  analysis <- analyse(
    model,
    data = data,
    nthin = settings$nthin,
    adapt_delta = settings$adapt_delta,
    stan_engine = "cmdstan-mcmc"
  )
  sbf_save_object(analysis)
  
  sbf_open_pdf("mcmc")
  plot(analysis)
  sbf_close_pdf()
}
