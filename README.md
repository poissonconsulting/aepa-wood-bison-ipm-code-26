# aepa-wood-bison-ipm-code-26

Analysis code for the paper "An integrated population model to estimate ungulate demographic rates from camera data: A case study with wood bison".

## Analyses

The integrated population model (IPM) estimates the abundance and demographic rates of the Ronald Lake wood bison herd from remote camera data and aerial survey data.
Spatial and temporal correlation between camera events is accounted for with a Gaussian process regression with a squared-exponential covariance structure.

Eleven models are fitted:

- Camera + aerial (the standard model; `camera-aerial/default`)
- Camera only (`camera/default`)
- Aerial only (`aerial/default`)
- Camera + aerial without the covariance structure (`camera-aerial/no-covariance`)
- Seven camera + aerial prior sensitivity scenarios for the initial abundance, the initial stage proportions, and adult female survival (`camera-aerial/<scenario>`), defined in `set-sensitivity-values.R`

All models are Bayesian and are fitted in Stan through the embr and smbr2 packages.

## Data

The data are archived separately on Zenodo ([doi:10.5281/zenodo.24407090](https://doi.org/10.5281/zenodo.24407090)).
Download the four CSV files from Zenodo and save them in a folder named `data` in this repository.

- `data/camera_event.csv`: the number of bison of each sex and age class in each camera event, with the camera location and start date and time
- `data/camera_location.csv`: the longitude and latitude of each camera
- `data/aerial_census.csv`: the aerial census estimates and their standard errors (2021 and 2024)
- `data/aerial_proportion_calf.csv`: the proportions of calves and the minimum counts from the late-winter aerial surveys (2021 to 2024)

## Requirements

- R (>= 4.4)
- A C++ toolchain for compiling Stan models (Xcode Command Line Tools on macOS or Rtools on Windows)
- CmdStan
- The R packages listed in `install-packages.R`

To install the R packages and CmdStan, run

```r
source("install-packages.R")
source("install-cmdstan.R")
```

## Running the analysis

Run `zzz-run-all.R` to run every script in order.
The models are fitted in paper mode (four chains run in parallel) and take about 10 days to fit in total.

| Script | Purpose |
|---|---|
| `data-*.R` | Read the camera and aerial survey data |
| `plot-*.R` | Plot the aerial survey data and the observed ratios from the camera data |
| `set-sensitivity-values.R` | Define the prior values for the standard model and the sensitivity scenarios |
| `manipulate-*.R` | Prepare the data for each model |
| `models-*.R` | Define the models and parameter descriptions (sourced by `analyse-*.R`) |
| `analyse-*.R` | Fit the models |
| `save-glance-coef.R` | Save the convergence and coefficient tables for all models |
| `standard-model-coef.R` | Save the standard model coefficient table |
| `standard-model-results.R` | Plot and tabulate the standard model estimates |
| `compare-methods-new.R` | Compare the estimates between the data sources, sensitivity scenarios, and covariance structures |
| `compare-*-precision.R` | Plot the coefficients of variation of the stage abundance and survival estimates by data source |

## Files

- `header.R`: loads packages and sets options
- `functions.R`: helper functions
- `new-expr.R`: R code for the derived parameters used by all models (sourced by `header.R`)
- `*.stan`: Stan model code

## Outputs

All outputs are saved to `output/` using subfoldr2, organised by model (`aerial/`, `camera/`, and `camera-aerial/`) and with the comparisons in `compare/`.

- `objects/`: fitted model objects
- `tables/`: convergence, coefficient, estimate, and comparison tables
- `plots/`: data, estimate, and comparison plots

## Licence

The code in this repository is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
See `LICENSE` and `NOTICE`.
