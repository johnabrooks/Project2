# Initialize libraries
## Standard
library(xlsx)
library(tidyr)
library(tidytext)
library(tidyverse)
library(dplyr)

## Words list
# install.packages("qdapDictionaries")
library(qdapDictionaries)

# Read in file
dirIn <- "/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2"
fileIn <- "Redacted FAB_Project_raw_data_Clean EXCEL Dec.23"

# Create Path
pathIn <- paste(dirIn,"/",fileIn,".xlsx",sep="")

# Read in data
rawData <- read.xlsx(pathIn,1)

# Process columns
columnNamesStore <- names(rawData)

cleanData <- rawData
names(cleanData) <- paste("c",1:ncol(cleanData),sep="_")

View(cleanData)

nonCatColumns <- c(14,
                   22,
                   30,
                   40,
                   41,
                   43,
                   45,
                   46,
                   48)

# Scrape free text columns
procData <- cleanData[,c(1,2,nonCatColumns)]
newNames <- names(procData)
selectNames  <- newNames[c(3:length(newNames))]

######### Translate here

# Pivot the data
pivtData <- procData %>%
  
  # Select only those columns with the ID and the phrases
  select(c(1,2,selectNames)) %>%
  
  # Pivot the data to be cataloged by ID and question index
  pivot_longer(selectNames,names_to = "column",values_to = "response")

# Prepare data for translation
forTranslation <- pivtData %>%
  
  # Take out french
  filter(c_2 == "FR") 
  
### process every "value

# Prepare data for translation
forProcessEng <- pivtData %>%
  
  # Take out french
  filter(c_2 == "EN") %>%
  
  # Get the responses into words
  unnest_tokens(word, response) %>%
  
  # Select the words column
  select(c("word")) %>%
  
  # Get the unique words
  unique()

# load the dictionary
wordVector <- qdapDictionaries::DICTIONARY$word

wordfile <- read.csv("/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2/words.txt",sep="\n")
wordsList <- tolower(wordfile$X2)

lengthProc <- nrow(forProcessEng)
isWord <- rep(FALSE,lengthProc)
for(currentIndex in 1:nrow(forProcessEng)) {
  isWord[currentIndex] <- as.character(forProcessEng[currentIndex,1]) %in%
    wordsList
}


# See non-words
forProcessEng[!isWord,1]
