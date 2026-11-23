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

if (FALSE) {
  # Install R packages
  source("install-packages.R")
  # Install cmdstan
  source("install-cmdstan.R")
}

# Load data sets
source("data-camera.R")
source("data-aerial.R")
source("plot-aerial.R")
source("plot-camera-ratio.R")

# Setup sensitivity analysis values
source("set-sensitivity-values.R")

# Run models (takes ~10 days to run all)
source("manipulate-aerial.R")
source("analyse-aerial.R") 

source("manipulate-camera.R")
source("analyse-camera.R")

source("manipulate-camera-aerial.R")
source("analyse-camera-aerial.R")

source("analyse-no-covariance.R")

# Save convergence and coefficient tables for all analyses
source("save-glance-coef.R")

# Standard model results
source("standard-model-coef.R")
source("standard-model-results.R")

# Sensitivity analysis results
source("compare-methods-new.R")
source("compare-class-abundance-precision.R")
source("compare-survival-precision.R")
