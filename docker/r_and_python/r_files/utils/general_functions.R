##### FUNCTIONS IN USE ####

#'1) This function tidies up a dataframe. It is designed to be used with datasets imported from Excel.
#'It replaces spaces and other odd characters in column nameswith underscores.
#'It ensures names are unique by adding suffixing _1,_2 etc to all duplicate column names.

make_names <- function( names, unique=FALSE, leading_ = '' ) { 
  
  if( ! substr( leading_, 1, 1 ) %in%  c( '', '.', letters, LETTERS ) )
    stop( "'leading_' must be a lower- or uppercase letter or '.'" )
  
  # USE make.names
  names <- sub( '^[^A-Za-z\\.]+', '.', names )# replace leading non-lead character with .
  names <- make.names( names, allow_ = TRUE ) # make.names, allow underscores
  names <- gsub( '\\.', '_', names )          # replace . -> _
  names <- gsub( "\\_+", "_", names )         # replace multiple leading _ with single _    
  
  if( unique ) names <- make.unique( names, sep="_")  # make.unique
  
  # REPLACE LEADING _ WITH leading_ 
  # leading <- grepl( '^_', names )
  # substr( names[ leading ], 1, 1 ) = leading_  
  names <- gsub( '^_', leading_, names)
  
  
  return(names)
  
}

# clean up some of the inconsistencies between the workforce file and our NOMIS prison names
clean_nomis_prison_names <- function(string) {
  string <- str_replace_all(string, c("( )?\\(.*\\)" = "", # remove anything within brackets
                                      "^(?i)the( )?" = "", # the verne/mount -> verne/mount
                                      "(?i)hmp|yoi" = "", # remove any HMP/YOI identifiers not in brackets
                                      "[:punct:]|&" = " ", #remove punctuation
                                      "(?i)feltham.*" = "feltham", # no need to distinguish between Feltham A and B
                                      "(?i)immigration removal centre" = "(irc)",
                                      ".*prescoed.*" = "usk", # replace anything containing prescoed w/ usk
                                      ".*spring( )?hill.*" = "grendon", # as above, but for spring hill (sometimes spelt springhill)
                                      "^peterborough$" = "peterborough male", # if just "Peterborough", assign to male
                                      "\\s{2,}" = " ", #where multiple spaces are present, change them to a single space... 
                                      "^\\s+|\\s+$" = "")) # remove leading and trailing whitespace 
  return(string)
}

