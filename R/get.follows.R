

get.follows <- function(user, token){
  
call <- get.user(user, token)

if(!is.na(call[1])){
  if(call$data$counts$follows!=0){

n <- call$data$counts$follows

con = curl(paste0("https://api.instagram.com/v1/users/",user,"/follows?access_token=",token))

call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))

if(length(call$pagination)==0){
  follows.id <- unlistWithNA(call$data,'id') 
  cat(paste("...", n, sep = ""))
  return(follows.id) 
}
else{
  follows.id <- unlistWithNA(call$data,'id')
  n.retrieved <- length(call$data)
  while((n.retrieved<n) & (length(call$pagination)!=0)){
    next.url <- call$pagination$next_url
    con = curl(next.url)
    call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
    close(con)
    follows.id.tmp <- unlistWithNA(call$data,'id')
    follows.id <- append(follows.id, follows.id.tmp)
    n.retrieved.tmp <- length(call$data)
    n.retrieved <- n.retrieved+n.retrieved.tmp
    cat(paste("...", n.retrieved, sep = ""))
  }
  return(follows.id)
  }
}
else{
  return(NULL)
}
}
else{
  return(NULL)
}

}

