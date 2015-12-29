get.geo <- function(user, token){

  call <- get.user(user, token)
  
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
      
      n <- call$data$counts$media
      
      con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token,"&count=35"))
      
      call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
      
      close(con)
      
      cat(user)
      
      if(length(call$pagination)==0){
        
        df <- rbind.fill(lapply(call$data, function(x){
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
        )
        )
        return(df) 
      }
      else{
        
        df <- rbind.fill(lapply(call$data, function(x){
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
        )
        )
        
        n.retrieved <- length(call$data)
        
        while((n.retrieved<n) & (length(call$pagination)!=0)){
          
          next.url <- paste0(call$pagination$next_url,"&count=35")
          con = curl(next.url)
          call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
          close(con)
          
          df2 <- rbind.fill(lapply(call$data, function(x){
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
          )
          )
          
          
          df <- rbind.fill(df, df2)
          n.retrieved.tmp <- length(call$data)
          n.retrieved <- n.retrieved+n.retrieved.tmp
          cat(paste("...", n.retrieved, sep = ""))
        }
        cat("... Done")
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
