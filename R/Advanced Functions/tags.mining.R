# Packages & Token

source("./R/Advanced Functions/requirements.R")

# Main function, to retrieve tags and media published in 2015 located in Milan

source("./R/Advanced Functions/get.geo.mclapply.milan.tags.2015.R")

# Start

load("./data/users.final.RData")

lapply(seq_along(users.final), function(i,x,token){
  df <- get.geo.mclapply.milan.tags.2015(x[[i]],token)
  write.table(df, paste0("./data/extraction",x[[i]][[1]],".csv"), sep=",")
  Sys.sleep(600)
}, x=users.final, token=token)