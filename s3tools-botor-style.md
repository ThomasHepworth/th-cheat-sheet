# Functions to replace soon to be deprecated s3tools functions

Old s3tool function replacements - these should act as 1:1 replacements for the old s3tools functions:
  - [read_using](#read_using)
  - [s3_path_to_full_df](#s3_path_to_full_df)
  - [list_files_in_buckets](#list_files_in_buckets)

<hr>

## Alternatives methods for reading, writing and viewing files/buckets available in botor

### read file examples
```
botor::s3_read('s3://alpha-hmpps-covid-data-processing/HMPPS-deaths.csv', read.csv)
botor::s3_read('s3://alpha-hmpps-covid-data-processing/HMPPS-deaths.csv', data.table::fread)
botor::s3_read('s3://botor/example-data/mtcars.json', jsonlite::fromJSON)
botor::s3_read('s3://botor/example-data/mtcars.jsonl', jsonlite::stream_in)
```

### write file examples
```
botor::s3_write(mtcars, write.csv, 's3://botor/example-data/mtcars.csv', row.names = FALSE) # edit s3 filepath

# for .xlsx, it's a little bit more longwinded:
t <- tempfile(fileext = '.xlsx')
# create blank df and save to temp folder
wb <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, sheetName = 'testing')
openxlsx::writeData(wb, sheet = 'testing', x = mtcars)
openxlsx::saveWorkbook(wb, file = t)
botor::s3_upload_file(file = t, uri = "s3://alpha-hmpps-covid-data-processing/testing.xlsx") # edit s3 filepath
```

### viewing files/buckets
```
# view files along filepath
boto3::s3_ls("alpha-hmpps-covid-data-processing")
boto3::s3_ls("alpha-hmpps-covid-data-processing/deaths")
# view all buckets owned by asd
boto3::s3_list_buckets(simplify = TRUE)
```

<hr>

## read_using
```
# updated read_using function
read_using <- function(FUN, s3_path, overwrite = TRUE, ...) {
  # trim s3:// if included by the user
  s3_path <- gsub(
    '^s3://',
    "",
    s3_path,
  )
  
  # find fileext
  file_ext <- paste0('.', tools::file_ext(s3_path))
  
  # download file to tempfile()
  tmp <- botor::s3_download_file(paste0('s3://', s3_path), tempfile(fileext = file_ext), force = overwrite)
  
  FUN(
    tmp,
    ...
  )
}
```

**Examples**
```
read_using(
  FUN = openxlsx::read.xlsx,
  s3_path = 's3://alpha-hmpps-covid-data-processing/covid19infectionsurveydatasets20210521.xlsx',
  startRow = 1,
  sheet = 2
)

read_using(FUN=readxl::read_excel, s3_path="alpha-test-team/mpg.xlsx")
```

<hr>

## s3_path_to_full_df
```
# if you are using a file with .gz, .bz or .xz extension, please using botor::s3_read directly
s3_path_to_full_df <- function(s3_path, ...) {
  # trim s3:// if included by the user
  s3_path <- gsub(
    '^s3://',
    "",
    s3_path,
  )
  
  # fileexts accepted by s3_read
  accepted_direct_fileext <- c('csv' = read.csv, 
                               'json' = jsonlite::fromJSON,
                               'jsonl' = jsonlite::stream_in,
                               'rds' = readRDS)
  # specify all other accepted filetypes
  excel_filepaths <- c('xlsx', 
                       'xls', 
                       'xlsm')
  
  accepted_fileext <- c(names(accepted_direct_fileext), excel_filepaths)
  
  fileext <- tools::file_ext(s3_path)
  
  # error if invalid filepath is entered
  if(!grepl(paste0('(?i)', accepted_fileext, collapse = "|"), fileext)) {
    stop(paste0("Invalid filetype entered. Please confirm that your file extension is one of the following: ", paste0(accepted_fileext, collapse = ', '), ". \n Alternatively, use botor directly to read in your file."))
  }
  
  # if we are using a function accepted by s3_read, then use that to parse the data
  if(grepl(paste0('(?i)', names(accepted_direct_fileext), collapse = "|"), fileext)) {
    # read from s3 using our designated method
    botor::s3_read(paste0('s3://',s3_path), fun = accepted_direct_fileext[[tolower(fileext)]])
  } else {
    read_using(
      FUN = readxl::read_excel,
      s3_path = s3_path,
      ...
    )
  }
  
}
```

**Examples**
```
s3_path_to_full_df('s3://alpha-hmpps-covid-data-processing/HMPPS-deaths.csv')
s3tools::s3_path_to_full_df("alpha-hmpps-covid-data-processing/covid19infectionsurveydatasets20210521.xlsx", sheet = 2)
s3_path_to_full_df("alpha-hmpps-covid-data-processing/capacity-reports/COVID-19CapacityImpact-20200427.xlsm", sheet = 1)
```

<hr>

## list_files_in_buckets
```
list_files_in_buckets <- function(bucket_filter = NULL, prefix = NULL) {
  
  if (is.null(bucket_filter)) {
    stop("You must provide one or more buckets e.g. accessible_files_df('alpha-everyone')  This function will list their contents")
  }
  if(!is.character(bucket_filter)) {
    stop("Supplied bucket_filter is not of class: character")
  }
  if(!is.character(prefix)&!is.null(prefix)) {
    stop("Supplied prefix is not of class: character")
  }
  
  # trim s3:// if included by the user - removed so we can supply both alpha-... and s3://alpha
  bucket_filter <- gsub(
    '^s3://',
    "",
    bucket_filter,
  )
  
  cols_to_keep <- c("key","last_modified","size","bucket_name")
  
  list <- botor::s3_ls(paste0('s3://', bucket_filter))
  list <- list[,cols_to_keep]
  list["full_path"] <- paste(list$bucket_name, list$key, sep = '/')
  
  if(nrow(list) == 0) {
    warning('Bucket contains 0 files')
    return(list)
  } else if(is.null(prefix)) {
    return(list)
  } else {
    return(list[grepl(prefix, list$key, ignore.case = TRUE),])
  }
}
```

**Examples**
```
list_files_in_buckets(bucket_filter = "alpha-hmpps-covid-data-processing", prefix = 'BASS.csv')
list_files_in_buckets(bucket_filter = "alpha-hmpps-covid-data-processing", prefix = 'deaths')
list_files_in_buckets(bucket_filter = "alpha-hmpps-covid-data-processing", prefix = 'fat') # prefix works using regex, so a shorter string will now work
list_files_in_buckets(bucket_filter = "alpha-hmpps-covid-data-processing/deaths", prefix = 'fatalities') # or just type in the full string you watch to match...
```

