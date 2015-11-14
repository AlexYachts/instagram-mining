

get.edgelist.follows <- function(user, token){
  
  edge <- get.follows(user, token)
  df = data.frame(n. = 1:length(edge))
  df$vertex <- rep(user,nrow(df))
  df <- cbind(df,edge)
  df$n. <- NULL
    
return(df)

}
  
  
  