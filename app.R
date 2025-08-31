library(shiny)

source("R/globals.R", local = TRUE)

ui <- fluidPage(
  tags$head(tags$link(rel="stylesheet", href="styles.css")),
  titlePanel(tags$span("Netflix Content Explorer & Activity Tracker", class = "title-bold-red")),
  tabsetPanel(
    tabPanel("The Hub",          mod_hub_ui("hub")),
    tabPanel("Explore Contents", mod_explore_ui("explore")),
    tabPanel("Track My Activity",mod_activity_ui("activity"))
  )
)

server <- function(input, output, session){
  ds <- svc_data_init()     # central data bundle
  mod_hub_server("hub", ds = ds)
  mod_explore_server("explore", ds = ds)
  mod_activity_server("activity", ds = ds)
}

shinyApp(ui, server)
