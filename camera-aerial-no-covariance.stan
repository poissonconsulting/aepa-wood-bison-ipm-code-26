// Copyright 2026 Province of Alberta
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data {
  int <lower=0> nObs;
  int <lower=0> nclass;
  int <lower=0> nannual;
  int <lower=0> nseason;
  int <lower=0> nseason_annual;
  
  array[nObs] int <lower=0> f0;
  array[nObs] int <lower=0> m0;
  array[nObs] int <lower=0> calf;
  array[nObs] int <lower=0> f1;
  array[nObs] int <lower=0> m1;
  array[nObs] int <lower=0> yearling;
  array[nObs] int <lower=0> m2;
  array[nObs] int <lower=0> m3;
  array[nObs] int <lower=0> ma;
  array[nObs] int <lower=0> fa;
  array[nObs] int <lower=0> adult;
  array[nObs] int <lower=0> groupsize_total;
  array[nObs] int <lower=0> annual;
  array[nObs] int <lower=0> season;
  array[nObs] int <lower=0> season_annual;
  array[nObs] int <lower=0, upper=366> doy;
  
  int <lower=0> ncensus;
  array[ncensus] real <lower=0> census;
  array[ncensus] real <lower=0> sCensus;
  array[ncensus] int <lower=1, upper=366> doy_census;
  array[ncensus] int <lower=0> annual_census;
  array[ncensus] real<lower=0> minimum_count_census;

  int <lower=0> nprop_calf;
  array[nprop_calf] real <lower=0, upper=1> prop_calf;
  array[nprop_calf] real <lower=0> sPropCalf;
  array[nprop_calf] int <lower=1, upper=366> doy_prop_calf;
  array[nprop_calf] int <lower=0> annual_prop_calf;
  
  int mean_abundance_init;
  vector[nclass] alpha_vec;
  real mean_surv_FA;
}

// Bull = M2, M3, MA
// FA = reproductive and non-reproductive cows 
// Adult = FA, M2, M3, MA, UA

parameters {
  array[nannual] real bSurvF0Annual;
  array[nannual] real bSurvF1Annual;
  array[nannual] real bSurvFAAnnual;
  array[nannual] real bSurvM0Annual;
  array[nannual] real bSurvM1Annual;
  array[nannual] real bSurvBullAnnual;
  real <lower=0> bPopulationAbundanceInit;
  real <lower=0> bPopulationF0Init; 
  real <lower=0> bPopulationF1Init; 
  real <lower=0> bPopulationFAInit; 
  real <lower=0> bPopulationM0Init; 
  real <lower=0> bPopulationM1Init; 
  real <lower=0> bPopulationM2Init; 
  real <lower=0> bPopulationM3Init; 
  real <lower=0> bPopulationMAInit; 
  simplex[nclass] bPropVecInit;
  real <lower=0, upper=1> bPropReproductiveFA; 
  real bFecundityReproductiveFA; 
  array[nannual] real bInitialMortalityCalfAnnual; 
  array[nseason] real <lower=0, upper=1> bMAProportion; 
}

