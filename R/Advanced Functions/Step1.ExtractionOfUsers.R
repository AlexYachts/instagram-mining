# Packages & Token
source("./R/Advanced Functions/requirements.R")

# Functions needed

source("./R/Advanced Functions/get.geo.mclapply.milan.R")
source("./R/Basic Functions/unlist.with.NA.R")
source("./R/Basic Functions/get.follows.R")

# Get "self"

self.info <- get.user("self", token)

self.info.id <- self.info$data$id

# Get self's follows

follows <- get.follows(self.info.id, token)

# Get follows of follows

follows.follows <- mclapply.hack.cmp(follows,get.follows, token)

# Data manipulation to have them in lists of 100 each

follows.follows.list <- lapply(follows.follows, as.list)

follows.follows.unlist.list <- as.list(unlist(follows.follows.list))

users <- append(follows, follows.follows.unlist.list)

users.list <- unique(users)

users.vector <- do.call(c, users.list)

elements.f <- rep(seq_len(ceiling(length(users.vector) / 100)),each = 100,length.out = length(users.vector))
users.final<- split(users.vector, f = elements.f)

# Saving

save(users.final, file = "./data/users.final.RData")