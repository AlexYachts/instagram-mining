call.media.pagination <- function(url){tryCatch({
  
  con = curl(url)
  
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  
  close(con)
  
  return(call)
}
,
error = function(e) NULL)}