transformed parameters {
  // Setup holding variables for derived parameters
  // Annual
  array[nannual] simplex[nclass] bPropVecAnnual;
  matrix <lower=0> [nclass, nannual] bPopulationAnnual; // Population abundances on Apr. 1

  array[nannual] matrix <lower=0, upper=1> [nclass, nclass] eSurvivalMatrixAnnual;
  array[nannual] matrix <lower=0, upper=1> [nclass, nclass] eBirthMatrixAnnual;
  matrix <lower=0, upper=1> [nclass, nclass] eAgeMatrix;

  array[nannual] real <lower=0, upper=1> eSurvF0Annual;
  array[nannual] real <lower=0, upper=1> eSurvF1Annual;
  array[nannual] real <lower=0, upper=1> eSurvFAAnnual;
  array[nannual] real <lower=0, upper=1> eSurvM0Annual;
  array[nannual] real <lower=0, upper=1> eSurvM1Annual;
  array[nannual] real <lower=0, upper=1> eSurvBullAnnual;
  
  real <lower=0, upper=1> eFecundityFA;
  array[nannual] real <lower=0, upper=1> eInitialMortalityAnnual;
  
  // Event
  array[nObs] simplex[nclass] bPropVecEvent;
  matrix <lower=0> [nclass, nObs] ePopulationEvent;

  array[nObs] real <lower=0, upper=1> eSurvF0Event;
  array[nObs] real <lower=0, upper=1> eSurvF1Event;
  array[nObs] real <lower=0, upper=1> eSurvFAEvent;
  array[nObs] real <lower=0, upper=1> eSurvM0Event;
  array[nObs] real <lower=0, upper=1> eSurvM1Event;
  array[nObs] real <lower=0, upper=1> eSurvBullEvent;

  array[nObs] matrix <lower=0, upper=1> [nclass, nclass] eSurvivalMatrixEvent;
  
  // Mar 31 - to derive ratios at the stable point at the end of the year.
  array[nannual] simplex[nclass] bPropVecMar31;
  matrix <lower=0> [nclass, nannual] bPopulationMar31; // Population abundances on Mar 31

  // Incorporate census data
  matrix <lower=0> [nclass, ncensus] ePopulationCensus;

  array[ncensus] real <lower=0, upper=1> eSurvF0Census;
  array[ncensus] real <lower=0, upper=1> eSurvF1Census;
  array[ncensus] real <lower=0, upper=1> eSurvFACensus;
  array[ncensus] real <lower=0, upper=1> eSurvM0Census;
  array[ncensus] real <lower=0, upper=1> eSurvM1Census;
  array[ncensus] real <lower=0, upper=1> eSurvBullCensus;

  array[ncensus] matrix <lower=0, upper=1> [nclass, nclass] eSurvivalMatrixCensus;

  // Incorporate data on proportion of calves
  array[nprop_calf] simplex[nclass] ePropVecPropCalf;
  matrix <lower=0> [nclass, nprop_calf] ePopulationPropCalf;

  array[nprop_calf] real <lower=0, upper=1> eSurvF0PropCalf;
  array[nprop_calf] real <lower=0, upper=1> eSurvF1PropCalf;
  array[nprop_calf] real <lower=0, upper=1> eSurvFAPropCalf;
  array[nprop_calf] real <lower=0, upper=1> eSurvM0PropCalf;
  array[nprop_calf] real <lower=0, upper=1> eSurvM1PropCalf;
  array[nprop_calf] real <lower=0, upper=1> eSurvBullPropCalf;

  array[nprop_calf] matrix <lower=0, upper=1> [nclass, nclass] eSurvivalMatrixPropCalf;
  
  // Calculate derived parameters
  bPopulationAnnual[, 1] = [bPopulationF0Init, bPopulationF1Init, bPopulationFAInit, bPopulationM0Init, bPopulationM1Init, bPopulationM2Init, bPopulationM3Init, bPopulationMAInit]';
  
  for (i in 1:nannual) {
    eSurvF0Annual[i] = inv_logit(bSurvF0Annual[i]);
    eSurvM0Annual[i] = inv_logit(bSurvM0Annual[i]);
    eSurvF1Annual[i] = inv_logit(bSurvF1Annual[i]);
    eSurvM1Annual[i] = inv_logit(bSurvM1Annual[i]);
    eSurvFAAnnual[i] = inv_logit(bSurvFAAnnual[i]);
    eSurvBullAnnual[i] = inv_logit(bSurvBullAnnual[i]);

    eSurvivalMatrixAnnual[i] = diag_matrix([eSurvF0Annual[i], eSurvF1Annual[i], eSurvFAAnnual[i], eSurvM0Annual[i], eSurvM1Annual[i], eSurvBullAnnual[i], eSurvBullAnnual[i], eSurvBullAnnual[i]]');
  }
  
  eFecundityFA = inv_logit(bFecundityReproductiveFA);
  
  for (i in 1:nannual) {
    eInitialMortalityAnnual[i] = inv_logit(bInitialMortalityCalfAnnual[i]);
    eBirthMatrixAnnual[i] = diag_matrix(rep_vector(1.0, nclass));
    eBirthMatrixAnnual[i, 1, 1] = 0.0;
    eBirthMatrixAnnual[i, 4, 4] = 0.0;
    eBirthMatrixAnnual[i, 1, 3] = eFecundityFA * 0.5 * bPropReproductiveFA * (1 - eInitialMortalityAnnual[i]);
    eBirthMatrixAnnual[i, 4, 3] = eFecundityFA * 0.5 * bPropReproductiveFA * (1 - eInitialMortalityAnnual[i]);
  }
  
  eAgeMatrix = diag_matrix(rep_vector(0.0, nclass));
  eAgeMatrix[2, 1] = 1.0;
  eAgeMatrix[3, 2] = 1.0;
  eAgeMatrix[3, 3] = 1.0;
  eAgeMatrix[5, 4] = 1.0;
  eAgeMatrix[6, 5] = 1.0;
  eAgeMatrix[7, 6] = 1.0;
  eAgeMatrix[8, 7] = 1.0;
  eAgeMatrix[8, 8] = 1.0;

  // Population model
  for (i in 2:nannual) {
    bPopulationAnnual[, i] = eBirthMatrixAnnual[i - 1] * eAgeMatrix * eSurvivalMatrixAnnual[i - 1] * bPopulationAnnual[, (i - 1)];
  }

  // Derive proportions in age classes
  for (i in 1:nannual) {
    for (j in 1:nclass) {
      bPropVecAnnual[i, j] = bPopulationAnnual[j, i] / sum(bPopulationAnnual[, i]);
    }
  }

  // Update survival for each event by day of year
  for (i in 1:nObs) {
    eSurvF0Event[i] = eSurvF0Annual[annual[i]]^(doy[i] / 365.25);
    eSurvF1Event[i] = eSurvF1Annual[annual[i]]^(doy[i] / 365.25);
    eSurvFAEvent[i] = eSurvFAAnnual[annual[i]]^(doy[i] / 365.25);
    eSurvM0Event[i] = eSurvM0Annual[annual[i]]^(doy[i] / 365.25);
    eSurvM1Event[i] = eSurvM1Annual[annual[i]]^(doy[i] / 365.25);
    eSurvBullEvent[i] = eSurvBullAnnual[annual[i]]^(doy[i] / 365.25);

    eSurvivalMatrixEvent[i] = diag_matrix([eSurvF0Event[i], eSurvF1Event[i], eSurvFAEvent[i], eSurvM0Event[i], eSurvM1Event[i], eSurvBullEvent[i], eSurvBullEvent[i], eSurvBullEvent[i]]');
  }

  // Update population for each event
  for (i in 1:nObs) {
    // Assumes exponential decay in population classes through year
    ePopulationEvent[, i] = eSurvivalMatrixEvent[i] * bPopulationAnnual[, annual[i]]; 
  }

   // Derive proportions in age classes for each event
  for (i in 1:nObs) {
    for (j in 1:nclass) {
      bPropVecEvent[i, j] = ePopulationEvent[j, i] / sum(ePopulationEvent[, i]);
    }
  }

  // Save proportions for March 31
  for (i in 1:nannual) {
    bPopulationMar31[, i] = eSurvivalMatrixAnnual[i] * bPopulationAnnual[, i];
    for (j in 1:nclass) {
      bPropVecMar31[i, j] = bPopulationMar31[j, i] / sum(bPopulationMar31[, i]);
    }
  }

  // Census
  for (i in 1:ncensus) {
    eSurvF0Census[i] = eSurvF0Annual[annual_census[i]]^(doy_census[i] / 365.25);
    eSurvF1Census[i] = eSurvF1Annual[annual_census[i]]^(doy_census[i] / 365.25);
    eSurvFACensus[i] = eSurvFAAnnual[annual_census[i]]^(doy_census[i] / 365.25);
    eSurvM0Census[i] = eSurvM0Annual[annual_census[i]]^(doy_census[i] / 365.25);
    eSurvM1Census[i] = eSurvM1Annual[annual_census[i]]^(doy_census[i] / 365.25);
    eSurvBullCensus[i] = eSurvBullAnnual[annual_census[i]]^(doy_census[i] / 365.25);

    eSurvivalMatrixCensus[i] = diag_matrix([eSurvF0Census[i], eSurvF1Census[i], eSurvFACensus[i], eSurvM0Census[i], eSurvM1Census[i], eSurvBullCensus[i], eSurvBullCensus[i], eSurvBullCensus[i]]');

    ePopulationCensus[, i] = eSurvivalMatrixCensus[i] * bPopulationAnnual[, annual_census[i]];
  }

  // Proportion of calves
  for (i in 1:nprop_calf) {
    eSurvF0PropCalf[i] = eSurvF0Annual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);
    eSurvF1PropCalf[i] = eSurvF1Annual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);
    eSurvFAPropCalf[i] = eSurvFAAnnual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);
    eSurvM0PropCalf[i] = eSurvM0Annual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);
    eSurvM1PropCalf[i] = eSurvM1Annual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);
    eSurvBullPropCalf[i] = eSurvBullAnnual[annual_prop_calf[i]]^(doy_prop_calf[i] / 365.25);

    eSurvivalMatrixPropCalf[i] = diag_matrix([eSurvF0PropCalf[i], eSurvF1PropCalf[i], eSurvFAPropCalf[i], eSurvM0PropCalf[i], eSurvM1PropCalf[i], eSurvBullPropCalf[i], eSurvBullPropCalf[i], eSurvBullPropCalf[i]]');

    ePopulationPropCalf[, i] = eSurvivalMatrixPropCalf[i] * bPopulationAnnual[, annual_prop_calf[i]];

    for (j in 1:nclass) {
      ePropVecPropCalf[i, j] = ePopulationPropCalf[j, i] / sum(ePopulationPropCalf[, i]);
    }
  }
}

