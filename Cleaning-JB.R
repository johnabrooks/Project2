# Initialize libraries
## Standard
library(xlsx)
library(tidyr)
library(tidytext)
library(tidyverse)
library(dplyr)
library(stringr)

## Words list that includes variations of words (e.g. searched, searching, etc. for search)
# install.packages("qdapDictionaries")
library(qdapDictionaries)

## Translation 
# install.packages("googleLanguageR")
library(googleLanguageR)

# Load authorization
gl_auth("/Users/johnbrooks/Dropbox/Synced/Credentials/API/STAT 5702 - Text Translation-df0390ca10f9.json")

# https://cran.r-project.org/web/packages/googleLanguageR/vignettes/setup.html

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
  select(c("c_1","c_2",selectNames)) %>%
  
  # Pivot the data to be cataloged by ID and question index
  pivot_longer(selectNames,names_to = "column",values_to = "response")

# Prepare data for translation
forTranslation <- pivtData %>%
  
  # Take out french
  filter(c_2 == "FR") 

# Count Characters
counterChar <- 0
for(currentStr in forTranslation$response) {
  counterChar <- counterChar + str_length(currentStr)
}

# Translational functional block
## Commented out as running it too many time could mean $$$
## control + shift + C to activate / deactivate lines

# translationFeed <- forTranslation$response[!(forTranslation$response == "")]
# 
# translationFrame <- gl_translate(
#   t_string,
#   target = "en",
#   format = "text",
#   source = "fr",
#   model = "nmt"
# )
# 
# for (i in 2:length(translationFeed)){
#   if(i!=8){
#     translationEnFr <- gl_translate(
#       translationFeed[i],
#       target = "en",
#       format = "text",
#       source = "fr",
#       model = "nmt"
#     )
#   }
#   translationFrame <- rbind(translationFrame, translationEnFr)
# }
# 
# saveRDS(translationFrame,"frenchToEnglish.rds")

# How to read / write the file
# g <- readRDS("frenchToEnglish.rds")
# write.xlsx(g, "frenchToEnglish.xlsx")

# Prepare data for assessment
forProcessEng <- pivtData %>%
  
  # Take out french
  filter(c_2 == "EN") %>%
  
  # Get the responses into words
  unnest_tokens(word, response) %>%
  
  # Select the words column
  select(c("word")) %>%
  
  # Get the unique words
  unique()

# load the dictionary (one source)
wordVector <- qdapDictionaries::DICTIONARY$word

# comprehensive source
wordfile <- read.csv("/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2/words.txt",sep="\n")
wordsList <- tolower(wordfile$X2)

# detect if the isolate word appears in the English language
lengthProc <- nrow(forProcessEng)
isWord <- rep(FALSE,lengthProc)
for(currentIndex in 1:nrow(forProcessEng)) {
  isWord[currentIndex] <- as.character(forProcessEng[currentIndex,1]) %in%
    wordsList
}

# Create patterns to find initialisms
initialismPattern <- c(
  # Natural strings
  "\\b\\w+[[:upper:]]\\w+[[:upper:]]\\w+\\b",
  "\\b[[:upper:]]\\w+[[:upper:]]\\w+\\b",
  "\\b\\w+[[:upper:]]\\w+[[:upper:]]\\b",
  "\\b\\w+[[:upper:]][[:upper:]]\\w+\\b",
  "\\b[[:upper:]][[:upper:]]\\w+\\b",
  "\\b\\w+[[:upper:]][[:upper:]]\\b",
  "\\b[[:upper:]]\\w+[[:upper:]]\\b",
  "\\b[[:upper:]][[:upper:]]\\b",
  
  # Possessive strings
  "\\b\\w+[[:upper:]]\\w+[[:upper:]]\\w+\'s\\b",
  "\\b[[:upper:]]\\w+[[:upper:]]\\w+\'s\\b",
  "\\b\\w+[[:upper:]]\\w+[[:upper:]]\'s\\b",
  "\\b\\w+[[:upper:]][[:upper:]]\\w+\'s\\b",
  "\\b[[:upper:]][[:upper:]]\\w+\'s\\b",
  "\\b\\w+[[:upper:]][[:upper:]]\'s\\b",
  "\\b[[:upper:]]\\w+[[:upper:]]\'s\\b",
  "\\b[[:upper:]][[:upper:]]\'s\\b"
)

