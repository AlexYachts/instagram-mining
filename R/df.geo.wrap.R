df.geo.wrap <- function(x){
  df.tmp <- data.frame(
    author = ifelse(!is.null(x$user$id), x$user$id, NA),
    media = ifelse(!is.null(x$id), x$id, NA),
    likes = ifelse(!is.null(x$likes$count), x$likes$count, NA),
    created.time = ifelse(!is.null(toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01"))), toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01")), NA),
    longitude = ifelse(!is.null(x$location$longitude), x$location$longitude, NA),
    latitude = ifelse(!is.null(x$location$latitude), x$location$latitude, NA)
  )
  df.tmp <- subset(df.tmp, !is.na(longitude)|!is.na(latitude))
  row.names(df.tmp) <- NULL
  return(df.tmp)
}