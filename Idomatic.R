#install.packages("rvest")
library(rvest)
library(stringr)
library(tidyverse)
library(sentimentr)

url_data <- "https://7esl.com/english-idioms/"

storeIdioms <- list()
indexNow <- 1
letterIndex <- "01"
css_selector <- paste0("#elementor-tab-content-24",
                       letterIndex,
                       " > table > tbody > tr:nth-child(",
                       indexNow,
                       ") > td")
readCurrent <- url_data %>% 
  read_html() %>% 
  html_node(css = css_selector) %>% 
  html_text() %>%
  tolower()

tibble(expression = "", 
       definition = "")

t <- data.frame(a = c(), b = c())
u <- data.frame(a = c(1), b = c(2))
u <- tibble(a = c(1), b = c(2))
t <- rbind(t, u)

if(is.na(readCurrent)==FALSE){
  intM <- str_split(readCurrent, ": ")
  storeIdioms[[as.numeric(letterIndex)]] <- 
    tibble(expression = intM[[as.numeric(letterIndex)]][1], 
           definition = intM[[as.numeric(letterIndex)]][2])
}

while(is.na(readCurrent)==FALSE){
  intM <- str_split(readCurrent, ": ")
  if(indexNow > 1){
    storeIdioms[[as.numeric(letterIndex)]] <- rbind(storeIdioms[[as.numeric(letterIndex)]], 
                                                    tibble(expression = intM[[1]][1], 
                                                           definition = intM[[1]][2]))
  } else {
    storeIdioms[[as.numeric(letterIndex)]] <- tibble(expression = intM[[1]][1], 
                                                     definition = intM[[1]][2])
  }
  indexNow <- indexNow + 1
  css_selector <- paste0("#elementor-tab-content-24",
                         letterIndex,
                         " > table > tbody > tr:nth-child(",
                         indexNow,
                         ") > td")
  
  readCurrent <- url_data %>% 
    read_html() %>% 
    html_node(css = css_selector) %>% 
    html_text() %>%
    tolower()
  
  if(is.na(readCurrent)==TRUE){
    indexNow <- 1
    if(as.numeric(letterIndex)<10){
      letterIndex <- paste0("0", as.numeric(letterIndex) + 1)
    } else {
      letterIndex <- paste0("0", as.numeric(letterIndex) + 1)
    }
    css_selector <- paste0("#elementor-tab-content-24",
                           letterIndex,
                           " > table > tbody > tr:nth-child(",
                           indexNow,
                           ") > td")
    readCurrent <- url_data %>% 
      read_html() %>% 
      html_node(css = css_selector) %>% 
      html_text() %>%
      tolower()
  }
}

getwd()
# setwd("/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2/")
# Save a single object to a file
# saveRDS(storeIdioms, "idiomsRead.rds")
# Restore it under a different name
storeIdioms <- readRDS("idiomsRead.rds")

for(currentLetter in 1:length(storeIdioms)) {
  storeIdioms[[currentLetter]]$expression <- tolower(storeIdioms[[currentLetter]]$expression)
  storeIdioms[[currentLetter]]$expression <- str_replace_all(storeIdioms[[currentLetter]]$expression, pattern = " \\(.*?\\)", "")
  storeIdioms[[currentLetter]]$definition <- tolower(storeIdioms[[currentLetter]]$definition)
}

#install.packages("sentimentr")
library(sentimentr)
# lexicon::hash_sentiment_jockers_rinker

#storeIdioms[[18]]
#sentiment_by(storeIdioms[[18]]$definition, by = NULL)
#View(emotion_by(storeIdioms[[18]]$definition, by = NULL))

#storeIdioms[[18]] %>%
#  get_sentences() %>%
#  sentiment_by(., by = "expression")

# Sentiment
sTibble <- data.frame(expression = c(), word_count = c(), sd = c(), 
                      ave_sentiment = c())

for(sTibbleIndex in 1:length(storeIdioms)) {
  storeIdioms[[sTibbleIndex]] %>%
    get_sentences() %>%
    sentiment_by(., by = "expression") %>%
    rbind(sTibble,.) -> sTibble
}

rsTibble <- tibble(expression = sTibble$expression,
                   sentimentF = sTibble$ave_sentiment)

rsTibble$sentimentF > 0
rsTibble$sentimentF < 0

maxSrst <- max(rsTibble$sentimentF)
minSrst <- min(rsTibble$sentimentF)

