# Requirements

require(compiler)

# Basic Functions

call.api <- function(query, token){
  con = curl(paste0("https://api.instagram.com/v1/users/",query,"/?access_token=",token))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}

get.user <- function(user, token){
  if(!is.na(user)){
    tryCatch(call.api.cmp(user,token),
             error = function(e) {return(NA)})
  }else{return(NA)
  }
}

call.media <- function(user,token){tryCatch({
  con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token,"&count=35"))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}, error = function(e) NULL)}


call.media.pagination <- function(url){tryCatch({
  con = curl(url)
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}, error = function(e) NULL)}


tags.f <- function(x){
  x2 <- t(rep(1, length(x)))
  df <- data.frame(x2)
  colnames(df) <- x
  return(df)
}

# Compiling

tags.f.cmp <- cmpfun(tags.f)

# Geo Data Frame generator

df.geo <- function(x, followers){
  if(!is.null((x$location$latitude)) & !is.null((x$location$longitude))){
    if(as.numeric(x$created_time)>1420066800 & x$location$longitude>9.040939 & x$location$longitude<9.278398 & x$location$latitude>45.386074 & x$location$latitude<45.535303){
      df.tmp <- data.frame(
        author = ifelse(!is.null(x$user$id), x$user$id, NA),
        followers = ifelse(!is.null(followers), followers, NA),
        media = ifelse(!is.null(x$id), x$id, NA),
        likes = ifelse(!is.null(x$likes$count), x$likes$count, NA),
        created.time = ifelse(!is.null(toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01"))), toString(as.POSIXct(as.numeric(x$created_time), origin="1970-01-01")), NA),
        longitude = ifelse(!is.null(x$location$longitude), x$location$longitude, NA),
        latitude = ifelse(!is.null(x$location$latitude), x$location$latitude, NA),
        id.location = ifelse(!is.null(x$location$id), x$location$id, NA)
      )
      tags <- tags.f.cmp(x$tags)
      df.tmp <- cbind(df.tmp, tags)
      return(df.tmp)
    }else{return(NULL)}
  }else{return(NULL)}
}

# mclapply hack, courtesy of Nathan VanHoudnos
# http://edustatistics.org/nathanvan/2015/10/14/parallelsugar-an-implementation-of-mclapply-for-windows/

mclapply.hack <- function(...) {
  size.of.list <- length(list(...)[[1]])
  cl <- makeCluster( min(size.of.list, detectCores()) )
  loaded.package.names <- c(
    sessionInfo()$basePkgs,
    names( sessionInfo()$otherPkgs ))
  tryCatch( {
    this.env <- environment()
    while( identical( this.env, globalenv() ) == FALSE ) {
      clusterExport(cl,
                    ls(all.names=TRUE, env=this.env),
                    envir=this.env)
      this.env <- parent.env(environment())
    }
    clusterExport(cl,
                  ls(all.names=TRUE, env=globalenv()),
                  envir=globalenv())
    parLapply( cl, 1:length(cl), function(xx){
      lapply(loaded.package.names, function(yy) {
        require(yy , character.only=TRUE)})
    })
    return( parLapply( cl, ...) )
  }, finally = {        
    stopCluster(cl)
  })
}

# Compiling of Basics

call.api.cmp <- cmpfun(call.api)

get.user.cmp <- cmpfun(get.user)

call.media.cmp <-cmpfun(call.media)

call.media.pagination.cmp <- cmpfun(call.media.pagination)

df.geo.cmp <- cmpfun(df.geo)

mclapply.hack.cmp <-cmpfun(mclapply.hack)

# Intermediate Wrapper

df.geo.wrap <- function(call, followers){rbind.fill(lapply(call$data, df.geo.cmp, followers))}

# Compiling

df.geo.wrap.cmp <- cmpfun(df.geo.wrap)

# Main Function

get.geo.fast<- function(user, token){
  call <- get.user.cmp(user, token)
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
      followers <- call$data$counts$followed_by
      n <- call$data$counts$media
      call <- call.media.cmp(user,token)
      if(!is.null(call)){
        if(length(call$pagination)==0){
          df <- df.geo.wrap.cmp(call, followers=followers)
          return(df) 
        }
        else{
          df <- df.geo.wrap.cmp(call, followers=followers)
          n.retrieved <- length(call$data)
          while((n.retrieved<n) & (length(call$pagination)!=0)){
            next.url <- paste0(call$pagination$next_url,"&count=35")
            call <- call.media.pagination.cmp(next.url)
            if(!is.null(call)){
              df2 <- df.geo.wrap.cmp(call, followers=followers)
              df <- rbind.fill(df, df2)
              n.retrieved.tmp <- length(call$data)
              n.retrieved <- n.retrieved+n.retrieved.tmp
            }else{break}
          }
          return(df)
        }
      }
      else{return(NULL)}
    }else{return(NULL)}
  }else{return(NULL)}
}

# compiling

get.geo.fast.cmp <- cmpfun(get.geo.fast)

# mclapply.hack wrapper

get.geo.mclapply.hack <- function(x, token){rbind.fill(mclapply.hack(x, get.geo.fast.cmp,token))}

# Final compiling

get.geo.mclapply.milan.tags.2015 <- cmpfun(get.geo.mclapply.hack)