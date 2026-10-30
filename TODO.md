# Case 1 (WTI Oil): TODO and Submission Tracker

Status key: `[x]` done · `[ ]` open · `[~]` done in the draft, but the group still needs to act on it

---

## 1. Open TODO items

- [ ] **Rewrite the report prose to make narration straightforward yet engaging.** Keep the inline `` `r ...` `` values so the numbers stay linked to the results.
- [ ] **Add group member names** to the `author:` field in `main.Rmd` (currently `[names]`).
- [ ] **Record the group video** (8–12 min). It should cover the key findings, the diagnostics and remedies, the final model (M4), the recommendation, and why the methods were chosen. Every member should speak.
- [ ] **Confirm the decision-maker framing** with the instructor. The draft assumes a Philippine fuel-buying firm or treasury.
- [ ] **Confirm the data substitutions** with the instructor. The draft uses COMEX gold futures (Yahoo `GC=F`) instead of World Gold Council data, and Yahoo `PHP=X` instead of BSP rates.
- [ ] **Decide what to do with `finarts-case- study- suggested-code.R`.** It is not used by the report, so delete it or move it to an `archive/` folder.
- [ ] **Commit the work to git** (nothing is committed yet).
- [ ] *(Optional)* Put pandoc on the PATH, or knit from RStudio. Outside RStudio, run `export RSTUDIO_PANDOC=/usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64` first.
- [ ] *(Optional)* Add more references for the theoretical baseline (currently Kilian 2009 and Akram 2009).

---

## 2. Final Submission Checklist (Section 13 of the brief)

- [x] **The financial question is clear and answerable using the selected regression methods.**
  - The general question is refined into two testable questions (Introduction in `main.Rmd`): which *global* conditions are associated with monthly WTI log returns, and whether *Philippine* conditions add anything once global conditions are controlled for.
  - The second question is answered directly by a joint F-test on the Philippine block (Section 4.4).

- [x] **Variables and data preparation are documented.**
  - Variable dictionary (Table 1): code, construction, source and expected sign for each variable.
  - Checks for data types, missing values and non-finite values (Table 2). Data-quality issues are discussed: the source substitutions and PSA manufacturing base effects of up to +534% YoY.
  - Each transformation is justified (Section 2.4): log returns, the first-differenced yield, VIX average, YoY rates, and month-end WTI to avoid the negative print of April 2020.

- [x] **The initial multiple regression is correctly estimated and interpreted.**
  - M1 is estimated by OLS with all 8 regressors from the brief (`2_initial_multiple_regression_model.Rmd`).
  - Reports coefficients, SEs, t-values, p-values, 95% CIs, R², adjusted R² and the overall F-test (Tables 4–5).
  - Each coefficient is interpreted ceteris paribus, and expected and estimated signs are compared (Table 6).

- [x] **Statistical inference and model fit are addressed.**
  - Two-sided t-tests, plus a one-sided test for the dollar (Section 4.1). CI plot (Figure 4).
  - Economic significance as one-standard-deviation effects, compared with statistical significance (Table 8).
  - Joint F-tests on the Philippine block, the global block and PH macro only (Table 9).
  - Model comparison with adjusted R², AIC, BIC, a nested F-test (M2 vs M1) and a non-nested check (M3 vs M2). M3 is rejected despite its higher R², because its advantage depends on one month (Section 5).

- [x] **Relevant regression diagnostics are conducted.**
  - Multicollinearity: correlation heatmap and VIFs, all below 2.5 (Section 6.1).
  - Heteroskedasticity: Breusch-Pagan and White tests. Autocorrelation: Durbin-Watson and Breusch-Godfrey(12).
  - Influential observations: Cook's distance, leverage, studentized residuals and the Bonferroni outlier test, which flag March and May 2020.
  - Residual plots (four-panel), Jarque-Bera test for normality and RESET test for functional form.

- [x] **Problems are addressed with justified remedies where needed.**
  - Pulse dummies for March and May 2020, justified as known, dated, exogenous oil-market shocks (Section 7.2). The report also explains why it does not delete those months or use a single COVID dummy.
  - Newey-West HAC standard errors (3 lags ≈ T^(1/4)) for the remaining heteroskedasticity and possible autocorrelation.
  - Before/after comparison (Tables 16–17): RESET, Jarque-Bera, BP and White all pass in M4. The report warns that the higher R² is partly mechanical.

- [x] **At least one appropriate advanced regression method is applied and justified.**
  - Robust MM-estimation (`MASS::rlm`, bisquare), justified by fat-tailed returns and the risk that the dummies were picked after seeing the data (`7_advanced_regression_component.Rmd`).
  - On its own, it gives March and May 2020 zero weight and reproduces M4's coefficients. Logistic regression, panel methods, regularisation and regime interactions are explicitly ruled out.

- [~] **Financial interpretation is explicit and not merely statistical.**
  - Effects are expressed in pp of oil return and in money terms (4 pp on a \$10M fuel bill), and the exposure is described as "imported" global risk.
  - The report argues that oil price rises and peso weakness compound each other for a Philippine importer (Section 9.2).
  - *The group still needs to rewrite this in its own words (see TODO).*

- [~] **The recommendation follows from the empirical evidence.**
  - Three recommendations, each tied to a finding: monitor global indicators, not domestic ones; hedge oil and USD/PHP together; protect against tail events with options and stress tests (Section 10).
  - *The group should confirm that the decision-maker assumption holds.*