rsTibble$sentimentF[rsTibble$sentimentF > 0] <-
  round(4 * rsTibble$sentimentF[rsTibble$sentimentF > 0] / maxSrst) / 4

rsTibble$sentimentF[rsTibble$sentimentF < 0] <-
  round(4 * rsTibble$sentimentF[rsTibble$sentimentF < 0] / minSrst) / -4

sentimentrTibble <- rsTibble[!duplicated(rsTibble$expression),]

# Emotional
aTibble <- data.frame()

for(aTibbleIndex in 1:length(storeIdioms)) {
  aTibble <- rbind(aTibble,
                   tibble(expression = storeIdioms[[aTibbleIndex]]$expression,
                          defEx = paste(storeIdioms[[aTibbleIndex]]$expression,
                                        storeIdioms[[aTibbleIndex]]$definition,
                                        sep = ", ")))
}

emotionsTibble <- emotion(get_sentences(gsub("\\!",";",gsub("\\.",";",aTibble$defEx,))))
emotionsNoted <- c("anger", "anger_negated", "anticipation", "anticipation_negated", 
                   "disgust", "disgust_negated", "fear", "fear_negated",
                   "joy", "joy_negated", "sadness", "sadness_negated",
                   "surprise", "surprise_negated", "trust", "trust_negated")

anger = emotionsTibble$emotion_type == emotionsNoted[1]
anger_negated = emotionsTibble$emotion_type == emotionsNoted[2]
anticipation = emotionsTibble$emotion_type == emotionsNoted[3]
anticipation_negated = emotionsTibble$emotion_type == emotionsNoted[4]
disgust = emotionsTibble$emotion_type == emotionsNoted[5]
disgust_negated = emotionsTibble$emotion_type == emotionsNoted[6]
fear = emotionsTibble$emotion_type == emotionsNoted[7]
fear_negated = emotionsTibble$emotion_type == emotionsNoted[8]
joy = emotionsTibble$emotion_type == emotionsNoted[9]
joy_negated = emotionsTibble$emotion_type == emotionsNoted[10]
sadness = emotionsTibble$emotion_type == emotionsNoted[11]
sadness_negated = emotionsTibble$emotion_type == emotionsNoted[12]
surprise = emotionsTibble$emotion_type == emotionsNoted[13]
surprise_negated = emotionsTibble$emotion_type == emotionsNoted[14]
trust = emotionsTibble$emotion_type == emotionsNoted[15]
trust_negated = emotionsTibble$emotion_type == emotionsNoted[16]

emotionsLogic <- data.frame(
  anger,
  anger_negated,
  anticipation,
  anticipation_negated,
  disgust,
  disgust_negated,
  fear,
  fear_negated,
  joy,
  joy_negated,
  sadness,
  sadness_negated,
  surprise,
  surprise_negated,
  trust,
  trust_negated
)

strictEmotionsNoted <- c("anger", "anticipation", 
                         "disgust", "fear",
                         "joy", "sadness",
                         "surprise", "trust")
emotionsSelectIndex <- 1:length(strictEmotionsNoted)

token <- c()
d <- c()
for(elementIndex in 1:max(emotionsTibble$element_id)){
  overarchingLogic <- (emotionsTibble$element_id == elementIndex)
  
  currentAnger <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$anger] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$anger_negated]
  
  currentAnticipation <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$anticipation] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$anticipation_negated]
  
  currentDisgust <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$disgust] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$disgust_negated]
  
  currentFear <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$fear] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$fear_negated]
  
  currentJoy <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$joy] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$joy_negated]
  
  currentSadness <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$sadness] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$sadness_negated]
  
  currentSurprise <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$surprise] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$surprise_negated]
  
  currentTrust <- emotionsTibble$emotion[overarchingLogic&emotionsLogic$trust] -
    emotionsTibble$emotion[overarchingLogic&emotionsLogic$trust_negated]
  
  currentVector <- c(currentAnger, currentAnticipation, currentDisgust, currentFear, 
                     currentJoy, currentSadness, currentSurprise, currentTrust)
  
  currentMax <- max(currentVector)
  length(emotionsSelectIndex[currentVector==currentMax])
  
  if(currentMax > 0){
    token <- c(token,rep(aTibble$expression[elementIndex],
                         sum(currentVector==currentMax)))
    d <- c(d, strictEmotionsNoted[emotionsSelectIndex[currentVector==currentMax]])
  } else {
    token <- c(token, aTibble$expression[elementIndex])
    d <- c(d, "")
  }
}