# Collapse the responses into one searchable string
responsesTogether <- paste(pivtData$response, collapse = "\n")

# Get the initialisms
listInitialisms <- unlist(str_extract_all(responsesTogether,initialismPattern)) %>%
  unique() %>%
  sort()

# For each initialism find where it was discovered
indexHold <- c()
respondsHold <- c()
for(initialismIndex in 1:length(listInitialisms)){
  currentResponses <- grep(listInitialisms[initialismIndex],pivtData$response)
  respondsHold <- c(respondsHold, currentResponses)
  indexHold <- c(indexHold, rep(initialismIndex,length(currentResponses)))
}

# Decode verification frame
verificationFrame <- data.frame(listInitialisms[indexHold],
                                pivtData$response[respondsHold])

# Write the verification fram to an excel file for ease of viewing
write.xlsx(verificationFrame,"initialsVerification.xlsx")

# Sort out the non-standard words
## Initialisms found
trueWords <- rbind(
  c("ABSB",""),
  c("ABSC",""),
  c("ABW",""),
  c("ACO",""),
  c("AEP",""),
  c("ALASD",""),
  c("AMA",""), # mega alert
  c("ATIPs",""), 
  c("BECC",""), 
  c("BGIS",""),
  c("BI",""), # alert
  c("BIQA",""),
  c("BLO",""), # alert
  c("BMC",""),
  c("CAPS",""),
  c("CAS",""),
  c("CERB",""),
  c("CESB",""),
  c("client reorgs",""),
  c("CNAS",""),
  c("CO",""), # Alert - find with "CO,"
  c("CoEs",""),
  c("COMSEC",""),
  c("CPB",""),
  c("CPB\'s",""),
  c("CPI",""),
  c("CPIs",""),
  c("CPSP",""),
  c("CSMD",""),
  c("CVB",""),
  c("DG","Director General"),
  c("DGs","Directors General"),
  c("DGFA",""), # French
  c("DGO",""),
  c("DGRH",""), # French
  c("DMC",""),
  c("DoF","Department of Finance"), #department of finance
  c("DSFA","Delegation of Spending and Financial Authority"),
  c("DTA",""),
  c("EA requests",""),
  c("EAP",""), #Careful as  appears in many words
  c("EBus",""),
  c("ECOTSO",""),
  c("EEs",""), #Careful as EEs 
  c("EPS project (Synergy replacement)",""),
  c("EPS projects",""),
  c("EUR",""),
  c("EFM",""),
  c("EFMS",""),
  c("FAB\'s",""),
  c("FAMF",""),
  c("FandA",""),
  c("F&A",""),
  c("FAMF",""),
  c("FAQ","Frequently Asked Quesions"),
  c("FIs",""), #alert
  c("FM"),
  c("FMA\'s",""),
  c("FMAs",""),
  c("FMAS",""),
  c("FMASD","Financial Management & Advisory Services Directorate"),
  c("FMASD\'s","Financial Management & Advisory Services Directorate's"),
  c("FMS","Financial Management System"),
  c("FORD program","TBS program for the development of Financial Officers FIs"),
  c("FORD","TBS program for the development of Financial Officers FIs"),
  c("FRAD",""),
  c("FRAD\'s",""),
  c("FTEs",""),
  c("GCSurplus",""),
  c("GCWCC",""),
  c("GLs",""),
  c("GS\'s",""),
  c("HRB",""),
  c("IAFCD",""),
  c("IBC",""),
  c("IBC\'s",""),
  c("ID\'s",""), #alert
  c("ISD",""), #alert
  c("ITB",""),
  c("ITB",""),
  c("ITSS",""),
  c("ITSSP",""),
  c("JVs",""),
  c("KRP\'s",""),
  c("MG1",""),
  c("MG1\'s",""),
  c("MG2",""),
  c("MG2\'s",""),
  c("MG3",""),
  c("MG4",""),
  c("MIFI",""),
  c("ML3",""),
  c("MyAccount",""),
  c("NFDC",""),
  c("NPSW",""),
  c("NPSW",""),
  c("OAG",""),
  c("OGD",""),
  c("OGD\'s",""),
  c("OGDs",""),
  c("P3",""),
  c("P6",""),
  c("P7",""),
  c("PAB",""), #alert
  c("PBF",""),
  c("PC\'s",""),
  c("PCCE",""),
  c("PMBOK",""),
  c("PMI",""),
  c("PMP",""),
  c("PO\'s",""),
  c("PPSL",""),
  c("PRINCE2",""),
  c("PSPC",""),
  c("PSPC",""),
  c("PSSDSG",""),
  c("RARAD",""),
  c("RARAD",""),
  c("RBA",""), #Alert
  c("RC02",""),
  c("RC02",""),
  c("RMC bootcamps",""),
  c("RMC",""),
  c("RMD","Resource Management Directorate"),
  c("RP",""), 
  c("RP1","Tenant Request for work"),
  c("RPA",""), #Alert
  c("RPRD\'s",""),
  c("RPSID","Real Property & Service Integration Directorate"),
  c("RR","respendable revenue"),
  c("RSCAD",""),
  c("SIAD","Security and Internal Affairs Directorate"),
  c("SIR\'s",""),
  c("SP 02",""),
  c("SP02",""),
  c("SP05",""),
  c("SP07",""),
  c("SP2",""),
  c("SP3",""),
  c("SP5",""),
  c("SP5s",""),
  c("TBS",""),
  c("TETSO",""),
  c("TETSO",""), 
  c("TNTSO",""),
  c("TSO\'s",""),
  c("TSOS",""),
  c("TWTSO","west?"),
  c("WFH",""),
  c("ZDFA_RPT",""),
  c("","")
)