- [x] **Tables and figures are generated through R.**
  - All 20 tables (`kableExtra`) and 8 figures (`ggplot2` and base R) are produced by code chunks. Every number in the prose comes from inline R.

- [x] **The R Markdown document knits successfully.**
  - The knitted file is `main.pdf`.

- [ ] **The group recording clearly discusses and defends the final regression output.**
  - Not started (see TODO).

- [x] **The submitted files are sufficient to reproduce the analysis.**
  - `main.Rmd` plus the section files `0_`–`8_`, `finarts-case-study-1.Rproj`, `data/raw_monthly.csv` (cached raw data) and `data/analysis_dataset.csv` (prepared data).
  - Deleting `data/raw_monthly.csv` re-downloads everything from FRED, PSA OpenSTAT and Yahoo.

---

## 3. Assessment Rubric: Self-Assessment

### Performance standards (Section 11 of the brief)

| Level | General standard |
| --- | --- |
| **Excellent** | Accurate, complete, well-justified and financially insightful analysis; strong methodological judgment; results are reproducible and professionally communicated. |
| **Good** | Sound analysis with only minor omissions or weaknesses; methods and interpretation are generally appropriate. |
| **Developing** | Basic analysis is present but important elements are incomplete, weakly justified or insufficiently interpreted. |
| **Poor** | Major analytical, methodological, interpretive or reproducibility problems; required components are missing or inappropriate. |

### Criterion-by-criterion assessment

The levels below assume the group rewrites the prose in its own words.

| # | Criterion | Weight | Level | Justification |
| --- | --- | --- | --- | --- |
| 1 | Financial Problem, Research Question & Model Specification | 10% | **Good** | The research question is precise, testable and tied to a decision context. Each variable has a stated theoretical link and expected sign. *Weaknesses:* the decision-maker is assumed rather than given, and the literature base is thin (two papers), so the specification relies more on argument than on citation. |
| 2 | Data Preparation & Descriptive Analysis | 10% | **Excellent** | Complete variable dictionary; checks of data types, missing values and non-finite values; descriptive statistics with skewness, kurtosis and AR(1); three figures that are interpreted; every transformation justified. Real data-quality problems are found and handled openly (PSA base effects, source substitutions, the negative WTI print) rather than hidden. |
| 3 | Multiple Regression Estimation & Interpretation | 15% | **Excellent** | Every required statistic is reported. Each coefficient is interpreted ceteris paribus in pp of oil return, magnitudes are checked (e.g. 1.85 pp per 10 bp), and an alternative reading of USD/PHP (oil moving the peso) is given. The report cautions against relying on classical SEs before the diagnostics are run. |
| 4 | Statistical Inference & Model Evaluation | 10% | **Excellent** | t-tests with stated hypotheses, CIs, one-SD effects contrasted with p-values, three joint F-tests, and model comparison by adjusted R², AIC, BIC, a nested F-test and a non-nested check. It explicitly shows why the highest-R² model (M3) is *not* chosen, which is what Section 4.4 of the brief asks for. |
| 5 | Regression Diagnostics | 15% | **Excellent** | All five areas are covered with suitable tests and plots, on both M1 and M2, and summarised in a severity table. Influence is traced to specific dated events, and the RESET failure is linked to the outliers instead of being treated as non-linearity. |
| 6 | Model Improvement / Corrective Methods | 10% | **Excellent** | The main problem is identified and the remedies are matched to it. The report explains why it uses dummies rather than deletion or one COVID dummy, why HAC errors, and why not WLS or a transformation. The before/after table shows every diagnostic passing, and the report warns that the higher R² is partly mechanical. The Philippine block is re-tested in the improved model. |
| 7 | Appropriate Advanced Regression Method | 10% | **Excellent** | A single advanced method, chosen because the data call for it (fat tails, a possibly snooped dummy choice), with other methods explicitly ruled out, as the "do not force every technique" principle requires. It also does real work: it independently validates the final model. The approximate nature of MM standard errors is noted. |
| 8 | Financial Interpretation & Recommendation | 10% | **Good** | Findings are put in financial terms (imported risk, oil and peso compounding, tail risk), limitations are honest, and each recommendation traces back to a result. *Weaknesses:* the recommendations are qualitative (no hedge ratio or cost estimate), and the decision context is assumed. Turning the coefficients into, say, an estimated peso fuel-cost sensitivity would raise this to Excellent. |
| 9 | Reproducibility, R Implementation & Professional Presentation | 5% | **Good** | The modular Rmd files knit to one PDF with no visible code. Shared helpers avoid repeated code, data is cached, and every number in the text comes from R. *Weaknesses:* knitting outside RStudio needs a pandoc path, re-downloading Yahoo data may revise past values slightly, the unused suggested-code file is still in the repo, and one filename has a typo (`andprepration`). |
| 10 | Group Recording: Results Discussion & Defense | 5% | **Poor (not started)** | No recording exists yet. Once done, the rest of the analysis gives the group a strong defence: the dummies are confirmed independently by the robust regression, and the rejection of M3 shows judgment beyond R². |

**Overall:** Most criteria (2–7, about 70% of the weight) are at **Excellent**, with criteria 1, 8 and 9 at **Good**. Finishing the open TODO items, especially the group-written prose, the recording, and a quantified recommendation for criterion 8, would bring the submission to Excellent overall.
