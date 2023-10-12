library(httr2)
library(jsonlite)
library(purrr)
library(raster)

token <-  'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IkF2ZC1ka2RBaUFrYWNfSEFDcDlDcyJ9.eyJodHRwczovL3N0YWMuc3RhZ2luZy5yZWVmZGF0YS5pby9yb2xlcyI6W10sImh0dHBzOi8vc3RhYy5zdGFnaW5nLnJlZWZkYXRhLmlvL2FwcF9tZXRhZGF0YSI6eyJhdXRob3JpemF0aW9uIjp7Imdyb3VwcyI6W10sInBlcm1pc3Npb25zIjpbXSwicm9sZXMiOltdfX0sIm5pY2tuYW1lIjoibGlsaWFuLmZpZXJyb2FyY29zIiwibmFtZSI6IkRlbmlzc2UgRmllcnJvIEFyY29zIiwicGljdHVyZSI6Imh0dHBzOi8vcy5ncmF2YXRhci5jb20vYXZhdGFyL2FjNWZmNGMxN2FlZjAxNDkzYjdhNDhiNGNlZGE0NmZmP3M9NDgwJnI9cGcmZD1odHRwcyUzQSUyRiUyRmNkbi5hdXRoMC5jb20lMkZhdmF0YXJzJTJGZGYucG5nIiwidXBkYXRlZF9hdCI6IjIwMjMtMTAtMTFUMDE6NDc6NDMuOTI2WiIsImVtYWlsIjoibGlsaWFuLmZpZXJyb2FyY29zQHV0YXMuZWR1LmF1IiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vc3RhZ2luZy1yZWVmZGF0YS5hdS5hdXRoMC5jb20vIiwiYXVkIjoiNXNhWDMyZ2R5ZGJEUEtjV1pUbThWTmhxSk1RVDhVelkiLCJpYXQiOjE2OTcwODk3MTgsImV4cCI6MTY5NzE3NjExOCwic3ViIjoiYXV0aDB8NjQ3ZWI1MWQ3NTM3NGVlM2Q3YmM3NWM3Iiwic2lkIjoia00wZTRzM3Jza2RLdVYwWW5hSDNYREtxLXBvWjd3cUgifQ.YkTzK_K72xo0jg_X27DZuxPPluGEs25XSHMTraIeXXwCSwBxgQmCgDo0uK6ooDOozY7xv_tiNiYbVApU2bKTvXTs-uMvUd_u9yEEU9UYJZLIHdsBLMZjLU77_kXrqneTG5eERqN3q2oDKLSMME52uN-a5TaBVIqDfrpJa9VBTL7ER6dP6PqQMt5IWeuRExe6uCb3wnyrCmhsmKPMt6tZmZiElFD51-3hLmw-G8t5cIjUFdKI65JxOfIjiys-FOCoyUwdzSn_sZTjPca1QBqU54YhnkXm9kosgGq6WJFIRJJQgcm5IVg7LVnQeSq9KlWDe_3aPZ_hwJJd9msUN4QyVQ'

dataURL <- "https://pygeoapi.staging.reefdata.io/collections/noaa-crw-dhw/coverage?datetime=2023-02-01/2023-02-10"

req <- request(dataURL) |>
  req_headers("Authorization" = paste("Bearer", token),
              Accept = "application/json") |>
  req_perform()

dd <- req |> 
  resp_body_json()

## create a matrix
## get coordinates
lonMin <- dd$domain$axes$x$start
lonMax <- dd$domain$axes$x$stop
lonN <- dd$domain$axes$x$num #- 1
latMin <- dd$domain$axes$y$start
latMax <- dd$domain$axes$y$stop
latN <- dd$domain$axes$y$num #- 1
#longitudes <- seq(lonMin, lonMax, round((lonMax - lonMin)/lonN, 3))
#latitudes <- seq(latMin, latMax, round((latMax - latMin)/latN, 3))
time <- dd$domain$axes$time$num
times <- seq(as.Date(dd$domain$axes$time$start), as.Date(dd$domain$axes$time$stop), by = "days")

## create a matrix
mm <- dd$ranges$degree_heating_week$values
mm[sapply(mm, is.null)] <- NA
mm <- mm |> 
  list_c() 

t1 <- mm[1:(360*720)] |> 
  matrix(nrow = latN+1, ncol = lonN+1, byrow = T)
plot(raster(t1, xmn = lonMin, xmx = lonMax,
            ymn = latMax, ymx = latMin))

x <- array(dim = c(latN+1, lonN+1, time))
dim_mat <- 360*720
for(i in seq_len(time)){
  if(i == 1){
    s <- 1
    e <- dim_mat
  }else{
    s <- s+dim_mat
    e <- dim_mat*i
  }
  x[,,i] <- matrix(mm[s:e], nrow = latN+1, ncol = lonN+1, byrow = T)
}

brick_x <- brick(x, xmn = lonMin, xmx = lonMax,
                 ymn = latMax, ymx = latMin)

names(brick_x) <- times
plot(brick_x$X2023.02.01)


(unlist(mm, use.names = FALSE))
dimnames <- list(latitude=latitudes, longitude=longitudes)
ddMatrix = matrix(mm, nrow = latN+1, ncol = lonN+1, dimnames=dimnames)
## make a data frame
df <- as.data.frame(ddMatrix)
df$lat <- latitudes
df1 <- df |> pivot_longer(cols = 1:(ncol(df)-1), values_to = "dhw", names_to = "lon")
df1$lon <- as.numeric(df1$lon)