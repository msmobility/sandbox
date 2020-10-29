# chromedriver.exe
# selenium server standalone
# both should be located in the same folder where the R script is located<
# first in CMD navigate to the folder where RScript is
# write java -jar selenium-server-standalone.jar -port 5556
# Afterwards the work in R can be started

#install.packages("devtools")
#install.packages("RSelenium")
#install.packages("rvest")
#install.packages("tidyverse")

library(devtools)
library(RSelenium)
library(rvest)
library(tidyverse)

testit <- function(x)
{
  p1 <- proc.time()
  Sys.sleep(x)
  proc.time() - p1 # The cpu usage should be negligible
}

browser <- remoteDriver(port = 5556)
# open chrome browser
remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 5556,
  browserName = "chrome")

remDr$open()

# provide the link
remDr$navigate("https://applications.icao.int/icec")

# list of cities we need to create city-pairs from
cities <- c("Berlin", "Frankfurt", "Dortmund", "Dresden", "Dusseldorf", "Hanover")

# table where the information is stored
finalTable <- data.frame(matrix(ncol = 5, nrow = 0))
x <- c("From", "To", "Distance,km", "AircraftFuelBurn,kg", "CO2perPass,kg")
colnames(finalTable) <- x

# for-loop to create city-pairs from provided list of cities(cities)
for (i in 1:length(cities)){
  for (j in 1:length(cities)) {
  
    # select "One Way" and click it
    webElem <- remDr$findElement(using = 'xpath', value = "//*[@class='form-control']")
    testit(3)
    webElem$clickElement()
    
    webElem1 <- remDr$findElement(using = 'xpath', "//option[contains(.,'One Way')]")
    testit(3)
    webElem1$clickElement()
    
    # fill in the first window FROM
    autocomplete <- cities[i]
    testit(2)
    FROM <- remDr$findElement(using = "name", value= "frm1")$sendKeysToElement(list(autocomplete))
    testit(2)
    remDr$findElements("id", "ui-id-1")[[1]]$clickElement()
    
    # fill in the second window TO
    autocomplete <- cities[j]
    testit(2)
    TO <- remDr$findElement(using = "name", value= "to1")$sendKeysToElement(list(autocomplete))
    testit(2)
    remDr$findElements("id", "ui-id-2")[[1]]$clickElement()
    
    # press "Compute" ("Search", "OK")
    web.elem <- remDr$findElements("id", "computeByInput")[[1]]$clickElement()
    
    # in case the provided city-pair does not exist the PopUp window will apper. Check if there is a PopUp window
    alert <- try(remDr$getAlertText(), silent=T) # check if there is an alert window
    
    # in case there is a PopUp window reload the page and go with next city-pair
    # in case there is NO PopUp window proceed to extract the required information
    if(class(alert) != "try-error") { # if an alert window is present, do the following
      signals <- data.frame(callsign = NA, network = NA, ch_num = NA, band = NA, strength = NA, cont.strength = NA)
      remDr$acceptAlert()
      remDr$navigate("https://applications.icao.int/icec")
    } else { # if no alert, continue on as normal
      testit(1)
      # extracting required data from the page
      web.elem <- remDr$findElements(using = "class", value = "active")
      content <- unlist(lapply(web.elem, function(e) { e$getElementText() }))
      content <- content[8]
      content <- as.data.frame(content)
      split_result <- strsplit(as.character(content$content), " ")
      length_n <- sapply(split_result, length)
      length_max <- seq_len(max(length_n))
      tempTable <- as.data.frame(t(sapply(split_result, "[", i = length_max)))
      tempTable <- tempTable[,c(1,2,3,ncol(tempTable)-1,ncol(tempTable))]
      #column rename
      x <- c("From", "To", "Distance,km", "AircraftFuelBurn,kg", "CO2perPass,kg")
      colnames(tempTable) <- x
      #store new data in the final table
      finalTable <- rbind(finalTable, tempTable)
      testit(1)
    }
    # reload the page
    remDr$navigate("https://applications.icao.int/icec")
  }
  
}