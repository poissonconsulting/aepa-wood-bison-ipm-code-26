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

subs <- sbf_subs_object_recursive("analysis")

for (sub in subs) {
  print(sbf_set_sub(sub))

  analysis <- sbf_load_object("analysis")

  glance <- glance(analysis) %>%
    mutate(duration_minutes = signif(as.numeric(analysis$duration, "minutes"), 3))
  coef <- coef(
    analysis,
    include_constant = FALSE, 
    sd = FALSE, 
    directional_information = FALSE
  ) %>%
    mutate(across(estimate:svalue, \(x) signif(x, 3)))

  glance %>% print()
  coef %>% print(n = nrow(.))

  sbf_save_table(glance)
  sbf_save_table(coef)
}
