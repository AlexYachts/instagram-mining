ifelse(!require(curl), install.packages("curl"), require(curl))
ifelse(!require(rjson), install.packages("rjson"), require(rjson))
ifelse(!require(plyr), install.packages("plyr"), require(plyr))
ifelse(!require(parallel), install.packages("parallel"), require(parallel))

load("./data/Token")