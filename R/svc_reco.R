get_history <- function(user_df, movies, username="User 7", n=50){
  uh <- user_df |> dplyr::filter(user == username) |>
    dplyr::mutate(show = tolower(show)) |>
    dplyr::count(show, sort = TRUE)
  
  hits <- character()
  for (s in uh$show) {
    if (tolower(s) %in% tolower(movies$title)) hits <- c(hits, s)
    if (length(hits) >= n) break
  }
  unique(hits)
}

open_search <- function(movies, corpora, sentence){
  tokens <- strsplit(tolower(sentence), "\\s+")[[1]]
  for (t in tokens) {
    if (t %in% corpora$genres)    return(movies[grepl(t, tolower(movies$genres)), ])
    if (t %in% corpora$countries) return(movies[grepl(t, tolower(movies$orign_country)), ])
    if (t %in% corpora$languages) return(movies[grepl(t, tolower(movies$language)), ])
  }
  # fallback: sample
  movies[sample(nrow(movies)), ]
}
