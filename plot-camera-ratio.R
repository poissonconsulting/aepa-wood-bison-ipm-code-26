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

sbf_load_datas("camera")

# Calf-cow ratio
gp <- bisonpictools::bpt_plot_ratios(camera_event, camera_location, c("f0", "m0", "u0"), "fa")

sbf_open_window(11, 8)
sbf_print(gp)

# Bull-cow ratio
gp <- bisonpictools::bpt_plot_ratios(camera_event, camera_location, "ma", "fa")

sbf_open_window(11, 8)
sbf_print(gp)

# Yearling sex ratio
gp <- bisonpictools::bpt_plot_ratios(camera_event, camera_location, "f1", "m1")

sbf_open_window(11, 8)
sbf_print(gp)
