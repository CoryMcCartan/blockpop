#' Estimate 2020 population from 2010-2019 populations
#'
#' `r lifecycle::badge("experimental")`
#' Uses the average growth rate over the specified window to impute the 2020
#' population. Final estimates are rescaled to match the Census April 1, 2020
#' apportioment populations at the state level.
#'
#' @param data the output of [load_state()]
#' @param forecast_start the year to use as the base year. E.g. if 2013, then
#'   the average growth rate from 2013--2019 will be used.
#'
#' @returns A modified data frame with just 2010, base year, and 2020 estimates.
#'
#' @examples
#' \donttest{
#' d = bl_download_state("WA")
#' bl_est_2020(d, 2010)
#' }
#'
#' @export
bl_est_2020 = function(data, forecast_start=2010) {
    pop_cols = c(str_c("pop", forecast_start), "pop2019")
    period = 2019 - forecast_start

    census_pop = states_pop2020$pop2020[states_pop2020$state == data$state[[1]]]

    data = data %>%
        select(.data$state, .data$block, .data$pop2010, all_of(pop_cols)) %>%
        mutate(log_rate = (log(.data$pop2019) - log(.data[[pop_cols[1]]])) / period,
               pop2020 = if_else(is.na(.data$log_rate) | is.infinite(.data$log_rate),
                                 .data$pop2019, .data$pop2019 * exp(.data$log_rate))) %>%
        select(-all_of(pop_cols[2]), -.data$log_rate)

    adj_factor = sum(data$pop2020) / census_pop
    data$pop2020 = data$pop2020 / adj_factor

    data
}
