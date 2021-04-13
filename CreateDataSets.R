# Initialization
library(xlsx)
library(tidyr)
library(tidytext)
library(tidyverse)
library(dplyr)
library(stringr)
library(word2vec)
library(R.utils)

# File path
questionsInFile <- "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/masterResponse.xlsx"
questionsData <- readxl::read_xlsx(questionsInFile)

adjColNames <- function(dfIn,newNames){
  return(colnames(dfIn) <- newNames)
}

# Discovered misspelling
misSpelled <- data.frame(rbind(
  c("adminsitrave","administrative"),
  c("assesment","assessment"),
  c("back and forths","redundant communication"),
  c("beuracracy","bureaucracy"),
  c("carreer","career"),
  c("clickets","clicks"),
  c("Clients's","client's"),
  c("Cluster's","clusters"),
  c("collegues","colleagues"),
  c("collugies","colleagues"),
  c("communicatiuons","communications"),
  c("consistetnly","consistently"),
  c("constent","constant"),
  c("containg","containing"),
  c("coporate","corporate"),
  c("costings","costing"),
  c("curretn","current"),
  c("desking","desk"),
  c("eceptional","exceptional"),
  c("effrective","effective"),
  c("emapathy","empathy"),
  c("emial","email"),
  c("empath ","empathetic"),
  c("enthusiactic","enthusiastic"),
  c("excellente","excellent"),
  c("explaination","explanation"),
  c("finanace","finance"),
  c("gliches","glitches"),
  c("inforamtion","information"),
  c("inperson","in person"),
  c("interfereing","interfering"),
  c("intrical","integral"),
  c("leavning","leaving"),
  c("managment","management"),
  c("nintey percent","90percent"),
  c("particualry","particularly"),
  c("perfer","prefer"),
  c("persay",""), #just eliminate / extraneous
  c("pletntiful","plentiful"),
  c("Plexi Glass","plexiglass"),
  c("positve","positive"),
  c("postions","positions"),
  c("prompty","promptly"),
  c("puticular","particular"),
  c("questons","questions"),
  c("refferences","references"),
  c("ressource","resource"),
  c("ressources","resources"),
  c("serie","series"), #alert
  c("sifficient","sufficient"),
  c("strenghts","strengths"),
  c("stylis","stylus"),
  c("THe","The"),
  c("timefram","time frame"),
  c("timeframe","time frame"),
  c("timeframes","time frames"),
  c("timeline","time line"),
  c("timelines","time lines"),
  c("unintentially","unintentionally"),
  c("unprecedent","unprecedented")
)) %>%
  adjColNames(.,c("error","corrected"))

# Change misSpellings into substitution ready patterns
misSpelled %>%
  mutate(error = paste0("\\b",error,"\\b")) -> p1

# Take away NA
questionsData %>%
  filter(!is.na(response)) -> noNAAnswers

# Replace misSpellings
for(indexAnswer in 1:dim(misSpelled)[1]) {
  noNAAnswers %>% 
    mutate(english = str_replace_all(english,p1[indexAnswer,1],p1[indexAnswer,2])) -> noNAAnswers
}

# xlsx::write.xlsx2(noNAAnswers, "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/noNonsense.xlsx")

# Once we have adjusted the entences properly
sentenceTokenize = noNAAnswers %>%
  unnest_tokens(output = sentences, token="sentences", input = english) %>%
  select(c_1, column, sentences)

dePunct = sentenceTokenize %>%
  mutate(sentences = str_replace_all(sentences,"[[:punct:]]"," "))

# Number of questions
questionColumns <- unique(questionsData$column)

# Filter to run on python
for(indexQuestion in 1:length(questionColumns)){
  dePunct %>%
    filter(column == questionColumns[indexQuestion]) %>%
    select(c_1,sentences) %>%
    data.frame() -> currentPull
  
  # Need to 0 this so it will play nicely with sklearn
  rownames(currentPull) <- as.numeric(rownames(currentPull))-1
  xlsx::write.xlsx2(currentPull, paste0(
    "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store/",
    questionColumns[indexQuestion],
    ".xlsx"))
}

