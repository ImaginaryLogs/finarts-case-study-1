# =====================================================================
# Case 1 - WTI Oil: monthly log return regression (Jan 2018 - Dec 2025)
# =====================================================================
# INPUT: one CSV of MONTHLY RAW LEVELS named "wti_data.csv" with columns:
#   Date                         first day of month, e.g. 2018-01-01
#   WTI                          month-end WTI spot (FRED DCOILWTICO)
#   SP500                        month-end S&P 500 level
#   USD_Index                    month-end broad USD index (FRED DTWEXBGS)
#   VIX                          monthly AVERAGE of VIXCLS
#   Gold                         month-end gold price (World Gold Council)
#   US_10Y_Yield                 month-end DGS10 (in % points)
#   PH_CPI                       Philippine CPI YoY % change (PSA)
#   USD_PHP                      month-end USD/PHP (BSP)
#   PH_Manufacturing_Production  Philippine manufacturing production YoY % (PSA)
# Include Dec 2017 as a row so that Jan 2018 returns can be computed.
# =====================================================================

# ---- 0. Packages -----------------------------------------------------
pkgs <- c("tidyverse", "lubridate", "lmtest", "sandwich", "car",
          "tseries", "strucchange", "broom", "zoo")
new  <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(new)) install.packages(new)
invisible(lapply(pkgs, library, character.only = TRUE))

dir.create("output", showWarnings = FALSE)

# ---- 1. Load data ----------------------------------------------------
raw <- read_csv("wti_data.csv", show_col_types = FALSE) %>%
  mutate(Date = as.Date(Date)) %>%
  arrange(Date)

# OPTIONAL: pull the FRED series automatically instead of using a CSV.
# (PSA, BSP and WGC series still have to be added manually.)
# library(quantmod)
# getSymbols(c("DCOILWTICO","SP500","DTWEXBGS","VIXCLS","DGS10"), src = "FRED")
# me <- function(x) apply.monthly(na.omit(x), last)   # month-end
# av <- function(x) apply.monthly(na.omit(x), mean)   # monthly average

# ---- 2. Construct variables -----------------------------------------
lr <- function(x) 100 * c(NA, diff(log(x)))   # log return in percent
d  <- function(x) c(NA, diff(x))              # first difference

df <- raw %>%
  transmute(
    Date,
    WTI_ret    = lr(WTI),
    SP500_ret  = lr(SP500),
    USD_ret    = lr(USD_Index),
    VIX        = VIX,
    dVIX       = d(VIX),                     # change in VIX (fixes timing mismatch)
    Gold_ret   = lr(Gold),
    d10Y       = d(US_10Y_Yield),
    PH_CPI     = PH_CPI,                     # YoY, as specified
    dPH_CPI    = d(PH_CPI),                  # monthly change in YoY rate
    USDPHP_chg = lr(USD_PHP),
    PH_Mfg     = PH_Manufacturing_Production,
    dPH_Mfg    = d(PH_Manufacturing_Production)
  ) %>%
  filter(Date >= as.Date("2018-01-01"), Date <= as.Date("2025-12-31")) %>%
  mutate(
    covid   = as.integer(Date >= as.Date("2020-03-01") & Date <= as.Date("2020-05-01")),
    ukraine = as.integer(Date == as.Date("2022-03-01"))
  )

cat("\nObservations:", nrow(df), "  Missing values per column:\n")
print(colSums(is.na(df)))

write_csv(df, "output/analysis_dataset.csv")

# ---- 3. Data inspection ---------------------------------------------
vars <- c("WTI_ret","SP500_ret","USD_ret","VIX","dVIX","Gold_ret",
          "d10Y","PH_CPI","dPH_CPI","USDPHP_chg","PH_Mfg","dPH_Mfg")

