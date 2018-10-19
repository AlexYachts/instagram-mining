# This part is inspired by Julian Hillebrand's Tutorial.
# Check http://thinktostart.com/analyze-instagram-r/ for more.

# Requirements
require(httr)
require(rjson)
require(RCurl)
require(httpuv)

# Go on http://instagram.com/developer/
# Click on "Register Your Application" and go through the login.
# Set the parameters for your App. 
# Execute the following code to get an OAuth redirect URI:

full_url <- oauth_callback()
full_url <- gsub("(.*localhost:[0-9]{1,5}/).*", x=full_url, replacement="\\1")

print(full_url)

# Copy this URL and paste it in your app settings.

# After clicking on "Register" you will be redirected to your app authentication details.
# We need them to define the following 4 variables:

app_name <- "XXX"         #the name of your app
client_id <- "XXX"        #id number
client_secret <- "XXX"    #secret number
scope = "basic"           #The level of authorization you want to get. Basic is enough to start downloading data.

# Next we create the connection to the API.
# We provide the access points:

instagram <- oauth_endpoint(
  authorize = "https://api.instagram.com/oauth/authorize",
  access = "https://api.instagram.com/oauth/access_token")  
myapp <- oauth_app(app_name, client_id, client_secret)

# Here we have the Authentication

ig_oauth <- oauth2.0_token(instagram, myapp,scope=scope,  type = "application/x-www-form-urlencoded",cache=FALSE)  

# Now the browser should open and ask you to give permission to the app.
# After you returned to R you should have received your access token.

tmp <- strsplit(toString(names(ig_oauth$credentials)), '"')
token <- tmp[[1]][4]

save(token, file="./Data/Token")
