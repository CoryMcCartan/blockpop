
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **blockpop**: Estimate Census Block Populations for 2020

<!-- badges: start -->

[![R-CMD-check](https://github.com/CoryMcCartan/blockpop/workflows/R-CMD-check/badge.svg)](https://github.com/CoryMcCartan/blockpop/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

2020 Census data is delayed and will be affected by differential
privacy. This package uses FCC block-level population estimates from
2010–2019, which are based on new roads and map data, to estimate 2020
block populations. In the future it may estimate other quantities of
interest as well.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("CoryMcCartan/blockpop")
```

## Usage

We start by downloading the FCC data locally (although you can skip this
step if you just want estimates for one state).

``` r
library(blockpop)
download_fcc("data-raw/fcc.csv")
```

Then we can extract the data for the state we care about and construct
the 2020 block estimates.

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

WA_blocks = load_state("WA", "data-raw/fcc.csv")
#> ℹ Extracting WA data.
WA_est = est_2020(WA_blocks)

print(WA_est)
#> # A tibble: 195,574 x 4
#>    state block           pop2010 pop2020
#>    <fct> <chr>             <dbl>   <dbl>
#>  1 WA    530019501001000       0       0
#>  2 WA    530019501001001       0       0
#>  3 WA    530019501001002       0       0
#>  4 WA    530019501001003       0       0
#>  5 WA    530019501001004       0       0
#>  6 WA    530019501001005       0       0
#>  7 WA    530019501001006       0       0
#>  8 WA    530019501001007       0       0
#>  9 WA    530019501001008       0       0
#> 10 WA    530019501001009       0       0
#> # … with 195,564 more rows
summarize(WA_est, across(starts_with("pop"), sum))
#> # A tibble: 1 x 2
#>   pop2010  pop2020
#>     <dbl>    <dbl>
#> 1 6724540 7693612.
```
