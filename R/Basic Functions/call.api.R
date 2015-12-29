

call.api <- function(query, token){
  con = curl(paste0("https://api.instagram.com/v1/users/",query,"/?access_token=",token))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}

