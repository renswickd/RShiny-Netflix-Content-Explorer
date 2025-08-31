# reusable rail
build_horizontal_rail <- function(df, id_prefix){
  tagList(
    div(class="movie-container",
        lapply(seq_len(nrow(df)), function(i){
          movie <- df[i, ]
          div(class="movie-item",
              img(src = movie$image_url %||% movie$image,  # supports either column name
                  id  = paste0(id_prefix, i)),
              div(class="movie-title", movie$title))
        })
    )
  )
}

`%||%` <- function(a,b) if (!is.null(a) && !is.na(a)) a else b
