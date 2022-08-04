# This script builds all information stored within galah/R/sysdata.rda
# storing of such code in /data-raw is recommended in 'R Packages' by 
# Hadley Wickham, section 8.3 'Internal data'
# https://r-pkgs.org/data.html

library(readr)
node_metadata <- read_csv("./data-raw/node_metadata.csv")


# configuration for web services of all atlases
# NOTE:
  # Australia, Brazil & UK use their own taxonomy
  # All other atlases use GBIF taxonomy
  # Order of priority is local-namematching > local-species > GBIF-namematching
  # France and Canada use GBIF due to lack of species service
# QUESTION: 
  # is this the best way to configure? 
  # How do we add different `path` behaviours for the same function in diff atlases?


# option 1: long-form full-text
node_config <- read_csv("./data-raw/node_config.csv")


# add to r/sysdata.rda
usethis::use_data(
  node_metadata,
  node_config,
  internal = TRUE, 
  overwrite = TRUE)


# # there is no API for GBIF fields, so hard-code them
# # this list can be found using sort(rgbif::occ_fields)
# # NOTE: these are not currently used anywhere in `galah`
# gbif_fields <- function(){
#   data.frame(id = c(
#     "basisOfRecord", "catalogNumber", "class", "classKey",       
#     "collectionCode", "country", "countryCode", "datasetKey",
#     "datasetName", "dateIdentified", "day", "decimalLatitude",
#     "decimalLongitude", "eventDate", "eventTime", "extensions",
#     "facts", "family", "familyKey", "gbifID", "genericName",
#     "genus", "genusKey", "geodeticDatum", "identificationID",
#     "identifier", "identifiers", "institutionCode", "issues",
#     "key", "kingdom", "kingdomKey", "lastCrawled", 
#     "lastInterpreted", "lastParsed", "modified", "month",
#     "name", "occurrenceRemarks", "order", "orderKey",
#     "phylum", "phylumKey", "protocol", "publishingCountry",
#     "publishingOrgKey", "recordedBy", "references", "relations",
#     "rights", "rightsHolder", "scientificName", "species",
#     "speciesKey", "specificEpithet", "taxonID", "taxonKey",
#     "taxonRank", "verbatimEventDate", "year" 
#   ))
# }

# # https://gbif.github.io/gbif-api/apidocs/org/gbif/api/vocabulary/OccurrenceIssue.html
# gbif_assertions <- function() {
#   tibble(
#     id = c(
#       "AMBIGUOUS_COLLECTION",
#       "AMBIGUOUS_INSTITUTION",
#       "BASIS_OF_RECORD_INVALID"
#     ),
#     description = c(
#       "The given collection matches with more than 1 GRSciColl collection",
#       "The given institution matches with more than 1 GRSciColl institution",
#       "The given basis of record is impossible to interpret or significantly different from the recommended vocabulary"
#     ),
#     type = "assertions"
#   )
# }