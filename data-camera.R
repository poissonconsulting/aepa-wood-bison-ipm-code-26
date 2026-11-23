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

dir <- "data"

files <- c("camera_event.csv", "camera_location.csv")
missing <- files[!file.exists(file.path(dir, files))]
if (length(missing)) {
  warning(
    "Data file(s) not found in ", dir, "/: ", str_c(missing, collapse = ", "), ". ",
    "Download the data from https://doi.org/10.5281/zenodo.24407090 and save the files in ", dir, "/."
  )
}

camera_event <- read_csv(file.path(dir, "camera_event.csv"))
camera_location <- read_csv(file.path(dir, "camera_location.csv"))

sbf_set_sub("camera")
sbf_save_datas()
