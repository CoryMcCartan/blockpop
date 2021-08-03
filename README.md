
<!-- README.md is generated from README.Rmd. Please edit that file -->

# **blockpop**: Estimate Census Block Populations for 2020 <a href='https://corymccartan.github.io/blockpop'><img src='man/figures/logo.png' align="right" height="320"  style="padding: 12px" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/CoryMcCartan/blockpop/workflows/R-CMD-check/badge.svg)](https://github.com/CoryMcCartan/blockpop/actions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

2020 Census data is delayed and will be affected by differential
privacy. This package uses FCC block-level population estimates from
2010–2019, which are based on new roads and map data, along with
decennial Census and ACS data, to estimate 2020 block populations, both
overall and by major race/ethnicity categories (using iterative
proportional fitting).

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
bl_download_fcc("data-raw/fcc.csv")
```

Then we can extract the data for the state we care about and construct
the 2020 block estimates.

``` r
library(dplyr)

fcc_d = bl_load_state("WA", "data-raw/fcc.csv")
block_d = bl_est_2020(fcc_d)

print(block_d)
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
summarize(block_d, across(starts_with("pop"), sum))
#> # A tibble: 1 x 2
#>   pop2010  pop2020
#>     <dbl>    <dbl>
#> 1 6724540 7715946.
```

To add populations by race and ethnicity, we need to download ACS and
2010 Census data.

``` r
acs_d = bl_download_acs_vars("WA")
census_d = bl_download_2010_vars("WA")
```

Then we call `bl_harmonize_vars()` to create block-level estimates that
still total to 2020 block populations and are close to ACS estimates at
the block group level.

``` r
bl_harmonize_vars(block_d, census_d, acs_d)
#> ℹ Joining tables.
#> ℹ Harmonizing counts.
#> # A tibble: 195,574 x 22
#>    state block      pop2010 pop2020 vap2010 vap2020 pop_aian pop_asian pop_black
#>    <fct> <chr>        <dbl>   <dbl>   <dbl>   <dbl>    <dbl>     <dbl>     <dbl>
#>  1 WA    530019501…       0       0       0       0        0         0         0
#>  2 WA    530019501…       0       0       0       0        0         0         0
#>  3 WA    530019501…       0       0       0       0        0         0         0
#>  4 WA    530019501…       0       0       0       0        0         0         0
#>  5 WA    530019501…       0       0       0       0        0         0         0
#>  6 WA    530019501…       0       0       0       0        0         0         0
#>  7 WA    530019501…       0       0       0       0        0         0         0
#>  8 WA    530019501…       0       0       0       0        0         0         0
#>  9 WA    530019501…       0       0       0       0        0         0         0
#> 10 WA    530019501…       0       0       0       0        0         0         0
#> # … with 195,564 more rows, and 13 more variables: pop_hisp <dbl>,
#> #   pop_nhpi <dbl>, pop_other <dbl>, pop_two <dbl>, pop_white <dbl>,
#> #   vap_aian <dbl>, vap_asian <dbl>, vap_black <dbl>, vap_hisp <dbl>,
#> #   vap_nhpi <dbl>, vap_other <dbl>, vap_two <dbl>, vap_white <dbl>
```