#lexicon::hash_nrc_emotions
overallEmotionTibble <- tibble(token,
                               emotion = d)

finalEmotionTibble <- overallEmotionTibble[!duplicated(paste(overallEmotionTibble$token, overallEmotionTibble$emotion)),]


# Examples
# must have a word in between
str_match_all("he saved my bacon", "saved (\\w+) bacon")

# can have a word or no word
str_match_all("he saved bacon", "saved( \\w+ | )bacon")

# can have either my or his
str_locate_all("he saved my bacon", "saved (my|his) bacon")




View(finalEmotionTibble)

View(left_join(sentimentrTibble,overallEmotionTibble))







# Remove Contractions
library(textclean)
replace_contraction(finalEmotionTibble$expression, contraction.key = lexicon::key_contractions)







########## Experimentation
########################

## Other
levels(factor(lexicon::hash_nrc_emotions$emotion))


###### Important for discourse
library(tidytext)
#install.packages("textdata")

afinnEmotion <- get_sentiments("afinn")
bingEmotion <- get_sentiments("bing")
nrcEmotion <- get_sentiments("nrc")
colnames(nrcEmotion)[2]<-"sentiment_NRC"

cTibble <- data.frame(expression = c(), word = c(), value = c(), 
                      sentiment = c())


#data(stop_words)
#exceptions <- grep(pattern = "not|n't", x = stopwords(), value = TRUE)
#my_stopwords <- setdiff(stopwords("en"), exceptions)

for(cTibbleIndex in 1:length(storeIdioms)) {
  cTibble <- storeIdioms[[cTibbleIndex]] %>%
    unnest_tokens(word, definition) %>%
    #anti_join(stop_words) %>%
    left_join(afinnEmotion) %>%
    left_join(bingEmotion) %>%
    rbind(cTibble,.)
}


cTibble$value[is.na(cTibble$value)] <- 0
cTibble$sentiment[is.na(cTibble$sentiment)] <- ""

iTibble <- cTibble %>%
  group_by(expression) %>%
  mutate(overallValue = sum(na.omit(value),na.omit(sentiment=="positive"),-1*na.omit(sentiment=="negative")),
         expressionMax = max(na.omit(value)),
         expressionMin = min(na.omit(value))) %>%
  ungroup()

View(iTibble)

cA <- c(NA,NA)
paste(na.omit(cA), collapse = ", ")






# For inspiraton
#install.packages("janeaustenr")

library(gutenbergr)
library(janeaustenr)
library(dplyr)
library(stringr)

original_books_1 <- austen_books() %>%
  group_by(book) %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, 
                                     regex("^chapter [\\divxlc]",
                                           ignore_case = TRUE)))) %>%
  ungroup()


original_books_2 <- austen_books() %>%
  mutate(linenumber = row_number(),
         chapter = cumsum(str_detect(text, 
                                     regex("^chapter [\\divxlc]",
                                           ignore_case = TRUE))))


tidy_books <- original_books %>%
  unnest_tokens(word, text)

data(stop_words)

tidy_books <- tidy_books %>%
  anti_join(stop_words)

hgwells <- gutenberg_download(c(35, 36, 5230, 159))

tidy_hgwells <- hgwells %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words)

bronte <- gutenberg_download(c(1260, 768, 969, 9182, 767))

tidy_bronte <- bronte %>%
  unnest_tokens(word, text) %>%
  anti_join(stop_words)

tidy_hgwells %>%
  count(word, sort = TRUE)

tidy_bronte %>%
  count(word, sort = TRUE)

library(tidyr)

frequency <- bind_rows(mutate(tidy_bronte, author = "Brontë Sisters"),
                       mutate(tidy_hgwells, author = "H.G. Wells"), 
                       mutate(tidy_books, author = "Jane Austen")) %>% 
  mutate(word = str_extract(word, "[a-z']+")) %>%
  count(author, word) %>%
  group_by(author) %>%
  mutate(proportion = n / sum(n)) %>%
  select(-n) %>% #Spread out selected column with columns dictate by current groupings
  spread(author, proportion) %>%
  gather(author, proportion, `Brontë Sisters`:`H.G. Wells`) %>%
  ungroup()




# References
## https://rstudio.com/wp-content/uploads/2016/09/RegExCheatsheet.pdf
## https://towardsdatascience.com/web-scraping-tutorial-in-r-5e71fd107f32
## https://cran.r-project.org/web/packages/sentimentr/sentimentr.pdf
### Page 46