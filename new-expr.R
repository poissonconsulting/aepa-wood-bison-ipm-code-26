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

new_expr_ipm <- "for (i in 1:nObs) {
      eSurvF0Annual[i] <- inv_logit(bSurvF0Annual[annual[i]])
      eSurvM0Annual[i] <- inv_logit(bSurvM0Annual[annual[i]])
      eSurvF1Annual[i] <- inv_logit(bSurvF1Annual[annual[i]])
      eSurvM1Annual[i] <- inv_logit(bSurvM1Annual[annual[i]])
      eSurvFAAnnual[i] <- inv_logit(bSurvFAAnnual[annual[i]])
      eSurvBullAnnual[i] <- inv_logit(bSurvBullAnnual[annual[i]])
      InitialMortalityCalfAnnual <- c(0, inv_logit(bInitialMortalityCalfAnnual))
      eInitialMortalityCalfAnnual[i] = InitialMortalityCalfAnnual[annual[i]]

      eSurvF0Doy[i] = eSurvF0Annual[i]^(doy[i] / 365.25);
      eSurvF1Doy[i] = eSurvF1Annual[i]^(doy[i] / 365.25);
      eSurvFADoy[i] = eSurvFAAnnual[i]^(doy[i] / 365.25);
      eSurvM0Doy[i] = eSurvM0Annual[i]^(doy[i] / 365.25);
      eSurvM1Doy[i] = eSurvM1Annual[i]^(doy[i] / 365.25);
      eSurvBullDoy[i] = eSurvBullAnnual[i]^(doy[i] / 365.25);

      eSurvF0AnnualIM[i] <- inv_logit(bSurvF0Annual[annual[i]]) * (1 - eInitialMortalityCalfAnnual[i])
      eSurvM0AnnualIM[i] <- inv_logit(bSurvM0Annual[annual[i]]) * (1 - eInitialMortalityCalfAnnual[i])

      eAbundanceF0RawDoy[i] <- bPopulationAnnual[1, annual[i]] / (1 - eInitialMortalityCalfAnnual[i])
      eAbundanceM0RawDoy[i] <- bPopulationAnnual[4, annual[i]] / (1 - eInitialMortalityCalfAnnual[i])

      eAbundanceF0Doy[i] <- eAbundanceF0RawDoy[i] * eSurvF0Doy[i] * if_else2(doy[i] > 90, (1 - eInitialMortalityCalfAnnual[i]), 1)
      eAbundanceF1Doy[i] <- bPopulationAnnual[2, annual[i]] * eSurvF1Doy[i]
      eAbundanceFADoy[i] <- bPopulationAnnual[3, annual[i]] * eSurvFADoy[i]
      eAbundanceM0Doy[i] <- eAbundanceM0RawDoy[i] * eSurvM0Doy[i] * if_else2(doy[i] > 90, (1 - eInitialMortalityCalfAnnual[i]), 1)
      eAbundanceM1Doy[i] <- bPopulationAnnual[5, annual[i]] * eSurvM1Doy[i]
      eAbundanceM2Doy[i] <- bPopulationAnnual[6, annual[i]] * eSurvBullDoy[i]
      eAbundanceM3Doy[i] <- bPopulationAnnual[7, annual[i]] * eSurvBullDoy[i]
      eAbundanceMADoy[i] <- bPopulationAnnual[8, annual[i]] * eSurvBullDoy[i]
      eAbundanceBullDoy[i] <- bPopulationAnnual[6, annual[i]] * eSurvBullDoy[i] +
        bPopulationAnnual[7, annual[i]] * eSurvBullDoy[i] +
        bPopulationAnnual[8, annual[i]] * eSurvBullDoy[i]

      eAbundanceDoy[i] <- eAbundanceF0Doy[i] + eAbundanceF1Doy[i] + eAbundanceFADoy[i] + eAbundanceM0Doy[i] + eAbundanceM1Doy[i] + eAbundanceM2Doy[i] + eAbundanceM3Doy[i] + eAbundanceMADoy[i]

      ePropCalfDoy[i] <- (eAbundanceF0Doy[i] + eAbundanceM0Doy[i]) / eAbundanceDoy[i]
      eCalfCowDoy[i] <- (eAbundanceF0Doy[i] + eAbundanceM0Doy[i]) / eAbundanceFADoy[i]

      eAbundanceF0[i] <- bPopulationAnnual[1, annual[i]]
      eAbundanceF1[i] <- bPopulationAnnual[2, annual[i]]
      eAbundanceFA[i] <- bPopulationAnnual[3, annual[i]]
      eAbundanceM0[i] <- bPopulationAnnual[4, annual[i]]
      eAbundanceM1[i] <- bPopulationAnnual[5, annual[i]]
      eAbundanceM2[i] <- bPopulationAnnual[6, annual[i]]
      eAbundanceM3[i] <- bPopulationAnnual[7, annual[i]]
      eAbundanceMA[i] <- bPopulationAnnual[8, annual[i]]

      eAbundance[i] <- eAbundanceF0[i] + eAbundanceF1[i] + eAbundanceFA[i] + eAbundanceM0[i] + eAbundanceM1[i] + eAbundanceM2[i] + eAbundanceM3[i] + eAbundanceMA[i]

      eAbundanceF0Mar31[i] <- bPopulationMar31[1, annual[i]]
      eAbundanceF1Mar31[i] <- bPopulationMar31[2, annual[i]]
      eAbundanceFAMar31[i] <- bPopulationMar31[3, annual[i]]
      eAbundanceM0Mar31[i] <- bPopulationMar31[4, annual[i]]
      eAbundanceM1Mar31[i] <- bPopulationMar31[5, annual[i]]
      eAbundanceM2Mar31[i] <- bPopulationMar31[6, annual[i]]
      eAbundanceM3Mar31[i] <- bPopulationMar31[7, annual[i]]
      eAbundanceMAMar31[i] <- bPopulationMar31[8, annual[i]]

      eAbundanceMar31[i] <- eAbundanceF0Mar31[i] + eAbundanceF1Mar31[i] + eAbundanceFAMar31[i] + eAbundanceM0Mar31[i] + eAbundanceM1Mar31[i] + eAbundanceM2Mar31[i] + eAbundanceM3Mar31[i] + eAbundanceMAMar31[i]

      m0_f0[i] <- bPropVecMar31[annual[i], 4] / bPropVecMar31[annual[i], 1]
      m1_f1[i] <- bPropVecMar31[annual[i], 5] / bPropVecMar31[annual[i], 2]
      calf_fa[i] <- (bPropVecMar31[annual[i], 1] + bPropVecMar31[annual[i], 4]) / bPropVecMar31[annual[i], 3]
      yearling_fa[i] <- (bPropVecMar31[annual[i], 2] + bPropVecMar31[annual[i], 5]) / bPropVecMar31[annual[i], 3]
      m2_fa[i] <- bPropVecMar31[annual[i], 6] / bPropVecMar31[annual[i], 3]
      m3_fa[i] <- bPropVecMar31[annual[i], 7] / bPropVecMar31[annual[i], 3]
      ma_fa[i] <- bPropVecMar31[annual[i], 8] / bPropVecMar31[annual[i], 3]

      prop_calf[i] <- bPropVecMar31[annual[i], 1] + bPropVecMar31[annual[i], 4]
      prop_calf_without_bh[i] <- (bPropVecMar31[annual[i], 1] + bPropVecMar31[annual[i], 4]) / (1 - bPropVecMar31[annual[i], 8] * (1 - bMAProportion[2]))

      eFecundity <- inv_logit(bFecundityReproductiveFA)
      ePropReproductiveFA[i] <- bPropReproductiveFA
      eMAProportion[i] <- bMAProportion[season[i]]

      AbundanceMar31 <- colSums(bPopulationMar31)
      InitialMortalityCalf <- InitialMortalityCalfAnnual[seq_along(bSurvF0Annual)]

      eMeanAbundanceMar31 <- mean(AbundanceMar31)
      eAbundanceChangeMar31 <- (AbundanceMar31[length(AbundanceMar31)] - AbundanceMar31[1]) / AbundanceMar31[1]
      eMeanCalfCowMar31 <- mean(apply(bPropVecMar31, 1, function(x) (x[1] + x[4]) / x[3]))
      eMeanSurvF0 <- mean(inv_logit(bSurvF0Annual) * (1 - InitialMortalityCalf))
      eMeanSurvM0 <- mean(inv_logit(bSurvM0Annual) * (1 - InitialMortalityCalf))
      eMeanSurvF1 <- mean(inv_logit(bSurvF1Annual))
      eMeanSurvM1 <- mean(inv_logit(bSurvM1Annual))
      eMeanSurvFA <- mean(inv_logit(bSurvFAAnnual))
      eMeanSurvBull <- mean(inv_logit(bSurvBullAnnual))
    }"
