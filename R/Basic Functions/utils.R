# functions

source("./R/Basic Functions/unlist.with.NA.R")
source("./R/Basic Functions/call.api.R")
source("./R/Basic Functions/get.user.R")
source("./R/Basic Functions/get.follows.R")
source("./R/Basic Functions/get.followed.R")
source("./R/Basic Functions/get.media.R")
source("./R/Basic Functions/get.who.liked.R")
source("./R/Basic Functions/get.who.commented.R")
source("./R/Basic Functions/get.media.id.R")
source("./R/Basic Functions/get.edgelist.follows.R")
source("./R/Basic Functions/get.edgelist.followed.R")
source("./R/Basic Functions/get.geo.R")


# token
token <- Sys.getenv("TOKEN", "")

# packages
ifelse(!require(plyr), install.packages("plyr"), require(plyr))
ifelse(!require(rjson), install.packages("rjson"), require(rjson))
ifelse(!require(curl), install.packages("curl"), require(curl))

