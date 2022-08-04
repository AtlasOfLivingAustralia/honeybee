#' Show orgs
#' 
#' Returns a `tibble` of supported biodiversity organisations with working APIs. 
#' Note that not all GBIF nodes are supported currently by `honeybee`
#' 
#' @export show_orgs

show_orgs <- function(){node_metadata}

#' Show endpoints
#' 
#' Returns a `tibble` of supported API endpoints. In development.
#' 
#' @export show_urls

show_urls <- function(){node_config}