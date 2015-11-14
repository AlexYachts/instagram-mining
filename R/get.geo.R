get.geo <- function(user, token){
  
  call <- get.user(user, token)
  
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
    
    n <- call$data$counts$media
    
    con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token))
    
    call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
    
    close(con)
    
    if(length(call$pagination)==0){
      df <- data.frame()
      
      for(i in 1:length(call$data)){
            df.tmp <- data.frame(
            author = call$data[[i]]$user$id,
            media = call$data[[i]]$id,
            likes = call$data[[i]]$likes$count,
            created.time = toString(as.POSIXct(as.numeric(call$data[[i]]$created_time), origin="1970-01-01")),
            longitude = ifelse(!is.null(call$data[[i]]$location$longitude), call$data[[i]]$location$longitude, NA),
            latitude = ifelse(!is.null(call$data[[i]]$location$latitude), call$data[[i]]$location$latitude, NA)
          )
          df <- rbind(df,df.tmp)
          cat(paste("...", i, sep = ""))
        }
      df <- subset(df, !is.na(longitude)|!is.na(latitude))
      row.names(df) <- NULL
      return(df) 
    }
    else{
      
      df <- data.frame()
      
      
      for(i in 1:length(call$data)){
        df.tmp <- data.frame(
          author = call$data[[i]]$user$id,
          media = call$data[[i]]$id,
          likes = call$data[[i]]$likes$count,
          created.time = toString(as.POSIXct(as.numeric(call$data[[i]]$created_time), origin="1970-01-01")),
          longitude = ifelse(!is.null(call$data[[i]]$location$longitude), call$data[[i]]$location$longitude, NA),
          latitude = ifelse(!is.null(call$data[[i]]$location$latitude), call$data[[i]]$location$latitude, NA)
        )
        df <- rbind(df,df.tmp)
      }
      
      n.retrieved <- length(call$data)
      
      while((n.retrieved<n) & (length(call$pagination)!=0)){
        
        next.url <- call$pagination$next_url
        con = curl(next.url)
        call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
        close(con)
              
        df2 <- data.frame()
        
        for(i in 1:length(call$data)){
          df.tmp <- data.frame(
            author = call$data[[i]]$user$id,
            media = call$data[[i]]$id,
            likes = call$data[[i]]$likes$count,
            created.time = toString(as.POSIXct(as.numeric(call$data[[i]]$created_time), origin="1970-01-01")),
            longitude = ifelse(!is.null(call$data[[i]]$location$longitude), call$data[[i]]$location$longitude, NA),
            latitude = ifelse(!is.null(call$data[[i]]$location$latitude), call$data[[i]]$location$latitude, NA)
          )
          df2 <- rbind(df2,df.tmp)
        }
        
          
        df <- rbind(df, df2)
        n.retrieved.tmp <- length(call$data)
        n.retrieved <- n.retrieved+n.retrieved.tmp
        cat(paste("...", n.retrieved, sep = ""))
      }
      df <- subset(df, !is.na(longitude)|!is.na(latitude))
      row.names(df) <- NULL
      return(df)
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