## Words that were capitalized for emphasis
emphasisWords <- rbind(
  c("ALL the slack","extreme amounts of slack"),
  c("Merci BEAUCOUP!","Thank you very much!"),
  c("Admin staff have been present DAILY","consistently worked every day"),
  c("visited EVERY site regularly","consistently visited sites"),
  c("Doing the job correctly THE FIRST TIME","providing quality work initially"),
  c("","")
)

## Words that truly are english but were not detected as such
otherWords <- rbind(
  c("St Catharines",""),
  c("CFO\'s","Cheif Financial Officer's"),
  c("checkin\'s",""),
  c("commissionaires",""),
  c("ebizz",""),
  c("efax",""),
  c("emails",""),
  c("false",""),
  c("group\'s",""),
  c("infozone",""),
  c("lockdown",""),
  c("lockdowns",""),
  c("majorly",""),
  c("onsite","on-site"),
  c("proactively",""),
  c("proactiveness","proactive"),
  c("pushback","objections"),
  c("resourced","supplied"),
  c("respendable",""),
  c("Screensharing",""),
  c("stakeholders",""),
  c("team\'s",""),
  c("teleconferencing",""),
  c("voicemail",""),
  c("voip",""),
  c("webcam",""),
  c("webex",""),
  c("website",""),
  c("wiki",""),
  c("WIKI",""),
  c("Winfast",""),
  c("workaround",""),
  c("workflow",""),
  c("workflows",""),
  c("worksite","on-site"),
  c("www.deepl.com","")
  )

## Words that are english but are being used in a different way in the text
dualWords <- rbind(
  c("AD","Assistant Director"),
  c("AD\'s","Assistant Directors"),
  c("ADs",""),
  c("AC",""),
  c("FAB",""),
  c("FAM",""),
  c("FAD",""),
  c("FI",""),
  c("OR","Operating Revenue"),
  c("SIP",""),
  c("CRA","Canada Revenue Agency"),
  c("CRA\'s","Canada Revenue Agency's")
)