# function to read in dates properly. 
# The assumption taken for the most part in this function is that your year will be displayed as yyyy. This is adequate for this work, but may need to be tweaked if additional datasets are added or requirements change.
coerce_dates <- function(dates_vector) {
  
  #simple function that takes a single date and allows R to read it as a date
  clean_date <- function(date) {
    # initially, remove any lagging/leading whitespace from our date
    date <- str_replace_all(date, "^\\s+|\\s+$", "")
    
    if(is.na(date)|is.na(readr::parse_number(as.character(date)))) { #if value is an NA, return it as such
      date <- lubridate::dmy("01-01-1900") #need to set to a strange date so that when we unlist (do.call), it doesn't convert our dates to numeric values
    } else if(is.character(date %>% type.convert(as.is = T))) { #if value is a character, then run a lubridate function to parse it as a date
      
      if(stringr::str_detect(date, "^202[0-9]{1}|20[1]{1}[3-9]{1}")) {
        if(stringr::str_detect(date, "[A-Z|a-z]+")) { # check if the string contains text (i.e. a month name)
          ifelse(stringr::str_detect(date, "[A-Z|a-z]+$"), date <- lubridate::ydm(date), date <- lubridate::ymd(date)) # parse date
        } else {
          # assume that dates will be in the format of ymd, unless the month is obviously a day
          month_day_string <- stringr::str_extract(date, "(?<=202[0-9]{1}|20[1]{1}[3-9]{1}).*")
          month_day_string <- stringr::str_replace_all(month_day_string, "[^[:digit:]]","") # pull out all digits
          # parse based on info
          ifelse(as.numeric(stringr::str_sub(month_day_string, start=1L, end = 2L))>12, date <- ydm(date), date <- ymd(date))
        }
        
      } else if(str_detect(date, "^[A-Z|a-z]{3}")) {
        date_digits <- stringr::str_replace_all(date, "[^[:digit:]]","") # pull out all digits
        # we can have combinations of either dd-yyyy, dd-yy, yy-dd or yyyy-dd (or single days)
        if(nchar(date_digits) %in% c(5, 6)) {
          # checking for the location of obvious year dates first
          long_year_location <- stringr::str_locate(date_digits, "20[0-3]{1}[0-9]{1}") # accepts dates after 2000 and prior to 2039
          ifelse(long_year_location[1] > 1, date <- lubridate::mdy(date), date <- lubridate::myd(date))
        } else if(nchar(date_digits) %in% c(3, 4)) { # limited amount we can do to sort this group. Just assume a date group of 20-25 is a year
          # checking for the location of obvious year dates first
          year_location <- str_locate(date_digits, "[2]{1}[0-5]{1}") # check for location of dates from 20-25
          ifelse(year_location[1] > 1, date <- lubridate::mdy(date), date <- lubridate::myd(date))
        }
      } else {
        # otherwise, check where year is and parse accordingly
        ## initially check the number of characters to determine whether we have a year date of 2 or 4 characters
        date_digits <- stringr::str_replace_all(date, "[^[:digit:]]","") # pull out all digits
        if(nchar(date_digits)>6) { 
          ifelse(stringr::str_detect(date, "20[0-3]{1}[0-9]{1}$"), date <- lubridate::dmy(date), date <- lubridate::dym(date)) 
        } else if(nchar(date_digits) < 6) { 
          ifelse(stringr::str_detect(date, "2[0-5]{1}$"), date <- lubridate::dmy(date), date <- lubridate::dym(date)) 
        } else if(nchar(date_digits) == 6) { # unique case. We can have 1/1/2020 or 01/01/20, which both contain six characters in total, so this needs a separate parsing methodology
          if(stringr::str_detect(date, "202[0-9]{1}|20[1]{1}[7-9]{1}")) { # i.e. 4 digit date somewhere in the string (potential for false positives here, of course) - looking for 2017-2029.
            ifelse(stringr::str_detect(date, "20[0-3]{1}[0-9]{1}$"), date <- lubridate::dmy(date), date <- lubridate::dym(date)) 
          } else {
            ifelse(stringr::str_detect(date, "2[0-9]{1}$"), date <- lubridate::dmy(date), date <- lubridate::dym(date)) 
          }
        }
      } 
      
    } else if(is.numeric(date %>% type.convert(as.is = T))){ #if numeric, use origin date to calculate correct date
      date <- as.Date(as.numeric(date), origin = "1899-12-30")
    }
    
    return(as.character(date))
  }
  
  #loop around our date_vector and 
  coerced_dates <- dates_vector %>% 
    purrr::map(clean_date) %>% 
    do.call('c', .) #unlists dates
  #where dates equal our proxy value, convert them to NA
  coerced_dates[coerced_dates==lubridate::dmy("01-01-1900")] <- NA
  coerced_dates <- as_date(coerced_dates) # ensure output is a date
  
  return(coerced_dates)
}


# this function assumes that there's a gap between your table and the footnotes (which is true in our case)
remove_footnotes <- function(df, cols_to_sum) {
  # calculate total number of values in each row (0 means the entire row is blank)
  df["blank"] <- rowSums(df[c(cols_to_sum)], na.rm = TRUE)
  
  # check that there are rows to remove before removing
  equal_0 <- df[["blank"]] == 0
  if(any(equal_0)) {
    # finally, filter all columns above our first blank row (which supercedes footnotes)
    df <- df[1:(min(which(equal_0), na.rm = TRUE)-1), ] 
  }
  # remove new "blank" column
  df <- df %>% dplyr::select(-blank)
  
  return(df)
}

