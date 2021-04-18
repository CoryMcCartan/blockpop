#' Download and extract population estimates for a state
#'
#' `r lifecycle::badge("experimental")`
#' @param state the two-letter abbreviation of the state to get data for.
#' @param path the path to the FCC data. Defaults to the online ZIP file, but
#'   can point to a local zip file or an extracted CSV (from e.g. [download_fcc()]).
#'
#' @returns A data frame with the population estimates.
#'
#' @examples
#' \dontrun{
#' download_state("WA")
#' }
#'
#' @export
load_state = function(state, path="https://www.fcc.gov/file/19314/download") {
    if (str_detect(path, "(http(s?)|ftp)://")) {
        cli::cli_alert_info("Downloading data.")
        url = path
        path = withr::local_tempfile(fileext=".zip")
        download.file(url, path)
    }

    if (str_ends(path, fixed(".zip"))) {
        cli::cli_alert_info("Unzipping data.")
        zip_path = path
        unzip_dir = withr::local_tempdir()
        files = unzip(zip_path, list=TRUE)
        main_file = files$Name[which.max(files$Length)]
        unzip(zip_path, main_file, exdir=unzip_dir)
        path = file.path(unzip_dir, main_file)
    }

    file_spec = readr::cols(stateabbr = readr::col_factor(),
                            block_fips = readr::col_character(),
                            .default = readr::col_double())
    header = readr::read_csv(path, n_max=0, col_types=file_spec)

    cli::cli_alert_info("Extracting {state} data.")
    out_path = withr::local_tempfile(fileext=".csv")
    grep_args = c(str_glue("'^{state}'"), path)
    system2("grep", grep_args, stdout=out_path)
    vroom::vroom(out_path, col_names=names(header),
                     col_types=readr::spec(header)) %>%
        select(state=.data$stateabbr,
               block=.data$block_fips,
               starts_with("pop"))
}


