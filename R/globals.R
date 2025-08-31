# Packages (exactly what you used)
pkgs <- c(
  "shiny","ggplot2","dplyr","rnaturalearth","sf","shinydashboard","lubridate",
  "wordcloud2","scales","plotly","readxl","tidyverse","viridis","patchwork",
  "hrbrthemes","fmsb","colormap","VennDiagram","gridExtra","stringr","memoise"
)
invisible(lapply(pkgs, require, character.only = TRUE))

options(shiny.sanitize.errors = FALSE)