model {
  array[nObs] real ePropCalf;
  array[nObs] real ePropYearling;
  array[nObs] real ePropAdult;
  array[nObs] real ePropF0M0;
  array[nObs] real ePropF1M1;
  array[nObs] real ePropFABull;
  array[nObs] real ePropM2M3;
  array[nObs] real ePropMAFA;

  bMAProportion[1] ~ normal(0.45, 0.1) T[0, 1];
  bMAProportion[2] ~ normal(0.1, 0.1) T[0, 1];

  // Values based on literature
  // SD terms chosen to give moderately informative priors
  bSurvF0Annual ~ normal(logit(0.44), 0.5);
  bSurvM0Annual ~ normal(logit(0.44), 0.5);
  bSurvF1Annual ~ normal(logit(0.85), 0.5);
  bSurvM1Annual ~ normal(logit(0.85), 0.5);
  bSurvFAAnnual ~ normal(mean_surv_FA, 0.5); 
  bSurvBullAnnual ~ normal(logit(0.90), 0.5);
  
  bInitialMortalityCalfAnnual ~ normal(0, 3);

  bFecundityReproductiveFA ~ normal(logit(0.71), 0.5);
  bPropReproductiveFA ~ normal(0.9, 0.2) T[0, 1];

  bPopulationAbundanceInit ~ normal(mean_abundance_init, 100) T[0, ];
  bPropVecInit ~ dirichlet(alpha_vec);
  
  bPopulationF0Init ~ normal(bPopulationAbundanceInit * bPropVecInit[1], 5) T[0, ];
  bPopulationF1Init ~ normal(bPopulationAbundanceInit * bPropVecInit[2], 5) T[0, ];
  bPopulationFAInit ~ normal(bPopulationAbundanceInit * bPropVecInit[3], 5) T[0, ];
  bPopulationM0Init ~ normal(bPopulationAbundanceInit * bPropVecInit[4], 5) T[0, ];
  bPopulationM1Init ~ normal(bPopulationAbundanceInit * bPropVecInit[5], 5) T[0, ];
  bPopulationM2Init ~ normal(bPopulationAbundanceInit * bPropVecInit[6], 5) T[0, ];
  bPopulationM3Init ~ normal(bPopulationAbundanceInit * bPropVecInit[7], 5) T[0, ];
  bPopulationMAInit ~ normal(bPopulationAbundanceInit * bPropVecInit[8], 5) T[0, ];
  
  for (i in 1:ncensus) { 
    census[i] ~ normal(sum(ePopulationCensus[, i]), sCensus[i]) T[minimum_count_census[i], ];
  }

  for (i in 1:nprop_calf) {
    prop_calf[i] ~ normal(ePropVecPropCalf[i, 1] + ePropVecPropCalf[i, 4], sPropCalf[i]) T[0, 1];
  }

  for (i in 1:nObs) {
    // Calves
    ePropCalf[i] = inv_logit(
      logit(bPropVecEvent[i, 1] + bPropVecEvent[i, 4])
    );
    calf[i] ~ binomial(groupsize_total[i], ePropCalf[i]);

    // Yearlings
    ePropYearling[i] = inv_logit(
      logit(bPropVecEvent[i, 2] + bPropVecEvent[i, 5]) 
    );
    yearling[i] ~ binomial(groupsize_total[i], ePropYearling[i]);
   
    // Adults
    ePropAdult[i] = inv_logit(
      logit(bPropVecEvent[i, 3] + bPropVecEvent[i, 6] + bPropVecEvent[i, 7] + (bPropVecEvent[i, 8] * bMAProportion[season[i]]))
    );
    adult[i] ~ binomial(groupsize_total[i], ePropAdult[i]);
    

    // Ratios of known sex
    // Proportion of female calves
    ePropF0M0[i] = inv_logit(
      logit(bPropVecEvent[i, 1] / (bPropVecEvent[i, 1] + bPropVecEvent[i, 4]))
    );
    f0[i] ~ binomial(f0[i] + m0[i], ePropF0M0[i]);
    
    // Proportion of male calves
    ePropF1M1[i] = inv_logit(
      logit(bPropVecEvent[i, 2] / (bPropVecEvent[i, 2] + bPropVecEvent[i, 5]))
    );
    f1[i] ~ binomial(f1[i] + m1[i], ePropF1M1[i]);

    // Proportion of females in "adults" (fa, m2, m3, ma)
    ePropFABull[i] = inv_logit(
        logit(bPropVecEvent[i, 3] /
        (bPropVecEvent[i, 3] + bPropVecEvent[i, 6] + bPropVecEvent[i, 7] + (bPropVecEvent[i, 8] * bMAProportion[season[i]])))
    );
    fa[i] ~ binomial(fa[i] + m2[i] + m3[i] + ma[i], ePropFABull[i]);

    // M2:M3 Ratio
    ePropM2M3[i] = inv_logit(
        logit(bPropVecEvent[i, 6] / (bPropVecEvent[i, 6] + bPropVecEvent[i, 7]))
    );
    m2[i] ~ binomial(m2[i] + m3[i], ePropM2M3[i]);

    // MA:FA ratio
    ePropMAFA[i] = inv_logit(
        logit((bPropVecEvent[i, 8] * bMAProportion[season[i]]) /
        (bPropVecEvent[i, 3] + (bPropVecEvent[i, 8] * bMAProportion[season[i]])))
    );
    ma[i] ~ binomial(fa[i] + ma[i], ePropMAFA[i]);
  }
}
