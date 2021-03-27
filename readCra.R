library(xlsx)
library(tidyr)
library(tidytext)
library(tidyverse)
library(dplyr)

## Initialize read parameters
url_data <- "https://www.canada.ca/en/news/advanced-news-search/news-results.html?typ=newsreleases&dprtmnt=revenueagency"
url_data <- "https://www.canada.ca/en/news/advanced-news-search/news-results.html?typ=newsreleases&idx=10&dprtmnt=revenueagency"

body > main > div:nth-child(2) > div.mwsharvest.section > article:nth-child(2) > h3 > a
body > main > div:nth-child(2) > div.mwsharvest.section > article:nth-child(3) > h3 > a

templatePage <- c(
  "body > main > div:nth-child(2) > div.mwsharvest.section > article:nth-child(",
  ") > h3 > a"
)

# Extract links to websites with CRA data
wrapIt <- function(currentIndex,beforeAndAfter = c("","")){
  paste0(beforeAndAfter[1],
         currentIndex,
         beforeAndAfter[2])
}

articleCss <- wrapIt(2:11,templatePage)
url_data <- "https://www.canada.ca/en/news/advanced-news-search/news-results.html?typ=newsreleases&dprtmnt=revenueagency"
pagePieces <- c("https://www.canada.ca/en/news/advanced-news-search/news-results.html?typ=newsreleases&idx=",
                "&dprtmnt=revenueagency")

readPage <- url_data %>% 
  read_html()

pageIndex <- 0
htmlLabelsStore <- c()
htmlLabel <- NULL

while((is.na(readPage)==FALSE)&(sum(is.na(htmlLabel))<1)){
  htmlLabel <- rep(NA,length(articleCss))
  
  for(currentCssIndex in 1:length(articleCss)){
    takeHtml <- as.character(html_node(readPage,css = articleCss[currentCssIndex])) 
    
    htmlLabel[currentCssIndex] <- str_extract(takeHtml, "<a [:graph:]+>") %>%
      substring(10,nchar(.)-2)
    
  }
  
  htmlLabelsStore <- c(htmlLabelsStore, htmlLabel)

  pageIndex <- pageIndex + 10
  url_data <- 
    wrapIt(pageIndex,pagePieces)
  readPage <- url_data %>% 
    read_html()
}

htmlLabelsStore <- htmlLabelsStore[!is.na(htmlLabelsStore)]
cutters <- c(
  "ottawa, ontario canada revenue agency",
  "ottawa canada revenue agency", 
  "ottawa, on canada revenue agency",
  "ottawa, ontario - canada revenue agency",
  "ottawa, on - canada revenue agency",
  "summerside, prince edward island canada revenue agency",
  "ottawa - canada revenue agency",
  "ottawa, ontario – canada revenue agency",
  "ottawa, ontario revenue agency",
  "vancouver canada revenue agency",
  "vancouver, december 8, 2017 -",
  ", january 28, 2017",
  "gatineau, qc canada revenue agency",
  "gatineau, quebec canada revenue agency",
  ", quebec canada revenue agency",
  "toronto, ontario canada revenue agency",
  "news release the",
  "canada revenue agency news release"
)

release <- rep(NA,length(htmlLabelsStore))

for(currentLabel in 1:length(htmlLabelsStore)){
  url_data <- htmlLabelsStore[currentLabel]
  
  readCurrent <- url_data %>% 
    read_html()
  
  readTextCurrent <- readCurrent %>%
    #html_node(css = "#news-release-container > div.mrgn-bttm-md > div > div > div > p:nth-child(1)") %>% 
    html_text() %>%
    tolower() 
  
  cutEnd <- str_split(readTextCurrent, "- 30 -")[[1]][1]
  cutEnd <- str_split(cutEnd, "related products\r\n")[[1]][1]
  cutEnd <- str_split(cutEnd, "associated links\r\n")[[1]][1]
  cutEnd <- str_split(cutEnd, "contacts\r\n")[[1]][1]
  cutFinal <- str_squish(str_replace_all(cutEnd,"quick facts\r\n", ""))
  
  checkIndex <- 1
  finalCut <- str_split(cutFinal, cutters[checkIndex])[[1]][2]

  while((is.na(finalCut)==TRUE)&(checkIndex < length(cutters))){
    checkIndex <- checkIndex + 1
    finalCut <- str_split(cutFinal, cutters[checkIndex])[[1]][2]
  }
  
  #readTextHead <- readCurrent %>%
  #  html_node(css = "body > main > div:nth-child(2) > div:nth-child(2) > p:nth-child(1)") %>% 
  #  html_text() %>%
  #  tolower() 
  
  #if(is.na(readTextHead)) {
  #  readTextHead <- readCurrent %>%
  #    html_node(css = "#news-release-container > div.mrgn-bttm-md > div > div > div > p:nth-child(1)") %>% 
  #    html_text() %>%
  #    tolower() 
  #}
  
  #cutBegin <- str_split(readTextCurrent,readTextHead)[[1]][2]

  release[currentLabel] <- finalCut
}

#allReleases <- paste(release, collapse = " \n ")
article <- 1:length(release)
releaseTibble <- tibble(article,release)

releaseTibble %>%
  unnest_tokens(word,release)