cat("\n=== Summary statistics ===\n")
summ <- df %>%
  select(all_of(vars)) %>%
  pivot_longer(everything(), names_to = "variable") %>%
  group_by(variable) %>%
  summarise(n = sum(!is.na(value)), mean = mean(value, na.rm = TRUE),
            sd = sd(value, na.rm = TRUE), min = min(value, na.rm = TRUE),
            max = max(value, na.rm = TRUE), .groups = "drop")
print(summ, n = Inf)
write_csv(summ, "output/summary_stats.csv")

# Time-series plots
p_ts <- df %>%
  select(Date, all_of(vars)) %>%
  pivot_longer(-Date, names_to = "variable") %>%
  ggplot(aes(Date, value)) +
  geom_line(linewidth = 0.4) +
  facet_wrap(~variable, scales = "free_y", ncol = 3) +
  theme_minimal() + labs(title = "Monthly series, 2018-2025", y = NULL)
ggsave("output/timeseries_plots.png", p_ts, width = 11, height = 8, dpi = 150)

# Stationarity: ADF (H0: unit root) and KPSS (H0: stationary)
cat("\n=== Stationarity tests ===\n")
stat_tab <- map_dfr(vars, function(v) {
  x <- na.omit(df[[v]])
  tibble(variable = v,
         ADF_p  = suppressWarnings(adf.test(x)$p.value),
         KPSS_p = suppressWarnings(kpss.test(x)$p.value))
})
print(stat_tab, n = Inf)
write_csv(stat_tab, "output/stationarity_tests.csv")

# Correlation matrix
core <- c("WTI_ret","SP500_ret","USD_ret","dVIX","Gold_ret","d10Y",
          "dPH_CPI","USDPHP_chg","dPH_Mfg")
cat("\n=== Correlation matrix ===\n")
cor_mat <- round(cor(df[core], use = "pairwise.complete.obs"), 2)
print(cor_mat)
write.csv(cor_mat, "output/correlation_matrix.csv")

# ---- 4. Models -------------------------------------------------------
# Newey-West HAC covariance (3 lags ~ T^(1/4)); robust to hetero + autocorr
nw <- function(m) NeweyWest(m, lag = 3, prewhite = FALSE, adjust = TRUE)

mdl_df <- df %>% drop_na(all_of(core))

# M1: theory baseline (global financial conditions)
m1 <- lm(WTI_ret ~ SP500_ret + USD_ret + dVIX + Gold_ret + d10Y, data = mdl_df)

# M2: baseline + Philippine block
m2 <- lm(WTI_ret ~ SP500_ret + USD_ret + dVIX + Gold_ret + d10Y +
           dPH_CPI + USDPHP_chg + dPH_Mfg, data = mdl_df)

# M3: baseline + event dummies (COVID, Russia-Ukraine)
m3 <- lm(WTI_ret ~ SP500_ret + USD_ret + dVIX + Gold_ret + d10Y +
           covid + ukraine, data = mdl_df)

# M4: full model + dummies
m4 <- lm(WTI_ret ~ SP500_ret + USD_ret + dVIX + Gold_ret + d10Y +
           dPH_CPI + USDPHP_chg + dPH_Mfg + covid + ukraine, data = mdl_df)

# M5 (robustness): literal brief specification (levels of VIX, YoY CPI/Mfg)
m5 <- lm(WTI_ret ~ SP500_ret + USD_ret + VIX + Gold_ret + d10Y +
           PH_CPI + USDPHP_chg + PH_Mfg, data = df %>% drop_na())

models <- list(M1_baseline = m1, M2_baseline_PH = m2, M3_baseline_dummies = m3,
               M4_full_dummies = m4, M5_literal_brief = m5)

