get.who.liked <- function(user, token){
  
 media.id <- get.media.id(user, token)
  
  if(length(media.id)!=0){
    
    df <- data.frame()
    
    for(i in 1:length(media.id)){
      
      con = curl(paste0("https://api.instagram.com/v1/media/",media.id[i],"/likes?access_token=",token))
      call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
      close(con)
    if(length(call$data)!=0){
      for(j in 1:length(call$data)){ 
        df.tmp <- data.frame(
        media = media.id[i],
        liker = call$data[[j]]$id
        )
      df.tmp$author <- rep(user,nrow(df.tmp))
       
      df <- rbind(df,df.tmp)
      }
      
    }
    cat(paste("...", i, sep = ""))
    }
  return(df)
  }else{
    return(NULL)
  }
}   
