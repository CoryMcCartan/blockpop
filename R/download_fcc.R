#' Download and extract all population estimates to a file
#'
#' `r lifecycle::badge("experimental")`
#'
#' @param path the path to extract the CSV (~1.3 gigabytes) to.
#' @param url the URL to the FCC data <https://www.fcc.gov/staff-block-estimates>
#'
#' @returns The path, invisibly.
#'
#' @examples \dontrun{
#' bl_download_fcc("data-raw/fcc.csv")
#' }
#'
#' @export
bl_download_fcc = function(path, url="https://www.fcc.gov/sites/default/files/Staff-Pop-Unit-Household-Estimates-2023.zip") {
    zip_path = withr::local_tempfile(fileext=".zip")
    download.file(url, zip_path, mode="wb")
    unzip_dir = withr::local_tempdir()
    files = unzip(zip_path, list=TRUE)
    unzip_path = unzip(zip_path, files$Name[which.max(files$Length)], exdir=unzip_dir)
    file.rename(unzip_path, path)
    invisible(path)
}