## Misspellings
misSpelled <- rbind(
  c("adminsitrave","administrative"),
  c("assesment","assessment"),
  c("beuracracy","bureaucracy"),
  c("carreer","career"),
  c("gliches","glitches"),
  c("clickets","clicks"),
  c("Clients\'s","client's"),
  c("Cluster\'s","clusters"),
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
  c("emial","email"),
  c("emapathy","empathy"),
  c("effrective","effective"),
  c("empath ","empathetic"),
  c("enthusiactic","enthusiastic"),
  c("excellente","excellent"),
  c("explaination","explanation"),
  c("finanace","finance"),
  c("back and forths","redundant communication"),
  c("inforamtion","information"),
  c("inperson","in person"),
  c("interfereing","interfering"),
  c("intrical","integral"),
  c("leavning","leaving"),
  c("managment","management"),
  c("persay",""), #just eliminate / extraneous
  c("nintey percent","90\%"),
  c("particualry","particularly"),
  c("perfer","prefer"),
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
  c("timefram","time frame"),
  c("timeframe","time frame"),
  c("timeframes","time frames"),
  c("timeline","time line"),
  c("timelines","time lines"),
  c("unintentially","unintentionally"),
  c("unprecedent","unprecedented")
)

## Words that added no meaning to the sentences
wordsForElimination <- rbind(
  c("\\bbuilding\'s\\b",""),
  c("\\bhttps://",""),
  c("\\b\\(IAR\\)\\b","")
)

## Words that may reasonably be subbed 
subWords <- rbind(
  c("actioned","addressed"),
  c("cellphone","phone"),
  c("cell phone","phone"),
  c("cellphones","phones"),
  c("cell phones","phones"),
  c("smartphone","phone"),
  c("smart phone","phone"),
  c("smartphones","phones"),
  c("smart phones","phones"),
  c("iphone","phone"),
  c("iphones","phones"),
  c("covid 19","covid"),
  c("covid-19","covid"),
  c("depts.","departments"),
  c("e.g","like"),
  c("doctor\'s","doctor"),
  c("Floorplan","floor plan"),
  c("admins","assistants"),
  c("admin ","assistant "),
  c("i.e.","like"),
  c("i.e","like"),
  c("I.T","information technology"),
  c("importants","important information"),
  c("inbox","mailbox"),
  c("googling","researching"),
  c("USERID\'s","names"),
  c("USERID","name"),
  c("JIRA","application 1"),
  c("WIKI","application 2"),
  c("Wiki","application 2"),
  c("Kahoot","application 3"),
  c("Kantech","application 4"),
  c("kinda","somewhat"),
  c("leaving them hanging",""),
  c("mailroom","mail room"),
  c("mastercard","credit"),
  c("Microsoft Office",""),
  c("Microsoft Outlook",""),
  c("Microsoft Teams",""),
  c("Microsoft teams",""),
  c("microsoft team",""),
  c("msteams",""),
  c("Microsoft Vista",""),
  c("na",""),
  c("onboarding","initiating"),
  c("cross boarding","transferring"),
  c("PowerPivot",""),
  c("powerpoint",""),
  c("PowerPoint",""),
  c("PowerQuery",""),
  c("Samsung smartphone","phone"), #usual reference is desire for iphone
  c("Samsung","phone"),
  c("IT ServiceDesk",""),
  c("SnagIT",""),
  c("SnipIt",""),
  c("staff\'s","subordinate's"),
  c("telecom","telephone companies"),
  c("teleworking","telecommuting"),
  c("telework","telecommuting"),
  c("how-to\'s","procedures"),
  c("touchpoints","interactions"),
  c("transferees within the organization","transferees"),
  c("unknows","uncertainty"),
  c("videoconferencing","teleconferencing"),
  c("webform","electronic form"),
  c("webinars","internet seminars"),
  c("widescreen","wider"),
  c("WiFI","wireless internet access"),
  c("WiFi","wireless internet access"),
  c("wifi","wireless internet access"),
  c("workplaces","work space"),
  c("thank you\'s","commendations")
)
str_replace_all(target,"\bacheived\b","achieved")

# See non-words
nonWords <- as.character(forProcessEng[!isWord,1]$word)
orderedNonWords <- nonWords[order(nonWords)]

# Replace terms
trueWords
otherWords
dualWords
misSpelled
subWords

# Extra
d <- "off toff staffed on the cuff ff (fford's), AoS AA"
str_replace_all(d,"\\(fford\'s\\)","gg")
str_replace_all(d,"\\bff","gg")



str_replace_all(d,initialismPattern,"")
