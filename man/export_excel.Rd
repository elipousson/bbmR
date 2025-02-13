% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/export_excel.R
\name{export_excel}
\alias{export_excel}
\title{Exports formatted Excel file}
\usage{
export_excel(
  df,
  tab_name,
  file_name,
  type = "new",
  col_width = "auto",
  tab_color = NULL,
  table_name = NULL,
  show_tab = TRUE,
  save = TRUE
)
}
\arguments{
\item{df}{A data frame, will be exported as an Excel table}

\item{tab_name}{A string, the name to give to the exported sheet}

\item{file_name}{A string, the name of the file to be created}

\item{type}{"new" or "existing", whether to export the sheet as a new stand-alone file (default), or as an addition to an existing file}

\item{col_width}{optional (defaults to 'auto'), either 'auto' for autosized columns or a vector of numbers which must be equal to the number of columns}

\item{tab_color}{optional (defaults to none), hex color or color from colors()}

\item{table_name}{optional (defaults to Table3, Table4, etc.), unique table name in workbook; useful for writing Excel formulas that reference sheets on different tabs}

\item{show_tab}{optional (defaults to TRUE), whether the sheet exported is shown or hidden}

\item{save}{optional (defaults to TRUE), whether to save the final Excel workbook; not saving the workbook allows for additional, more complex openxlsx changes,}
}
\value{
A new .xlsx file or a new sheet in an existing .xlsx file
}
\description{
Exports Excel sheets with table formatting, headers, auto-column width, etc. Currently does not auto-size columns with dates correctly.
}
\examples{

withr::with_tempdir({
  export_excel(iris, "Iris Data", "iris.xlsx", "new")

  # if using option to resize columns
  export_excel(iris, "Iris Data", "iris.xlsx", "new", rep(15, 5))
})

}
\seealso{
[export_excel_tabs()]
}
\author{
Jeremy Pesner, Lillian Nguyen
}
