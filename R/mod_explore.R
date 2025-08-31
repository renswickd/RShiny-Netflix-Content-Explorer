mod_explore_ui <- function(id){
  ns <- NS(id)
  fluidRow(
    shinydashboard::box(width=3,
                        selectInput(ns("type"), "Type:",     choices=NULL),
                        selectInput(ns("language"), "Language:", choices=NULL),
                        selectInput(ns("title"), "Title:",   choices=NULL)
    ),
    shinydashboard::box(width=8,
                        uiOutput(ns("detail_card")),
                        plotOutput(ns("worldMapFiltered"), height = 420)
    )
  )
}

mod_explore_server <- function(id, ds){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    movies <- ds$movies
    
    # initialise choices
    observe({
      updateSelectInput(session, "type", choices = c("All", sort(unique(movies$type))), selected="All")
      updateSelectInput(session, "language", choices = c("All", sort(unique(movies$language))), selected="All")
      updateSelectInput(session, "title", choices = c("All", sort(unique(movies$title))), selected="All")
    })
    
    r_titles <- reactive({
      f <- movies
      if (input$type     != "All") f <- dplyr::filter(f, type == input$type)
      if (input$language != "All") f <- dplyr::filter(f, language == input$language)
      f
    })
    
    observe({
      updateSelectInput(session, "language",
                        choices = c("All", sort(unique(r_titles()$language))), selected = "All")
    })
    observe({
      updateSelectInput(session, "title",
                        choices = c("All", sort(unique(r_titles()$title))), selected = "All")
    })
    
    output$worldMapFiltered <- renderPlot({
      if (is.null(input$title) || input$title == "All") {
        make_world_map_all(ds$world, r_titles())
      } else {
        row <- dplyr::filter(r_titles(), title == input$title) |> dplyr::slice(1)
        make_world_map_one(ds$world, row$orign_country[1])
      }
    })
    
    output$detail_card <- renderUI({
      if (is.null(input$title) || input$title == "All") return(NULL)
      row <- dplyr::filter(r_titles(), title == input$title) |> dplyr::slice(1)
      tagList(
        tags$img(src = row$image_url %||% row$image, width = 350, height = 400),
        build_title_card(row)
      )
    })
  })
}
