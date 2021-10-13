library(readxl)
library(readr)
library(lubridate)
library(stringr)
library(dplyr)

if(!any(str_detect(ls(), "clean_prison_name"))) {source("r_files/utils/general_functions.R")}

############################# Read in a set of lookups #########################
region_sort <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/cap_region_sort.csv",
  col_types = cols()
)

prison_regions <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/prison_lookup.csv",
  col_types = cols()
)

incident_regions <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/Incident_lookups.csv",
  col_types = cols()
)

covid_cols <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/Covid_return_lookup.csv",
  col_types = cols()
)

all_locs_cols <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/all_locs_lookup.csv",
  col_types = cols()
)

region_rename <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/lookups/hr_region_lookup_19.csv",
  col_types = cols()
)

last_updated <- read_using(
  readr::read_csv,
  s3_path = "alpha-hmpps-covid-data-processing/last_updated.csv",
  col_types = cols()
)

pub_priv_lookup <- read_using(
  readr::read_csv,
  s3_path = "alpha-covid-data-collection/lookups/region_lookup_19.csv",
  col_types = cols()
)

nomis_prison_lookup <- s3_path_to_full_df("alpha-hmpps-covid-data-processing/lookups/prison_mapping.csv")

# find the latest outbreak file to use


# List the file and remove the bucket name and then create vector to hold them
outbreak_files <- s3tools::list_files_in_buckets("alpha-hmpps-covid-data-processing", prefix = "outbreaks")$filename
outbreak_files <- outbreak_files[-which("outbreaks" == outbreak_files)]
# pull outbreak dates
available_dates <- ymd(stringr::str_extract(outbreak_files, '[0-9]{4}-[0-9]{2}-[0-9]{2}'))
# rm NA
available_dates <- available_dates[!is.na(available_dates)]
latest_file <- outbreak_files[which(max(available_dates)==available_dates)]

s3_path <- paste0('alpha-hmpps-covid-data-processing/outbreaks/', latest_file)

# read in info on prisons with outbreaks
prisons_outbreaks <- read_using(
  openxlsx::read.xlsx,
  s3_path = s3_path,
  startRow = 6,
  sheet = 1) %>% 
  dplyr::as_tibble()

# these are the designations for prisons under "current status" that designated a prison as an outbreak location
outbreak_definitions <- c("outbreak declared", 
                          "outbreak in recovery hmpps status 14 28 days since last case",
                          "outbreak in recovery oct status",
                          "outbreak in recovery oct status with case concerns")

# convert everything to lowercase
prisons_outbreaks <- prisons_outbreaks %>% 
  dplyr::mutate_all(str_to_lower)
# clean prison and columns we're using, then filter for only outbreak cases
prisons_outbreaks <- prisons_outbreaks %>% 
  dplyr::mutate(Establishment.name = clean_prison_name(Establishment.name),
                Current.status = clean_column(Current.status),
                Establishment.name = ifelse(Establishment.name == 'peterborough male female', 'peterborough male', Establishment.name)
  ) %>% 
  dplyr::filter(Current.status %in% outbreak_definitions)
# recently, the outbreak data has been changed to merge both Peterborough prisons. Add female back in as this is required in other areas
prisons_outbreaks <- dplyr::bind_rows(
  prisons_outbreaks,
  prisons_outbreaks %>% 
    dplyr::filter(Establishment.name == 'peterborough male') %>% 
    dplyr::mutate(Establishment.name = 'peterborough female')
) %>%
  dplyr::distinct(Establishment.name, .keep_all = TRUE)

# create an unfiltered version of our outbreak data (this contains YCS locations too)
prisons_outbreaks_unfiltered <- prisons_outbreaks %>%
  dplyr::filter(Establishment.type %in% c('prison', 'yoi', 'stc')) %>% 
  dplyr::select("prison"=Establishment.name, "outbreak_declaration_date"=Date.outbreak.declared.OPEN) %>% 
  dplyr::mutate(type = "outbreak ongoing")

# ensure that our outbreak column has no spelling errors...
prisons_outbreaks <- prisons_outbreaks %>% 
  dplyr::filter(Region %in% 1:19) %>% # remove YCS locations
  dplyr::select("prison"=Establishment.name, "outbreak_declaration_date"=Date.outbreak.declared.OPEN) %>% 
  dplyr::mutate(type = "outbreak ongoing")
if(nrow(prisons_outbreaks %>% dplyr::filter(is.na(outbreak_declaration_date)))>0){
  stop("Some of our outbreaks don't have outbreak dates. Please correct this before continuing.")
}
# coerce outbreak dates
prisons_outbreaks$outbreak_declaration_date <- coerce_dates(prisons_outbreaks$outbreak_declaration_date)
if(any(is.na(prisons_outbreaks$outbreak_declaration_date))) {
  missing_outbreak_dates <- prisons_outbreaks$prison[is.na(prisons_outbreaks$outbreak_declaration_date)]
  stop(paste0("Missing an outbreak date for the following outbreak sites: ", paste0(missing_outbreak_dates, collapse = ", \n"), ". 
              Please correct this in prison_outbreaks.xlsx on the platform"))
}
# write our output to s3 for easier testing later
write_df_to_csv_in_s3(prisons_outbreaks, 
                             "alpha-hmpps-covid-data-processing/prison_outbreak.csv", 
                             overwrite = TRUE, 
                             row.names = FALSE)
print(paste0("Total number of outbreaks currently sits at ", nrow(prisons_outbreaks)))

# read in our prison locations
prisons_lookup <- s3_path_to_full_df("alpha-hmpps-covid-data-processing/community-prevalence/prison_x_region.csv")
# remove covid reasons from breakdown
prisons_lookup <- prisons_lookup %>% 
  dplyr::mutate_at(c("prison", "government_region"), str_to_lower)

 ############################# Set some values for the Covid returns #########################

# Note we need a number of different settings to read the different version of the excel book 
# as the format changes over time.

STATS_S3_BUCKET <- "alpha-covid-data-collection"
SUMMARY_FOLDER <- "summary-data"
S3_BUCKET <- "alpha-hmpps-covid-data-processing"
MAN_SUMMARY_NAME <- "20200427_Summary_Data.xlsx"

