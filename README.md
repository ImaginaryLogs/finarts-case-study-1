# FINARTS CASE STUDY 1

![R](https://img.shields.io/badge/R-4.6-276DC3?logo=r&logoColor=white)
![R Markdown](https://img.shields.io/badge/R%20Markdown-knit%20to%20PDF-75AADB?logo=rstudioide&logoColor=white)
![Course](https://img.shields.io/badge/FINARTS%20C01-Group%20Case%201-2E7D32)
![Sample](https://img.shields.io/badge/sample-Jan%202018%20%E2%80%93%20Dec%202025-informational)
![Observations](https://img.shields.io/badge/observations-96%20months-informational)
![Data](https://img.shields.io/badge/data-FRED%20%7C%20PSA%20%7C%20Yahoo-orange)
![Status](https://img.shields.io/badge/status-draft-yellow)

**What moves oil?** This case regresses monthly WTI crude oil log returns on global financial conditions (S&P 500, US dollar index, VIX, gold, US 10Y yield) and Philippine conditions (CPI inflation, USD/PHP, manufacturing growth).

**Key findings.**

- WTI returns move with **global** conditions: positively with equities and US yield changes, and negatively with the dollar.
- **Philippine variables add no explanatory power** (joint F-test p = 0.17).
- Two extreme months, March and May 2020, distorted the initial model. The final model (M4) adds an event dummy for each month and uses Newey-West HAC standard errors. A robust MM-regression reaches the same answer independently, giving those two months zero weight.
- **Recommendation:** Philippine oil users should hedge using global indicators, cover oil and USD/PHP together, and protect against tail events.

## Structure

| File | Purpose |
| --- | --- |
| `main.Rmd` | Report entry point: Executive Summary and Introduction; knits all sections into `main.pdf` |
| `0_data_collection_and_library.Rmd` | Libraries, data download and caching, shared helper functions |
| `1_` – `8_*.Rmd` | One file per required section (data, initial model, inference, comparison, diagnostics, improvement, advanced method, interpretation) |
| `data/raw_monthly.csv` | Cached raw monthly levels; delete it to re-download from the sources |
| `data/analysis_dataset.csv` | Transformed dataset used in the regressions |
| `TODO.md` | Open tasks, submission checklist and rubric self-assessment |

## Build

Open `finarts-case-study-1.Rproj` in RStudio and knit `main.Rmd`. Alternatively, from a shell:

```sh
export RSTUDIO_PANDOC=/usr/lib/rstudio/resources/app/bin/quarto/bin/tools/x86_64  # if pandoc is not on PATH
Rscript -e 'rmarkdown::render("main.Rmd")'
```
