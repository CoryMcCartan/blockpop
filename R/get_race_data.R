
#' Download 2010 Census variables at the block level
#'
#' Downloads population and voting-age population by race at the block level
#' for the 2010 decennial Census.
#'
#' @param state the two-letter abbreviation of the state to get data for.
#'
#' @returns A data frame with the population counts
#'
#' @examples
#' \donttest{
#' bl_download_2010_vars("WA")
#' }
#'
#' @export
bl_download_2010_vars = function(state) {
    census_vars = c(pop       = "P001001",
                    pop_hisp  = "P005010",
                    pop_white = "P005003",
                    pop_black = "P005004",
                    pop_aian  = "P005005",
                    pop_asian = "P005006",
                    pop_nhpi  = "P005007",
                    pop_other = "P005008",
                    pop_two   = "P005009",
                    vap       = "P010001",
                    vap_hisp  = "P011002",
                    vap_white = "P011005",
                    vap_black = "P011006",
                    vap_aian  = "P011007",
                    vap_asian = "P011008",
                    vap_nhpi  = "P011009",
                    vap_other = "P011010",
                    vap_two   = "P011011")

    state_fips = fips_codes$state_code[which(fips_codes$state == state)[1]]
    counties = fips_codes$county_code[fips_codes$state == state]

    do.call(rbind, lapply(counties, function(county_fips) {
        tidycensus::get_decennial("block", state=state_fips, county=county_fips,
                                  variables=census_vars, cache_table=TRUE,
                                  year=2010, output="wide")
    })) %>%
        rename(block=.data$GEOID) %>%
        select(-.data$NAME)
}


#' Download 2019 5-year ACS variables at the block group level
#'
#' Downloads population and voting-age population by race at the block group
#' level for the 2019 5-year American Communities Survey.
#'
#' @param state the two-letter abbreviation of the state to get data for.
#'
#' @returns A data frame with the population counts
#'
#' @examples
#' \donttest{
#' bl_download_acs_vars("WA")
#' }
#'
#' @export
bl_download_acs_vars = function(state) {
    census_vars = c(pop       = "B03002_001E",
                    pop_hisp  = "B03002_012E",
                    pop_white = "B03002_003E",
                    pop_black = "B03002_004E",
                    pop_aian  = "B03002_005E",
                    pop_asian = "B03002_006E",
                    pop_nhpi  = "B03002_007E",
                    pop_other = "B03002_008E",
                    pop_two   = "B03002_009E")

    d = tidycensus::get_acs("block group", state=state,
                            variables=census_vars, cache_table=TRUE,
                            year=2019, output="wide") %>%
        rename(bgroup=.data$GEOID) %>%
        select(-.data$NAME, -ends_with("M"))
}
