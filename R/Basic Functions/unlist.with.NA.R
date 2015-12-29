unlistWithNA <- function(lst, field){
  if (length(field)==1){
    notnulls <- unlist(lapply(lst, function(x) !is.null(x[[field]])))
    vect <- rep(NA, length(lst))
    vect[notnulls] <- unlist(lapply(lst, function(x) x[[field]]))
  }
  if (length(field)==2){
    notnulls <- unlist(lapply(lst, function(x) !is.null(x[[field[1]]][[field[2]]])))
    vect <- rep(NA, length(lst))
    vect[notnulls] <- unlist(lapply(lst, function(x) x[[field[1]]][[field[2]]]))
  }
  if (field[1]=="shares"){
    notnulls <- unlist(lapply(lst, function(x) !is.null(x[[field[1]]][[field[2]]])))
    vect <- rep(0, length(lst))
    vect[notnulls] <- unlist(lapply(lst, function(x) x[[field[1]]][[field[2]]]))
  }
  if (length(field)==3){
    notnulls <- unlist(lapply(lst, function(x) 
      tryCatch(!is.null(x[[field[1]]][[field[2]]][[field[3]]]), 
               error=function(e) FALSE)))
    vect <- rep(NA, length(lst))
    vect[notnulls] <- unlist(lapply(lst[notnulls], function(x) x[[field[1]]][[field[2]]][[field[3]]]))
  }
  if (length(field)==4 & field[1]=="to"){
    notnulls <- unlist(lapply(lst, function(x) 
      tryCatch(!is.null(x[[field[1]]][[field[2]]][[as.numeric(field[3])]][[field[4]]]), 
               error=function(e) FALSE)))
    vect <- rep(NA, length(lst))
    vect[notnulls] <- unlist(lapply(lst[notnulls], function(x) x[[field[1]]][[field[2]]][[as.numeric(field[3])]][[field[4]]]))
  }
  if (field[1] %in% c("comments", "likes") & !is.na(field[2])){
    notnulls <- unlist(lapply(lst, function(x) !is.null(x[[field[1]]][[field[2]]][[field[3]]])))
    vect <- rep(0, length(lst))
    vect[notnulls] <- unlist(lapply(lst, function(x) x[[field[1]]][[field[2]]][[field[3]]]))
  }
  return(vect)
}