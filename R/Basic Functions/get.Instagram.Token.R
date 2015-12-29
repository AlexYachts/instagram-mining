#########################################################################################
# How to get a Token for the Instagram API                                              #
# ------------------------------------------------------------------------------------- #
# source: Julian Hillebrand (http://thinktostart.com/analyze-instagram-r/) & Instagram  #
#########################################################################################


# Requirements ------------------------------------------------------------
require(httr)
require(rjson)
require(RCurl)
require(httpuv)

# The place to start is http://instagram.com/developer/
# Click on „Register Your Application“ and go through the login.
# On the next screen you can set the parameters for your app. 
# Then you have to enter an OAuth redirect URI. To choose it execute the following code:

## getting callback URL
full_url <- oauth_callback()
full_url <- gsub("(.*localhost:[0-9]{1,5}/).*", x=full_url, replacement="\\1")

print(full_url) #This will show you the preferred callback URI for httr. Copy this URL and paste it in your app settings.

# After clicking on „Register“ you will be redirected to your app authentication details.
# We need them to define the following 4 variables:

app_name <- "XXXX"         #the name of your app
client_id <- "XXXX"        #id number
client_secret <- "XXXX"    #secret number
scope = "basic"           #The level of authorization you want to get. Basic is enough to download likes or comments.

# Next we create the connection to the API.
# We provide the access points:

instagram <- oauth_endpoint(
  authorize = "https://api.instagram.com/oauth/authorize",
  access = "https://api.instagram.com/oauth/access_token")  
myapp <- oauth_app(app_name, client_id, client_secret)

# Here we have the Authentication

ig_oauth <- oauth2.0_token(instagram, myapp,scope=scope,  type = "application/x-www-form-urlencoded",cache=FALSE)  

# Now your browser should open and ask you to give permission to the app.
# After you returned to R you should have received your access token.

tmp <- strsplit(toString(names(ig_oauth$credentials)), '"')
token <- tmp[[1]][4]

# Save it for future use

save(token, file="./data/token")

