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

if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak")
}

pak::pak(c(
  "chk",
  "cowplot",
  "doParallel",
  "dplyr",
  "forcats",
  "ggh4x",
  "ggplot2",
  "magrittr",
  "purrr",
  "readr",
  "rlang",
  "scales",
  "stringr",
  "tibble",
  "tidyr",
  "truncnorm",
  "stan-dev/cmdstanr", # See https://mc-stan.org/docs/cmdstan-guide/installation.html 
  "poissonconsulting/bisonpictools",
  "poissonconsulting/dttr2",
  "poissonconsulting/embr",
  "poissonconsulting/extras",
  "poissonconsulting/mcmcdata",
  "poissonconsulting/mcmcderive",
  "poissonconsulting/mcmcr",
  "poissonconsulting/newdata",
  "poissonconsulting/poispalette",
  "poissonconsulting/poisplot",
  "poissonconsulting/smbr2",
  "poissonconsulting/subfoldr2",
  "poissonconsulting/tidyplus"
))
