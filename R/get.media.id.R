
get.media.id <- function(user, token){
  
  call <- get.user(user, token)
  
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
    
    n <- call$data$counts$media
    
    con=curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token))
    
    call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
    
    close(con)


    
    if(length(call$pagination)==0){
      media.id <- unlistWithNA(call$data,'id') 
      return(media.id) 
    }
    else{
      media.id <- unlistWithNA(call$data,'id')
      n.retrieved <- length(call$data)
      while((n.retrieved<n) & (length(call$pagination)!=0)){
        next.url <- call$pagination$next_url
        con = curl(next.url)
        call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
        close(con)
        media.id.tmp <- unlistWithNA(call$data,'id')
        media.id <- append(media.id, media.id.tmp)
        n.retrieved.tmp <- length(call$data)
        n.retrieved <- n.retrieved+n.retrieved.tmp
        cat(paste("...", n.retrieved, sep = " "))
      }
      return(media.id)
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
