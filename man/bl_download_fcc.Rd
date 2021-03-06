% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_fcc.R
\name{bl_download_fcc}
\alias{bl_download_fcc}
\title{Download and extract all population estimates to a file}
\usage{
bl_download_fcc(path, url = "https://www.fcc.gov/file/19314/download")
}
\arguments{
\item{path}{the path to extract the CSV (~1.3 gigabytes) to.}

\item{url}{the URL to the FCC data \url{https://www.fcc.gov/staff-block-estimates}}
}
\value{
The path, invisibly.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}
}
\examples{
\dontrun{
bl_download_fcc("data-raw/fcc.csv")
}

}
