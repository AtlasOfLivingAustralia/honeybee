#' Build a query
#' 
#' This is ported from `galah/utilities_internal.R`, where it is an internal 
#' function. Designed to take standardised `galah` objects and turn them into
#' queries
#' 
#' @export build_query

##----------------------------------------------------------------
##                   Query-building functions                   --
##----------------------------------------------------------------

# Build query list from constituent arguments
build_query <- function(identify, filter, location, select = NULL,
                        profile = NULL) {
                          
  if(getOption("galah_config")$atlas == "Global"){
    api_engine <- "gbif"
  }else{
    api_engine <- "ala"
  }

  if (is.null(identify)) {
    if(api_engine == "gbif"){
      taxa_query <- list(taxonKey = 1)
    }else{
      taxa_query <- NULL
    }
  } else { # assumes a tibble or data.frame has been given
    if(nrow(identify) < 1){
      taxa_query <- NULL
    } else {
      check_taxa_arg(identify)
      # include <- !inherits(taxa, "exclude") # obsolete
      if (inherits(identify, "data.frame") &&
          "identifier" %in% colnames(identify)) {
        identify <- identify$identifier
      }
      #TODO: Implement a useful check here- i.e. string or integer
      # assert_that(is.character(taxa))
      taxa_query <- build_taxa_query(identify)
    }
  }
  
  # validate filters
  if (is.null(filter)) {
    filter_query <- NULL
  } else {
    assert_that(is.data.frame(filter))
    # remove profile from filter rows
    # filters <- filters[filters$variable != "profile",]
    if (nrow(filter) == 0) {
      filter_query <- NULL
    } else {
      filter_query <- build_filter_query(filter)
    }
  }
  
  if(api_engine == "gbif"){
    query <- c(taxa_query, filter_query)
  }else{
    query <- list(fq = c(taxa_query, filter_query)) 
  } 
  
  if (is.null(location)) {
    area_query <- NULL
  } else {
    area_query <- location
    query$wkt <- area_query
  }
  if (check_for_caching(taxa_query, filter_query, area_query, select)) {
    query <- cached_query(taxa_query, filter_query, area_query)
  }
  if (getOption("galah_config")$atlas == "Australia") {
    if (!is.null(profile)) {
      query$qualityProfile <- profile
    } else {
      query$disableAllQualityFilters <- "true"
    }
  }
  query
}

# Build query from vector of taxonomic ids
build_taxa_query <- function(ids) {
  ids <- ids[order(ids)]
  if(getOption("galah_config")$atlas == "Global"){
    return(list(taxonKey = ids))
  }else{
    taxon_code <- "lsid"
    return(paste0("(lsid:", 
      paste(ids, collapse = paste0(" OR lsid:")), 
    ")"))
  }
}

# Takes a dataframe produced by galah_filter and return query as a list
# Construct individual query term
# Add required brackets, quotes to make valid SOLR query syntax
query_term <- function(name, value, include) {
  # add quotes around value
  value <- lapply(value, function(x) {
    # don't add quotes if there are square brackets in the term
    if (grepl("\\[", x)) {
      x
    } else {
      paste0("\"", x, "\"")
    }
  })
  # add quotes around value
  if (include) {
    value_str <- paste0("(", paste(name, value, collapse = " OR ", sep = ":"),
                        ")")
  } else {
    value_str <- paste0("-(", paste(name, value,
                                   collapse = " OR ", sep = ":"), ")")
  }
  value_str
}

old_query_term <- function(name, value, include) {
  # add quotes around value
  value <- lapply(value, function(x) {
    # don't add quotes if there are square brackets in the term
    if (grepl("\\[", x)) {
      x
    } else {
      paste0("\"", x, "\"")
    }
  })
  # add quotes around value
  if (include) {
    value_str <- paste0("(", paste(name, value, collapse = " OR ", sep = ":"),
                        ")")
  } else {
    value_str <- paste0("(", paste(paste0("-", name), value,
                                   collapse = " AND ", sep = ":"), ")")
  }
  value_str
}

build_filter_query <- function(filters) {
  if(getOption("galah_config")$atlas == "Global"){
    queries <- as.list(filters$value)
    names(queries) <- filters$variable
    queries
  }else{
    queries <- unique(filters$query)
    paste0(queries, collapse = " AND ")
  }
}

new_build_filter_query <- function(filters) {
  if(nrow(filters) > 1){
    query <- paste(
      apply(
        filters[, c("query", "join")], 
        1, 
        function(a){paste0(a, collapse = "")
      }),
     collapse = "")
    query <- sub("NA$", "", query)
  }else{
    query <- filters$query
  }
  return(query)
}

# Extract profile row from filters dataframe created by galah_filter
extract_profile <- function(filters) {
  profile <- NULL
  if (!is.null(filters)){
    profile <- attr(filters, "dq_profile")
  }
  profile
}

# Replace logical R values with strings
filter_value <- function(val) {
  if (is.logical(val)) {
    return(ifelse(val, "true", "false"))
  }
  val
}

# Construct string of column
build_columns <- function(col_df) {
  if (nrow(col_df) == 0) {
    return("")
  }
  paste0(col_df$name, collapse = ",")
}

build_assertion_columns <- function(col_df) {
  if (nrow(col_df) == 0) {
    return("none")
    # all assertions have been selected
  } else if (nrow(col_df) == 107) {
    return("includeall")
  }
  paste0(col_df$name, collapse = ",")
}