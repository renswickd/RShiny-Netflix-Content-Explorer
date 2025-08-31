convert_to_minutes <- function(time_string){
  sp <- strsplit(time_string, ":")[[1]]
  if (length(sp) < 3) return(NA_real_)
  as.numeric(sp[1]) * 60 + as.numeric(sp[2]) + as.numeric(sp[3]) * 0.01
}

remove_after_colon <- function(text){
  if (str_detect(text, ":")) str_split(text, ":", n = 2)[[1]][1] else text
}

remove_after_paranthesis <- function(text){
  if (str_detect(text, fixed("("))) str_split(text, fixed("("), n = 2)[[1]][1] else text
}
