

get.followed <- function(user, token){
  
 call <- get.user(user, token)
 
 if(!is.na(call[1])){
   if(call$data$counts$followed_by!=0){
  
  n <- call$data$counts$followed_by
  
  con = curl(paste0("https://api.instagram.com/v1/users/",user,"/followed-by?access_token=",token))
  
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  
  close(con)

  if(length(call$pagination)==0){
    followed.id <- unlistWithNA(call$data,'id')
    cat(paste("...", n, sep = ""))
    return(followed.id) 
  }
  else{
    followed.id <- unlistWithNA(call$data,'id')
    n.retrieved <- length(call$data)
    while((n.retrieved<n) & (length(call$pagination)!=0)){
      next.url <- call$pagination$next_url
      con = curl(next.url)
      call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
      close(con)
      followed.id.tmp <- unlistWithNA(call$data,'id')
      followed.id <- append(followed.id, followed.id.tmp)
      n.retrieved.tmp <- length(call$data)
      n.retrieved <- n.retrieved+n.retrieved.tmp
      cat(paste("...", n.retrieved, sep = ""))
    }
    return(followed.id)
  }
}
else{
  return(NULL)
}
 }else{
   return(NULL)
 }


}

