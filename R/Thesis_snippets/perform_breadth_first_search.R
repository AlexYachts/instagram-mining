# Requirements 
load("./Data/Token")

require(plyr)
require(rjson)
require(curl)

# Creation of a basic function to make basic calls to Instagram's API

call.api <- function(query, token){
  con = curl(paste0("https://api.instagram.com/v1/users/",query,"/?access_token=",token))
  call <- suppressWarnings(fromJSON(readLines(con), unexpected.escape = "keep"))
  close(con)
  return(call)
}

# Creation of a function that retrieves information about a single users

get.user <- function(user, token){
  if(!is.na(user)){
    tryCatch(call.api(user,token),
    error = function(e) {return(NA)})
}else{return(NA)}
}

# Use of the get.user function on the own account

self.info <- get.user("self", token)

# Save just the ID

self.info.id <- self.info$data$id

# Creation of a function to retrieve information about people followed

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

# Application of the function to the own account

follows <- get.follows(self.info.id, token)

# Application of the function to the people followed

follows.follows <- lapply(follows,get.follows, token)
