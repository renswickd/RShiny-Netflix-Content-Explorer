# R/mod_activity.R
mod_activity_ui <- function(id){
  ns <- NS(id)
  fluidPage(
    fluidRow(
      shinydashboard::box(width=6,
                          selectInput(ns("user"), "Select Profile:", choices=c("User 7","User 8")),
                          checkboxInput(ns("by_month"), "Show Month Wise Total", FALSE)),
      shinydashboard::box(width=12, status="primary", plotOutput(ns("hours_plot")))
    ),
    fluidRow(
      shinydashboard::box(width=4, plotOutput(ns("pattern_by_hour"))),
      shinydashboard::box(width=4, wordcloud2Output(ns("wordcloud_display"))),
      shinydashboard::box(width=4, plotOutput(ns("venn_diagram")))
    )
  )
}

mod_activity_server <- function(id, ds){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    user_df <- ds$user_df
    
    # bars
    output$hours_plot <- renderPlot({
      df <- agg_user_time(user_df, input$user, input$by_month)
      make_hours_bar(df, if (isTRUE(input$by_month)) "Month" else "Date")
    })
    
    # radar
    output$pattern_by_hour <- renderPlot({
      ph <- hour_radar_df(user_df)
      colnames(ph) <- c(paste0(0:11,"am"), paste0(1:12,"pm"))
      par(mar=c(0,0,0,0))
      fmsb::radarchart(ph, axistype=1, plwd=4,
                       pcol=c(rgb(0.9,0.5,0.5,0.9), rgb(0.2,0.7,0.6,0.9)),  plty=1,
                       pfcol=c(rgb(0.9,0.5,0.5,0.4), rgb(0.2,0.7,0.6,0.4)),
                       cglcol="gray", axislabcol="#E50914", caxislabels=seq(0,50,10), vlcex=0.8)
    })
    
    # wordcloud
    output$wordcloud_display <- renderWordcloud2({
      wc <- user_df |> dplyr::filter(user == input$user) |> dplyr::count(show, name="freq")
      wordcloud2(wc, size=4, color='random-light', backgroundColor="white")
    })
    
    # venn
    output$venn_diagram <- renderPlot({
      u7 <- user_df |> dplyr::filter(user=="User 7") |> dplyr::pull(show)
      u8 <- user_df |> dplyr::filter(user=="User 8") |> dplyr::pull(show)
      vd <- VennDiagram::venn.diagram(
        x = list(user7 = u7, user8 = u8),
        category.names = c("User 7","User 8"),
        filename = NULL, fill = c("#E50914","#E50914"),
        alpha = c(0.5,0.5), lty="blank", cex=2, fontface="bold",
        cat.cex=2, cat.fontface="bold", cat.pos=c(-20,20))
      grid::grid.draw(vd); gridExtra::grid.arrange(grobs=list(vd))
    })
  })
}
