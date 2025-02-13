#' Retrieves Workday values from the foundational data model file
#' Matches Workday fund = fund, spend category = OSO, cost center = program + activity, grant = detailed fund, ledger = payroll natural
#' @param fdm_xwalk_file Path to "Baltimore FDM Crosswalk.xlsx" Excel file
#' @param spend_cat_file Path to "SubObject_SpendCategory.xlsx" Excel file
#' @return list of dataframes
#'
#' @author Sara Brumfield


# x-ref files for Workday and BPFS ===============================
#' @importFrom readxl read_excel
workday_get_values <- function(fdm_xwalk_file = "G:/Analyst Folders/Sara Brumfield/_ref/Baltimore FDM Crosswalk.xlsx",
                               spend_cat_file = "G:/Fiscal Years/SubObject_SpendCategory.xlsx") {
  x_fund <- import(fdm_xwalk_file, which = "Fund") %>%
    select(`FUND ID`, `Fund Name`, `Fund`) %>%
    rename(`BPFS Fund` = `Fund`) %>%
    rename(`Workday Fund` = `FUND ID`) %>%
    mutate(
      `BPFS Fund` = as.numeric(`BPFS Fund`),
      `Workday Fund` = as.numeric(`Workday Fund`)
    )

  x_spend_cat <- import(spend_cat_file)

  x_cc <- import(fdm_xwalk_file, which = "Pgm-Activity") %>%
    select(`Pgm-Activity`, `CCA ID`, `CC Name`)

  x_grant <- import(fdm_xwalk_file, which = "ProjectGrant") %>%
    select(`Grant / Project`, `Financial Grant ID`, `Financial Grant Name`, `Financials Proj ID`, `Financials Proj Name`, `SpecialPurpose`, `Special Purpose Name`) %>%
    mutate(
      `Grant / Project` = as.character(`Grant / Project`),
      Grant = as.numeric(substr(`Grant / Project`, 1, 4))
    )

  x_ledger <- import(fdm_xwalk_file, which = "Natural") %>%
    select(`Natural`, `Ledger Acct ID`, `Account Name`, `SC ID`, `Spend Cat`)

  x_sp <- readxl::read_excel(basename(fdm_xwalk_file), sheet = "ProjectGrant") %>%
    select(`Grant / Project`, `SpecialPurpose`, `Special Purpose Name`) %>%
    mutate(`Grant / Project` = as.character(`Grant / Project`))

  # read in bpfs account xwalk
  acct_26 <- query_db(paste0("planningyear24"), "ACCT_MAP_26_15") %>%
    collect() %>%
    mutate(
      PROGRAM_ID = as.numeric(PROGRAM_ID),
      ACTIVITY_ID = as.numeric(ACTIVITY_ID),
      SUBACTIVITY_ID = as.numeric(SUBACTIVITY_ID),
      FUND_ID = as.numeric(FUND_ID),
      DETAILED_FUND_ID = as.numeric(DETAILED_FUND_ID),
      OBJECT_ID = as.numeric(OBJECT_ID),
      SUBOBJECT_ID = as.numeric(SUBOBJECT_ID),
      `Activity ID` = as.numeric(substr(DIGIT_ACCOUNT_26, start = 18, stop = 21)),
      Natural = as.numeric(substr(DIGIT_ACCOUNT_26, start = 25, stop = 30))
    )

  data <- list(
    fund = x_fund,
    spend_cat = x_spend_cat,
    cc = x_cc,
    grant = x_grant,
    sp = x_sp,
    ledger = x_ledger,
    acct_26 = acct_26
  )

  return(data)
}


#' Concatenates BPFS values to create a Workday-compatible Program-Activity field
#'
#' @param program_col Program ID column name
#' @param activity_col Activity ID column name
#' @param subactivity_col Sub-activity ID column name
#' @return concatentated string value
#'
#' @author Sara Brumfield

make_program_activity <- function(data = df,
                                  program_col = `Program ID`,
                                  activity_col = `Activity ID.y`,
                                  subactivity_col = SUBACTIVITY_ID) {
  var <- paste0(
    str_pad(df$program_col, width = 4, pad = 0, side = "right"),
    "-",
    str_pad(df$activity_col, width = 3, pad = 0, side = "right"),
    str_pad(df$subactivity_col, width = 2, pad = 0, side = "left")
  )

  return(var)
}

#' Extracts BPFS values from the 26-digit legacy account # to create a
#' Workday-compatible Program-Activity field
#'
#' @param col Legacy account ID column name
#' @return concatentated string value
#'
#' @author Sara Brumfield


extract_program_activity <- function(col = DIGIT_ACCOUNT_26) {
  var <- substr(col, 13, 23)
  return(var)
}
