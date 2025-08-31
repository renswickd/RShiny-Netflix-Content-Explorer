mod_hub_ui <- function(id){
  ns <- NS(id)
  tagList(
    div(id="search-bar", div(id="search-container", textInput(ns("search"), "", placeholder="Search Movies"))),
    uiOutput(ns("search_results")),
    h3("Recommended for you"), uiOutput(ns("rail_reco")),
    h3("Trending in USA"),     uiOutput(ns("rail_usa")),
    h3("Recently Added"),      uiOutput(ns("rail_recent")),
    h3("Top on IMDB Ratings"), uiOutput(ns("rail_top")),
    div(style="display:flex;align-items:center;justify-content:center;",
        textInput(ns("openSearch"), "", placeholder="Can you tell me what's on your mind?"),
        actionButton(ns("suggest"), "Suggest", class="red-button"))
  )
}

mod_hub_server <- function(id, ds){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    movies  <- ds$movies
    user_df <- ds$user_df
    
    # search card (first match only, same as your logic)
    output$search_results <- renderUI({
      q <- tolower(input$search)
      if (is.null(q) || nchar(q) <= 3) return(NULL)
      res <- movies[grepl(q, tolower(movies$title)), ]
      if (!nrow(res)) return(NULL)
      res <- res[1, , drop = FALSE]
      build_horizontal_rail(res, id_prefix = "search_")
    })
    
    # rails
    output$rail_reco <- renderUI({
      picks <- get_history(user_df, movies, username="User 7", n = 50)
      df <- dplyr::filter(movies, tolower(title) %in% picks)
      build_horizontal_rail(df, "reco_")
    })
    
    output$rail_usa <- renderUI({
      df <- dplyr::filter(movies, orign_country == "United States")
      build_horizontal_rail(df, "usa_")
    })
    
    output$rail_recent <- renderUI({
      df <- movies[!is.na(movies$endYear), ]
      df <- df[order(-df$endYear), ]
      build_horizontal_rail(df, "recent_")
    })
    
    output$rail_top <- renderUI({
      df <- movies[order(-movies$rating), ]
      build_horizontal_rail(df, "top_")
    })
    
    # modal carousel
    idx <- reactiveVal(1)
    
    show_movie_modal <- function(pool){
      i <- idx()
      i <- if (i < 1) 1 else if (i > nrow(pool)) 1 else i
      idx(i)
      
      showModal(modalDialog(
        title = tags$span(class="modal-title","Are you looking for this?"),
        tags$div(class="modal-body",
                 tags$div(class="movie-details",
                          tags$img(src = pool$image_url[i] %||% pool$image[i]),
                          tags$h3(pool$title[i]),
                          tags$p(paste("Rating:", pool$rating[i])),
                          tags$p(paste("Plot:", pool$plot[i])),
                          tags$p(paste("Release Year:", pool$year[i]))
                 )),
        footer = tags$div(class="modal-footer",
                          actionButton(ns("prev_button"), "Prev", class="red-button"),
                          actionButton(ns("next_button"), "Next", class="red-button")),
        easyClose = TRUE
      ))
    }
    
    pool_cache <- reactiveVal(NULL)
    
    observeEvent(input$suggest, {
      pool_cache(open_search(movies, ds$corpora, input$openSearch))
      idx(1)
      show_movie_modal(pool_cache())
    })
    
    observeEvent(input$next_button, {
      idx(idx() + 1)
      removeModal(); show_movie_modal(pool_cache())
    })
    observeEvent(input$prev_button, {
      idx(idx() - 1)
      removeModal(); show_movie_modal(pool_cache())
    })
  })
}