#function that assigns a date value to a given month by rounding up to the last day of that month
assign_dates <- function(date, 
                         origin_date = start_date,
                         month_week = "week") {
  
  #add in a quick test to ensure that our entered vector/col is recognised as a date - otherwise give an error
  if(!is.Date(date)&!is.POSIXct((date))) {
    stop("Column/vector entered is of the wrong class type. Please convert it using as_date(.) and try again.")
  }
  #add in a quick test to ensure that our entered vector/col is recognised as a date - otherwise give an error
  if(!is.Date(origin_date)&!is.POSIXct((origin_date))|is.na(origin_date)) {
    stop("Origin date entered is of the wrong class type or invalid. Please convert it using as_date(.) or change the date in use and try again.")
  }
  
  
  #ceiling_date rounds a date to the next Sunday, and from there we can subtract 2 days
  #as Saturday is a special case, add 1 day to all values to ensure this works
  if(stringr::str_detect(month_week, "(?i)week")) {
    # use our date_key to decide how dates are rounded...
    output_date <- pmax(lubridate::ceiling_date(date, unit = "weeks", week_start = getOption("lubridate.week.start", wday(origin_date)-1), change_on_boundary = FALSE), origin_date)
  } else {
    output_date <- pmax(lubridate::ceiling_date(date, unit = "month") - days(1), origin_date)
  }
  
  
  return(output_date %>% as_date())
}

#simple function to clean prison names
#this is in a relatively lazy format for now - clean when/if time permits and a better format reveals itself
clean_prison_name <- function(string){
  string <- str_replace_all(string, regex(c(
    "[\\(]?(?<!wo)men[\\)]?" = "male", # convert men/women in brackets to male/female (primarily to help identify correct peterborough estab) -- also not preceded by "wo"
    "[\\(]?women[\\)]?" = "female", # men and women needs to be at the top as to not trigger the next cleaning step first
    "( )?\\(.*\\)" = "", # remove anything within brackets
    "[:punct:]" = " ", #remove punctuation
    " {1,}" = " ", #remove random spaces and replace with a single space
    "( the)|(the )" = "", # remove the from strings where it's clearly a unique word
    "( )?hm(p)?( )?" = "", #remove hm or hmp
    "( )?prison?( )?" = "", #remove "prison"
    "( )?yoi( )?" = "", #remove yoi
    "( )?ycs( )?" = "", #remove ycs
    "( )?stc( )?" = "", #remove stc
    "( )?irc( )?" = "", #remove irc
    "( )?sch|scc( )?" = "", #remove sch or scc
    "( )? sh|sh ( )?" = "", #remove sh (as long as it is preceded or suceeded by a space)
    "( )?immigration removal centre( )?" = "", #remove longform "irc"
    "( )?young persons unit( )?" = "", #remove "young persons unit"
    "( )?secure centre( )?" = "", #remove "secure centre"
    "^newhall$" = "new hall", #fix newhall (appearing without a space in certain datasets )
    "grendon( )*spring( )*hill" = "grendon", #obscure case, but if grendon & springhill appears in the data, convert to grendon
    "^spring( )?hill$" = "grendon", # can easily get this to work with the above line
    "&" = "and", # convert & to "and"
    "\\s+and" = "", # once normalised, remove "and"
    ".*usk.*|prescoed" = "usk",
    "highdown" = "high down",
    "^iow" = "isle of wight",
    "^adline" = "aldine", # correct spelling error
    ".*bronzefield.*" = "bronzefield",
    # anything rebinding on brackets needs to come after the above punctuation call
    "^morton hall$" = "morton hall (irc)", # add "(irc)" to morton hall
    "^oakhill$" = "oakhill (stc)", # where oakhill or rainsbrook, add "(stc)"
    "^rainsbrook$" = "rainsbrook (stc)", # apply the same logic to rainsbrook
    "^( )*" = "", #remove random spaces at the start
    "( )*$" = "", #remove random spaces at the end
    "\\s{2,}" = " "), ignore_case = TRUE) #where multiple spaces are present, change them to a single space... 
  )
  return(string)
}

# apply basic cleaning to a random column
clean_column <- function(string) {
  string <- stringr::str_replace_all(string, c("[:punct:]" = " ", #remove punctuation
                                               "^( )*" = "", #remove random spaces at the start 
                                               "( )*$" = "", #remove random spaces at the end
                                               " {1,}" = " ", #remove random spaces and replace with a single space
                                               "&" = "and", # convert & to "and"
                                               "\\s+and" = "", # once normalised, remove "and"
                                               "\\s{2,}" = " ")) #where multiple spaces are present, change them to a single space...
  return(string)
}

