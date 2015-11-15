# functions

source("./R/unlist.with.NA.R")
source("./R/call.api.R")
source("./R/get.user.R")
source("./R/get.follows.R")
source("./R/get.followed.R")
source("./R/get.media.R")
source("./R/get.who.liked.R")
source("./R/get.who.commented.R")
source("./R/get.media.id.R")
source("./R/get.edgelist.follows.R")
source("./R/get.edgelist.followed.R")
source("./R/get.geo.R")

# token
token <- Sys.getenv("TOKEN", "")

# packages
ifelse(!require(plyr), install.packages("plyr"), require(plyr))
ifelse(!require(rjson), install.packages("rjson"), require(rjson))
ifelse(!require(curl), install.packages("curl"), require(curl))

