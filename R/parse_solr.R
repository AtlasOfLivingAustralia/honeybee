#' parse a query into `solr` syntax
#' 
#' Many living atlases use `solr` as their indexing engine. This function takes
#' a `tibble` of specified structure, and parses it to return a valid `solr`
#' query.
#' 
#' @param df A `tibble` containing columns `variable`, `logical` and `value`
#' 
#' @return A vector of valid solr queries
#' @export parse_solr

# NOTE: This is a copy of galah/R/galah_filter.R/parse_query

parse_solr <- function(df){

  # determine what 'type' of string it is
  df$type <- rep("logical", nrow(df))
  vector_check <- grepl("c\\(|seq\\(", df$value)
  if(any(vector_check)){
    df$type[vector_check] <- "vector"
  }
  assertion_check <- df$variable %in% show_all_assertions()$id
  if(any(assertion_check)){
    df$type[assertion_check] <- "assertion"
  }

  # build a valid solr query
  df$query <- unlist(lapply(
    split(df, seq_len(nrow(df))), 
    function(a){
      switch(a$type,
        "logical" = parse_logical(a),
        "vector" = parse_vector(a),
        "assertion" = parse_assertion(a)
      )
    }))
    
  # exception for missingness
  missing_check <- grepl("\"\"\"\"", df$query)
  if(any(missing_check)){
    df$query[missing_check] <- unlist(lapply(
      split(df[missing_check, ], seq_along(which(missing_check))),
      function(a){
        switch(a$logical,
          "==" = paste0("(*:* AND -", a$variable, ":*)"),
          paste0("(", a$variable, ":*)")
        )
      }))
   }  
    
  # return query only
  return(df$query)
}

parse_logical <- function(df){
  switch(df$logical,
    "=" = {query_term(df$variable, df$value, TRUE)},
    "==" = {query_term(df$variable, df$value, TRUE)},
    "!=" = {query_term(df$variable, df$value, FALSE)},
    ">=" = {paste0(df$variable, ":[", df$value, " TO *]")},
    ">" = {paste0(df$variable, ":[", df$value, " TO *] AND -", query_term(df$variable, df$value, TRUE))},
    "<=" = {paste0(df$variable, ":[* TO ", df$value, "]")},
    "<" = {paste0(df$variable, ":[* TO ", df$value, "] AND -", query_term(df$variable, df$value, TRUE))}
  )
}


# question: does the below work when df$value is a character? May add 2x quotes
parse_vector <- function(df){
  clean_text <- gsub("\\\\", "", df$value) # remove multiple backslahses 
  values <- eval(parse(text = clean_text)) 
  paste0(
    if(df$logical == "!="){"-"},
    "(",
    paste(
      paste0(df$variable, ":\"", values, "\""),
    collapse = " OR "),
    ")")
}


parse_assertion <- function(df){
  logical <- isTRUE(as.logical(df$value))
  if(df$logical == "!="){logical <- !logical} # case where `variable != FALSE`
  logical_str <- ifelse(logical, "=", "!=")
  rows <- data.frame(variable = "assertions",
                     logical = logical_str,
                     value = df$variable)
  parse_logical(rows)
}