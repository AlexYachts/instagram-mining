
get.user <- function(user, token){
  if(!is.na(user)){
    tryCatch(call.api(user,token),
  error = function(e) {return(NA)})
}else{return(NA)
}
}
