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

source("models-camera-aerial-no-covariance.R")

sbf_set_sub("camera-aerial")

sbf_load_datas()
levels_annual <- sbf_load_object("levels_annual")
location_distance <- sbf_load_object("location_distance")

print(sbf_set_sub("camera-aerial", "no-covariance"))

sens_curr <-
  sensitivity_values %>%
  filter(variable == "default")

analysis <- analyse(model, data = data, nthin = 1L, stan_engine = "cmdstan-mcmc")
sbf_save_object(analysis)

sbf_open_pdf("mcmc")
plot(analysis)
sbf_close_pdf()
