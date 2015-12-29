call.media <- function(user,token){tryCatch({
  
  con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token,"&count=35"))
  
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  
  close(con)
  
  return(call)
}
,
error = function(e) NULL)}