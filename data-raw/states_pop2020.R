## code to prepare `DATASET` dataset goes here

state_abbrs = as_tibble(tidycensus::fips_codes) %>%
    select(state, state_name) %>%
    distinct()

states_pop2020 = readxl::read_xlsx("data-raw/nst-est2020.xlsx", skip=3) %>%
    suppressMessages() %>%
    select(state_name=1, pop2020=`2020`) %>%
    filter(str_starts(.data$state_name, fixed("."))) %>%
    mutate(state_name = str_sub(.data$state_name, 2)) %>%
    inner_join(state_abbrs, by="state_name") %>%
    select(-.data$state_name)

usethis::use_data(states_pop2020, internal=TRUE, overwrite=TRUE)