# ---- 5. Coefficient significance (HAC) ------------------------------
cat("\n=== Coefficients with Newey-West SEs ===\n")
coef_tab <- imap_dfr(models, function(m, nm) {
  ct <- coeftest(m, vcov. = nw(m))
  ci <- coefci(m, vcov. = nw(m))
  tibble(model = nm, term = rownames(ct),
         estimate = ct[, 1], std_error = ct[, 2],
         t_value = ct[, 3], p_value = ct[, 4],
         ci_low = ci[, 1], ci_high = ci[, 2])
})
print(coef_tab %>% mutate(across(where(is.numeric), ~ round(.x, 4))), n = Inf)
write_csv(coef_tab, "output/coefficients_HAC.csv")

# Fit statistics
fit_tab <- imap_dfr(models, function(m, nm) {
  tibble(model = nm, n = nobs(m), R2 = summary(m)$r.squared,
         adjR2 = summary(m)$adj.r.squared, AIC = AIC(m), BIC = BIC(m),
         F_p = pf(summary(m)$fstatistic[1], summary(m)$fstatistic[2],
                  summary(m)$fstatistic[3], lower.tail = FALSE))
})
cat("\n=== Fit comparison ===\n"); print(fit_tab)
write_csv(fit_tab, "output/model_fit.csv")

# Joint tests (HAC): do the Philippine variables matter as a block?
cat("\n=== Joint Wald F-test: Philippine block (M2 vs M1) ===\n")
print(waldtest(m1, m2, vcov = nw, test = "F"))
cat("\n=== Joint Wald F-test: Philippine block (M4 vs M3) ===\n")
print(waldtest(m3, m4, vcov = nw, test = "F"))
cat("\n=== Joint Wald F-test: event dummies (M4 vs M2) ===\n")
print(waldtest(m2, m4, vcov = nw, test = "F"))

# ---- 6. Economic significance ---------------------------------------
# Effect on WTI return (percentage points) of a +1 SD move in each regressor
econ_sig <- function(m, nm) {
  X  <- model.matrix(m)[, -1, drop = FALSE]
  b  <- coef(m)[-1]
  sdx <- apply(X, 2, sd)
  sdy <- sd(model.response(model.frame(m)))
  tibble(model = nm, term = names(b), beta = b, sd_x = sdx,
         effect_1SD_pp = b * sdx,                 # pp of WTI return per 1 SD
         std_beta = b * sdx / sdy,                # standardized beta
         pct_of_sd_y = 100 * b * sdx / sdy)
}
econ_tab <- bind_rows(econ_sig(m1, "M1"), econ_sig(m3, "M3"), econ_sig(m4, "M4"))
cat("\n=== Economic significance (1 SD effects) ===\n")
print(econ_tab %>% mutate(across(where(is.numeric), ~ round(.x, 3))), n = Inf)
write_csv(econ_tab, "output/economic_significance.csv")

# ---- 7. Diagnostics --------------------------------------------------
run_diag <- function(m, nm) {
  vifs <- if (length(coef(m)) > 2) car::vif(m) else NA
  tibble(
    model        = nm,
    max_VIF      = suppressWarnings(max(vifs)),
    BP_p         = bptest(m)$p.value,                       # heteroskedasticity
    White_p      = bptest(m, ~ fitted(m) + I(fitted(m)^2))$p.value,
    DW_stat      = unname(dwtest(m)$statistic),
    DW_p         = dwtest(m)$p.value,
    BG_p         = bgtest(m, order = 3)$p.value,            # autocorrelation
    JB_p         = jarque.bera.test(residuals(m))$p.value,  # normality
    RESET_p      = resettest(m, power = 2:3, type = "fitted")$p.value
  )
}
diag_tab <- bind_rows(imap(models, run_diag))
cat("\n=== Diagnostics (p < 0.05 flags a problem, except VIF > 5-10) ===\n")
print(diag_tab %>% mutate(across(where(is.numeric), ~ round(.x, 4))))
write_csv(diag_tab, "output/diagnostics.csv")

cat("\n=== VIFs, full model M4 ===\n"); print(round(car::vif(m4), 2))

