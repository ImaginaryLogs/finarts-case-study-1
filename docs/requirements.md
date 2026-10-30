CASE STUDY DATES:
Date Begin - Jan 01, 2018
Date End - Dec 31, 2025

The solution should be modular so we can assess changes across each part and just knitted at the end. R code should not be seen in the knit unless absolutely essential to the report. I'm doubt how much can finarts-case-study-suggested-code.R is even viable... We ought deliver the simplest necessary code required to pass all requirements, though use common design patterns to remove redudant code.

Case 1 — WTI Oil

*Theme: *Commodity / Energy Market

*Dependent variable: *WTI monthly log return

*Research question: *Which financial and economic conditions are associated
with wti monthly log return? The group should refine this into a precise
empirical question before estimating the final model.

*Economic focus: *Oil-price movements and global/Philippine
financial-economic conditions.

*#*

*Candidate regressor*

*Dataset variable code*

*Expected transformation*

*Source route*

1

S&P 500 return

SP500

Monthly log return

FRED SP500 / Yahoo ^GSPC

2

USD index return

USD_Index

Monthly log return

FRED DTWEXBGS

3

VIX

VIX

Monthly average

FRED VIXCLS / CBOE

4

Gold return

Gold

Monthly log return

World Gold Council

5

U.S. 10Y Treasury-yield change

US_10Y_Yield

Month-end first difference

FRED DGS10

6

Philippine CPI inflation

PH_CPI

YoY % change

PSA OpenSTAT CPI

7

USD/PHP change

USD_PHP

Monthly log change

BSP monthly exchange-rate statistics

8

Philippine manufacturing-production growth

PH_Manufacturing_Production

YoY % growth

PSA MISSI



Student modeling expectation: begin with a literature/theory-justified
baseline, inspect the data, estimate the multiple regression, evaluate
coefficient significance and economic significance, diagnose model
problems, and refine the specification where warranted. The final model
should not be determined solely by statistical significance.

*Special note for WTI: *The FRED DCOILWTICO series is a daily spot-price
series from the U.S. EIA. Month-end observations are used to construct the
monthly log return.