#identify the last date a specific day was (specifically so we can calc the previous Friday)
get_last_date <- function(day, origin_date = Sys.Date()) { #specified date should be the first three letters from your given date - first line is a contingency for when this isn't the case
  
  day <- strtrim(day, 3) %>% str_to_title() #trim the first three letters of the entered day
  dates <- seq((origin_date-7), (origin_date-1), by="days")
  final_date <- dates[lubridate::wday(dates, label=T)==day]
  
  #add an error if an invalid date is entered
  if(length(as.numeric(final_date)) == 0) {
    stop("Invalid date entered - please check that you have correctly entered a day of the week.")
  }
  
  return(final_date)
}

# function to read in and source our required data (this is currently on used within the structure_checks.R script)
xlsx_read_and_convert <- function(
  s3_prefix = NULL,
  s3_path = NULL,
  use_openxlsx = TRUE,
  sheet = 1,
  file_regex = NULL, # only use if you don't want to pull the latest file from your folder
  remove_footnotes = FALSE,
  ...
) 
{
  
  if(!is.null(s3_prefix)) { # if a value is set, find the most recent file using the prefix
    # import our prison outbreaks data
    # List the file and remove the bucket name and then create vector to hold them
    s3_files <- s3tools::list_files_in_buckets("alpha-hmpps-covid-data-processing", prefix = s3_prefix)
    s3_files <- s3_files[-which(s3_prefix == s3_files$filename),]
    if(!is.null(file_regex)) {
      s3_files <- s3_files[stringr::str_which(s3_files$filename, file_regex),]
    }
    # specify filepath and filename for our data
    s3_files_filename <- s3_files[which.max(as.Date(s3_files[, 5])),1]
    s3_path <- paste0("alpha-hmpps-covid-data-processing/", s3_prefix, "/", s3_files_filename)
  }
  
  # read in file
  # currently two methods are in use due to the way excel files read in for columns with merges
  # where a merge is present, the column name will be duplicated, which openxlsx refuses to read
  if(use_openxlsx) {
    df <- read_using(
      openxlsx::read.xlsx,
      s3_path = s3_path,
      sheet = sheet,
      ...) %>% 
      dplyr::as_tibble()
  } else {
    df <- read_using(
      readxl::read_xlsx,
      s3_path = s3_path,
      sheet = sheet,
      ...) %>% 
      dplyr::as_tibble()
  }
  
  
  # clean all columns with characters and 
  df <- df %>% 
    dplyr::mutate_if(is.character, clean_column) %>% 
    readr::type_convert()
  
  # convert colnames to lowercase
  colnames(df) <- stringr::str_to_lower(colnames(df))
  
  # pull the name of our latest file
  filename <-  stringr::str_extract(s3_path, "[^\\/]+$")
  
  # to keep things simple, assume the first column for all datasets will contain a full list of info
  # we can use this to find and remove footnotes for data that has an ambiguous number of rows (rows aren't constant)
  # find first NA row (footnotes are assumed to be under this)... if it doesn't exist, keep all rows
  # where no NA row exists, "Inf" will be returned. Use nrow df in these instances
  if(remove_footnotes) {
    df_rows_to_keep <- suppressWarnings(min(min(which(is.na(df[[colnames(df[2])]])))-1, nrow(df)))
    df <- df[1:df_rows_to_keep,] # keep only cols containing valid data
  }
  
  # clean all columns with characters and 
  df <- df %>% 
    dplyr::mutate_if(is.character, clean_column) %>% 
    readr::type_convert()
  
  ## do some final changes to the data to allow for easier checking against our excel file
  df <- df %>% 
    dplyr::mutate_if(is.POSIXct, lubridate::as_date)
  
  # produce a list containing our information we want checked
  final_list <- list(
    df = df,
    filename = filename,
    file_info = s3tools::list_files_in_buckets(stringr::str_extract(s3_path, "^[^\\/]+"), prefix = stringr::str_extract(s3_path, "(?<=\\/).*$")) # pull s3 file data
  )
  
  return(final_list)
}

# parse numeric col - i.e. only extract numeric value
parse_numeric_col <- function(df, column) {
  stringr::str_replace_all(df[[column]], "[:punct:]", "") %>% 
    stringr::str_extract(., '[0-9]*') %>% 
    as.numeric()
}