# Influence: Cook's distance and leverage for the chosen model
final <- m3     # <-- change after reviewing results
cd  <- cooks.distance(final)
inf <- tibble(Date = mdl_df$Date, cooks_d = cd,
              leverage = hatvalues(final),
              std_resid = rstandard(final)) %>%
  arrange(desc(cooks_d))
cat("\n=== Top 8 influential months ===\n"); print(head(inf, 8))
write_csv(inf, "output/influence.csv")

# Diagnostic plots
png("output/diagnostic_plots.png", width = 1200, height = 1000, res = 130)
par(mfrow = c(2, 2)); plot(final); dev.off()

# Stability: CUSUM of OLS residuals + Chow-type sup-F test
png("output/cusum.png", width = 900, height = 600, res = 130)
plot(efp(formula(final), data = mdl_df, type = "OLS-CUSUM"),
     main = "OLS-CUSUM stability test")
dev.off()
cat("\n=== Structural break (sup-F) ===\n")
print(sup.FStat <- sctest(Fstats(formula(final), data = mdl_df)))

# Residual autocorrelation plot
png("output/residual_acf.png", width = 800, height = 500, res = 130)
acf(residuals(final), main = "Residual ACF")
dev.off()

# ---- 8. Specification refinement ------------------------------------
# Information-criterion search restricted to theory-motivated candidates.
# (Used as a CHECK, not as the final decision rule.)
cat("\n=== Backward selection by BIC from M4 (check only) ===\n")
step_bic <- step(m4, direction = "backward", k = log(nobs(m4)), trace = 0)
print(summary(step_bic))

# Out-of-sample check: expanding window, 1-step-ahead RMSE (contemporaneous X)
oos_rmse <- function(formula, data, start = 48) {
  errs <- map_dbl(start:(nrow(data) - 1), function(i) {
    fit <- lm(formula, data = data[1:i, ])
    pred <- predict(fit, newdata = data[i + 1, ])
    data$WTI_ret[i + 1] - pred
  })
  sqrt(mean(errs^2))
}
cat("\n=== Out-of-sample RMSE (expanding window) ===\n")
oos <- tibble(
  model = c("Mean only", "M1", "M2", "M3", "M4"),
  RMSE  = c(
    sqrt(mean(map_dbl(48:(nrow(mdl_df) - 1),
                      ~ mdl_df$WTI_ret[.x + 1] - mean(mdl_df$WTI_ret[1:.x]))^2)),
    oos_rmse(formula(m1), mdl_df), oos_rmse(formula(m2), mdl_df),
    oos_rmse(formula(m3), mdl_df), oos_rmse(formula(m4), mdl_df))
)
print(oos)
write_csv(oos, "output/oos_rmse.csv")

# ---- 9. Robustness: drop extreme months, sub-samples ----------------
m3_nocovid <- update(m3, . ~ . - covid, data = filter(mdl_df, covid == 0))
m3_pre22   <- update(m3, . ~ . - ukraine, data = filter(mdl_df, Date < "2022-01-01"))
m3_post22  <- update(m3, . ~ . - covid - ukraine, data = filter(mdl_df, Date >= "2022-01-01"))
cat("\n=== Robustness: excluding COVID months ===\n")
print(coeftest(m3_nocovid, vcov. = nw(m3_nocovid)))
cat("\n=== Robustness: 2018-2021 ===\n")
print(coeftest(m3_pre22, vcov. = nw(m3_pre22)))
cat("\n=== Robustness: 2022-2025 ===\n")
print(coeftest(m3_post22, vcov. = nw(m3_post22)))

# ---- 10. Final model summary ----------------------------------------
cat("\n=== FINAL MODEL (edit 'final' above after reviewing results) ===\n")
print(coeftest(final, vcov. = nw(final)))
cat("\nChoose the final specification using theory, diagnostics, stability,\n",
    "out-of-sample performance AND economic significance - not p-values alone.\n",
    "Interpret as association, not causation.\n", sep = "")
cat("\nAll tables and plots saved in ./output/\n")
