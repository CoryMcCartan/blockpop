#' Harmonize 2010 Decennial Census, 2019 ACS, and 2020 Block Population Estimates
#'
#' Creates estimates for race/ethnicity variables for blocks in 2020, based on
#' the 2010 Census ([download_2010_vars()]) and 2019 ACS ([download_acs_vars()])
#' data.
#'
#' The racial breakdown of total and voting-age population are proportionally
#' adjusted within block groups to match the ACS block-group percentages. Then
#' these percentages are applied to the newly estimated block populations.
#' Finally, the block race populations are rescaled so that the block
#' populations match the 2020 estimates. This is essentially a 1-round IPF
#' procedure.
#'
#' @param block_d the output of [est_2020()]
#' @param census_d the output of [download_2010_vars()] or similar
#' @param acs_d the output of [download_acs_vars()] or similar
#'
#' @returns A data frame of 2020 block-level estimates for the variables in
#'   `census_d`.
#'
#' @export
harmonize_vars = function(block_d, census_d, acs_d) {
    census_d = rename_with(census_d, ~ str_c("cens_", .), .cols=-block)
    acs_d = rename_with(acs_d, ~ str_c("acs_", .), .cols=-bgroup)
    cli::cli_alert_info("Joining tables.")
    joined_d = inner_join(block_d, census_d, by="block") %>%
        mutate(bgroup = str_sub(block, 1, 12)) %>%
        left_join(acs_d, by="bgroup") %>%
        pivot_longer(c(starts_with("cens_pop_"), starts_with("cens_vap_"),
                       starts_with("acs_pop_"), starts_with("acs_vap_")),
                     names_to=c("source", "type", "race"),
                     names_sep="_",
                     values_to="count") %>%
        select(-cens_pop) %>%
        rename(vap2010=cens_vap, acs_total=acs_pop) %>%
        pivot_wider(names_from=c(source, type), names_sep="_",
                    values_from=count)

    cli::cli_alert_info("Harmonizing counts.")
    # statewide % of population of voting age
    tot_vap_frac = with(joined_d, sum(vap2010)/sum(pop2010))

    joined_d %>%
        lazy_dt() %>%
        # compute demographic margins at multiple levels
        mutate(tract = str_sub(block, 1, 11),
               county = str_sub(block, 1, 5)) %>%
        group_by(bgroup, race) %>%
        mutate(cens_bg_pop = sum(cens_pop),
               bg_pop10 = sum(pop2010),
               bg_vap10 = sum(vap2010)) %>%
        group_by(tract, race) %>%
        mutate(tr_acs_pop = sum(acs_pop),
               tr_acs_tot = sum(acs_total)) %>%
        group_by(county, race) %>%
        mutate(cty_acs_pop = sum(acs_pop),
               cty_acs_tot = sum(acs_total)) %>%
        ungroup() %>%
        # rescale for demographic margins
        mutate(acs_pct = coalesce(acs_pop/acs_total, tr_acs_pop/tr_acs_tot,
                                  cty_acs_pop/cty_acs_tot),
               cens_bg_pop_pct = coalesce(cens_bg_pop / bg_pop10, acs_pct),
               adj = pop2020/pop2010 * acs_pct/cens_bg_pop_pct,
               vap_frac = coalesce(bg_vap10/bg_pop10, tot_vap_frac),
               est_pop = if_else(cens_pop > 0 & cens_bg_pop_pct > 0,
                                 cens_pop * adj,
                                 acs_pct * pop2020),
               est_vap = if_else(cens_vap > 0 & cens_bg_pop_pct > 0,
                                 cens_vap * adj,
                                 acs_pct * vap_frac * pop2020)) %>%
        # rescale for block population margins
        group_by(block) %>%
        mutate(est_tot_pop = sum(est_pop)) %>%
        ungroup() %>%
        mutate(est_pop = est_pop * if_else(est_tot_pop>0, pop2020/est_tot_pop, 0),
               est_pop = if_else(est_tot_pop==0 & pop2020>0,
                                 pop2020*acs_pct, est_pop),
               est_vap = est_vap * if_else(est_tot_pop>0, pop2020/est_tot_pop, 0),
               est_vap = if_else(est_tot_pop==0 & pop2020>0,
                                 pop2020*vap_frac*acs_pct, est_vap)) %>%
        group_by(block) %>%
        # wrap-up
        mutate(vap2020 = sum(est_vap)) %>%
        select(state, block, pop2010, pop2020, vap2010, vap2020, race, pop=est_pop, vap=est_vap) %>%
        pivot_wider(names_from=race, values_from=c(pop, vap)) %>%
        as_tibble()

}
