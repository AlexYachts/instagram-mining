
source("./R/utils.R")

# Data about self

self.info <- get.user("self", token)

self.info.id <- self.info$data$id

self.info.follows <- get.follows(self.info.id, token)

self.info.followed <- get.followed(self.info.id, token)

self.media <- get.media(self.info.id, token)

self.media.id <- get.media.id(self.info.id, token)

self.media.who.liked <- get.who.liked(self.info.id,token)

self.media.who.commented <- get.who.commented(self.info.id, token)

self.edgelist.follows <- get.edgelist.follows(self.info.id, token)

self.edgelist.followed <- get.edgelist.followed(self.info.id, token)

self.geo <- get.geo(self.info.id, token)


# Data about follows

follows <- self.info.follows

follows.follows <- lapply(follows,get.follows, token)

follows.followed <- lapply(follows,get.followed, token)

follows.media <- rbind.fill(lapply(follows,get.media, token))

follows.who.liked <- rbind.fill(lapply(follows,get.who.liked, token))

follows.who.commented <- rbind.fill(lapply(follows,get.who.commented, token))

follows.edgelist.follows <- rbind.fill(lapply(self.info.follows,get.edgelist.follows, token))

follows.edgelist.followed <- rbind.fill(lapply(follows,get.edgelist.followed, token))

follows.geo <- rbind.fill(lapply(follows,get.geo, token))













