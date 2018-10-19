# Requirements

require(curl)
require(rjson)
require(plyr)
require(parallel)
require(compiler)

# Load Token

load("./Data/Token")

# First, we have to create some functions to retrieve the data

# A function to perform a basic call to the APIs

call.api <- function(query, token){
  con = curl(paste0("https://api.instagram.com/v1/users/",query,"/?access_token=",token))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}

# A function to get basic information about a user

get.user <- function(user, token){
  if(!is.na(user)){
    tryCatch(call.api.cmp(user,token),
             error = function(e) {return(NA)})
  }else{return(NA)
  }
}

# A function that retrieves information about the first 35 media of a user

call.media <- function(user,token){tryCatch({
  con = curl(paste0("https://api.instagram.com/v1/users/",user,"/media/recent?access_token=",token,"&count=35"))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}, error = function(e) NULL)}

# Function used in the pagination loop, with the same purpose of the call.media function

call.media.pagination <- function(url){tryCatch({
  con = curl(url)
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}, error = function(e) NULL)}

# Function that creates a small document-term matrix of the tags used in an image

tags.f <- function(x){
  x2 <- t(rep(1, length(x)))
  df <- data.frame(x2)
  colnames(df) <- x
  return(df)
}

# Compiling was used on all the functions, to speed up when possible

tags.f.cmp <- cmpfun(tags.f)

# Function to store information in data frames

df.geo <- function(x){
  if(!is.null((x$location$latitude)) & !is.null((x$location$longitude))){
    if(x$location$longitude>9.040939 & x$location$longitude<9.278398 & x$location$latitude>45.386074 & x$location$latitude<45.535303){
  df.tmp <- data.frame(
    author = ifelse(!is.null(x$user$id), x$user$id, NA),
    media = ifelse(!is.null(x$id), x$id, NA),
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

# Function to create a parallelised version of lapply.
# The operative system used is Windows, which does not support forking, therefore the classic "mclapply" cannot be used.
# Credits to Nathan VanHoudnos for this hack.
# Check https://github.com/nathanvan/mcmc-in-irt/blob/master/post-10-mclapply-hack.R

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

df.geo.wrap <- function(call){rbind.fill(lapply(call$data, df.geo.cmp))}

# Compiling

df.geo.wrap.cmp <- cmpfun(df.geo.wrap)

# Main function. It takes a user as input and it gives as output a data frame of only the media uploaded in Milan.

get.geo<- function(user, token){
  call <- get.user.cmp(user, token)
  if(!is.na(call[1])){
    if(call$data$counts$media!=0){
      n <- call$data$counts$media
      call <- call.media.cmp(user,token)
      if(!is.null(call)){
        if(length(call$pagination)==0){
          df <- df.geo.wrap.cmp(call)
          return(df) 
        }
        else{
          df <- df.geo.wrap.cmp(call)
          n.retrieved <- length(call$data)
          while((n.retrieved<n) & (length(call$pagination)!=0)){
            next.url <- paste0(call$pagination$next_url,"&count=35")
            call <- call.media.pagination.cmp(next.url)
            if(!is.null(call)){
              df2 <- df.geo.wrap.cmp(call)
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

# Final compiling

get.geo.cmp <- cmpfun(get.geo)

# mclapply.hack wrapper

get.geo.mclapply.hack <- function(x, token){rbind.fill(mclapply.hack(x, get.geo.cmp,token))}

# Compiling

get.geo.mclapply.hack.cmp <- cmpfun(get.geo.mclapply.hack)

# Now we can use get.geo.mclapply.hack.cmp to retrieve geo localised data
# First, retrieve the people that are followed by the people you follow by performing breadth first search.
# Store it in follows.follows using the get.follows function defined in perform_breadth_first_search.R
# follows.follows is a list of lists. Unlist it first

follows.follows.list <- lapply(follows.follows, as.list)

follows.follows.unlist.list <- as.list(unlist(follows.follows.list))

# Append also the first degree follows

users <- append(follows, follows.follows.unlist.list)

# Using 'unique' to avoid duplicates

users.list <- unique(users)

# Splitting the users in conformable lists of 100 users each

users.vector <- do.call(c, users.list)

elements.f <- rep(seq_len(ceiling(length(users.vector) / 100)),each = 100,length.out = length(users.vector))
users.final<- split(users.vector, f = elements.f)

# Application of the get.geo function to all the lists, with consequent storage in csv format

lapply(seq_along(users.final), function(i,x,token){
  df <- get.geo.mclapply.hack.cmp(x[[i]],token)
  write.table(df, paste0("./Data/geo",x[[i]][[1]],".csv"), sep=",")
  Sys.sleep(600)
}, x=users.final, token=token)
