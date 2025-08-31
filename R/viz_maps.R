make_world_map_all <- function(world, movies){
  counts <- movies |> dplyr::group_by(orign_country) |> dplyr::summarise(count=dplyr::n())
  world2 <- dplyr::left_join(world, counts, by=c("name_long"="orign_country"))
  ggplot(world2) +
    geom_sf(aes(fill=count)) +
    scale_fill_continuous(na.value="gray", low="red", high="darkred") +
    theme_minimal(base_size=10) +
    theme(plot.background=element_rect(fill="#141414", color=NA),
          panel.background=element_rect(fill="#141414", color=NA),
          panel.grid=element_blank(),
          axis.text=element_text(color="#FFFFFF"),
          axis.title=element_text(color="#FFFFFF"),
          plot.title=element_text(color="#FFFFFF", size=20, face="bold")) +
    labs(title="Number of Movies by Country", fill="Number of Movies")
}

make_world_map_one <- function(world, country){
  world |>
    dplyr::mutate(is_selected = ifelse(name_long == country, "selected","not_selected")) |>
    ggplot() +
    geom_sf(aes(fill=is_selected)) +
    scale_fill_manual(values=c(not_selected="grey", selected="#E50914")) +
    theme_minimal() + labs(title=paste("Origin Country:", country), fill="Country")
}

build_title_card <- function(x){
  tags$div(
    tags$h4(x$title),
    tags$p(x$plot),
    tags$h5(icon("users"), "Cast:"), tags$p(x$cast),
    tags$h5(icon("clock"), "Runtime:", x$runtime, "minutes"),
    tags$h4(icon("star"), "Rating:", x$rating, "/ 10")
  )
}
