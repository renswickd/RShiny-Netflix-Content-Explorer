# R/viz_activity.R
agg_user_time <- function(user_df, user, by_month=FALSE){
  df <- dplyr::filter(user_df, user == !!user)
  if (by_month){
    df |>
      dplyr::mutate(month = substring(date,6,7),
                    MONTHS = month.abb[as.integer(month)],
                    x = factor(MONTHS, levels = month.abb)) |>
      dplyr::group_by(x) |>
      dplyr::summarise(total = sum(minutes_decimal)/60, .groups="drop")
  } else {
    df |>
      dplyr::group_by(date) |>
      dplyr::summarise(total = sum(minutes_decimal)/60, .groups="drop") |>
      dplyr::mutate(x = factor(date))
  }
}

make_hours_bar <- function(df, xlab){
  ggplot(df, aes(x=x, y=total)) +
    geom_bar(stat="identity", fill="#E50914") +
    theme_minimal(base_size=15) +
    theme(plot.background=element_rect(fill="#141414", color=NA),
          panel.background=element_rect(fill="#141414", color=NA),
          panel.grid=element_blank(),
          axis.text=element_text(color="#FFFFFF"),
          axis.title=element_text(color="#FFFFFF"),
          plot.title=element_text(color="#FFFFFF", size=20, face="bold")) +
    labs(title="Total View Hours by User", x=xlab, y="Number of Hours")
}

hour_radar_df <- function(user_df){
  u7 <- dplyr::filter(user_df, user=="User 7") |> dplyr::group_by(hour) |> dplyr::summarise(avg=mean(minutes_decimal), .groups="drop")
  u8 <- dplyr::filter(user_df, user=="User 8") |> dplyr::group_by(hour) |> dplyr::summarise(avg=mean(minutes_decimal), .groups="drop")
  # guard for missing “02”
  if (!"02" %in% u7$hour) u7 <- rbind(u7, data.frame(hour="02", avg=0))
  u7 <- u7[order(u7$hour), ]; u8 <- u8[order(u8$hour), ]
  data.frame(rbind(rep(50,24), rep(0,24), u7$avg, c(u8$avg, rep(0, max(0,24-length(u8$avg))))))
}
