read_movies <- memoise(function(path="data/netflix_list.csv"){
  read.csv(path) |> dplyr::slice_head(n = 3000)
})

read_users <- memoise(function(path="data/user_data.xlsx"){
  readxl::read_excel(path) |> as.data.frame()
})

svc_data_init <- function(){
  movies <- read_movies()
  users  <- read_users()
  
  genres_corpus   <- tolower(unique(unlist(strsplit(movies$genres, ","))))
  country_corpus  <- tolower(unique(movies$orign_country))
  language_corpus <- tolower(unique(movies$language))
  
  # user_df shaping (kept identical to your code)
  user_df <- users |>
    dplyr::filter(user %in% c("User 7","User 8")) |>
    dplyr::mutate(a    = substring(as.character(duration), 12, 19),
                  date = substring(as.character(start_time),1,10),
                  hour = substring(as.character(start_time),12,13))
  
  user_df$minutes_decimal <- sapply(user_df$a, convert_to_minutes)
  user_df$show <- sapply(user_df$title, remove_after_colon)
  
  # world sf
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  
  list(
    movies = movies,
    user_df = user_df,
    world = world,
    corpora = list(
      genres   = genres_corpus,
      countries= country_corpus,
      languages= language_corpus
    )
  )
}
