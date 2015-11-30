get.geo.new <- function(user, token){
  
  call <- get.user(user, token)
  
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
      
      n <- call$data$counts$media
      
      con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token))
      
      call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
      
      close(con)
      
      if(length(call$pagination)==0){
        
        df <- rbind.fill(lapply(call$data, function(x){
          df.tmp <- data.frame(
            author = x$user$id,
            media = x$id,
            likes = x$likes$count,
            created.time = toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01")),
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
            author = x$user$id,
            media = x$id,
            likes = x$likes$count,
            created.time = toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01")),
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
          
          next.url <- call$pagination$next_url
          con = curl(next.url)
          call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
          close(con)
          
          df2 <- rbind.fill(lapply(call$data, function(x){
            df.tmp <- data.frame(
              author = x$user$id,
              media = x$id,
              likes = x$likes$count,
              created.time = toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01")),
              longitude = ifelse(!is.null(x$location$longitude), x$location$longitude, NA),
              latitude = ifelse(!is.null(x$location$latitude), x$location$latitude, NA)
            )
            df.tmp <- subset(df.tmp, !is.na(longitude)|!is.na(latitude))
            row.names(df.tmp) <- NULL
            return(df.tmp)
          }
          )
          )
          
          
          df <- rbind(df, df2)
          n.retrieved.tmp <- length(call$data)
          n.retrieved <- n.retrieved+n.retrieved.tmp
          cat(paste("...", n.retrieved, sep = ""))
        }
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