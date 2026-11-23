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

library(bisonpictools)
library(chk)
library(doParallel)
library(dttr2)
library(mcmcr)
library(mcmcderive)
library(mcmcdata)
library(newdata)
library(extras)
library(smbr2)
library(embr)
library(subfoldr2)
library(poispalette)
library(poisplot)
library(scales)
library(magrittr)
library(ggplot2)
library(ggh4x)
library(tidyr)
library(readr)
library(purrr)
library(dplyr)
library(stringr)
library(forcats)
library(tidyplus)

dtt_set_default_tz("Etc/GMT+7")

theme_set(theme_Poisson())

options(sbf.ask = FALSE)

sbf_set_main("output")
sbf_reset_sub()

if (getDoParWorkers() == 1) {
  message("registering 4 workers")
  registerDoParallel(4)
}
set_analysis_mode("paper")
# ESS >= 500 from 4000 samples
options(mb.esr = 0.125)

rm(list = ls())
graphics.off()

source("functions.R")
source("new-expr.R")

options(mb.beep = FALSE)
