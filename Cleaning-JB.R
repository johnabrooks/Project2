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

# control + shift + C to activate / deactivate lines
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

g <- readRDS("frenchToEnglish.rds")

write.xlsx(g, "frenchToEnglish.xlsx")


### process every "value

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

#wordsList
#write.xlsx(wordsList,"/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2/words.xlsx")

trueWords <- rbind(
  c("RARAD",""),
  c("ITB",""),
  c("ABSB",""),
  c("CVB",""),
  c("RMC",""),
  c("CAS",""),
  c("RC02",""),
  c("ABSC",""),
  c("AEP",""),
  c("P3",""),
  c("ATIPs",""), 
  c("ALASD",""),
  c("EBus",""),
  c("GCSurplus",""),
  c("RP",""), 
  c("BGIS",""),
  c("PSPC",""),
  c("TETSO",""), 
  c("BECC",""), 
  c("BIQA",""),
  c("CPB\'s",""),
  c("BMC",""),
  c("DMC",""),
  c("DGs",""),
  c("RMC bootcamps",""),
  c("CERB",""),
  c("CESB",""),
  c("TBS",""),
  c("FIs",""), #alert
  c("CPIs",""),
  c("CPSP",""),
  c("CSMD",""),
  c("DSFA","Delegation of Spending and Financial Authority"),
  c("DTA",""),
  c("EAP",""), #Careful as  appears in many words
  c("ECOTSO",""),
  c("EEs",""), #Careful as EEs 
  c("EFM",""),
  c("EFMS",""),
  c("FORD program","TBS program for the development of Financial Officers FIs"),
  c("FORD","TBS program for the development of Financial Officers FIs"),
  c("DoF","Department of Finance"), #department of finance
  c("FAB\'s",""),
  c("FAMF",""),
  c("FandA",""),
  c("FMASD\'s","Financial Management & Advisory Services Directorate's"),
  c("FMASD","Financial Management & Advisory Services Directorate"),
  c("FMAs",""),
  c("FMAS",""),
  c("FMA\'s",""),
  c("FRAD\'s",""),
  c("FRAD",""),
  c("FTEs",""),
  c("GCWCC",""),
  c("NPSW",""),
  c("GLs",""),
  c("GS\'s",""),
  c("HRB",""),
  c("IAFCD",""),
  c("IBC",""),
  c("IBC\'s",""),
  c("ZDFA_RPT",""),
  c("ID\'s",""), #alert
  c("ISD",""), #alert
  c("ITB",""),
  c("ITSSP",""),
  c("ITSS",""),
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
  c("OAG",""),
  c("OGD",""),
  c("OGDs",""),
  c("OGD\'s",""),
  c("P6",""),
  c("P7",""),
  c("PAB",""), #alert
  c("PBF",""),
  c("PC\'s",""),
  c("PCCE",""),
  c("PMBOK",""),
  c("PMI",""),
  c("PMP",""),
  c("PRINCE2",""),
  c("PO\'s",""),
  c("PPSL",""),
  c("PSSDSG",""),
  c("PSPC",""),
  c("RARAD",""),
  c("RBA",""), #Alert
  c("RC02",""),
  c("client reorgs",""),
  c("RR","respendable revenue"),
  c("RMD","Resource Management Directorate"),
  c("RP1","Tenant Request for work"),
  c("RPA",""), #Alert
  c("RPRD\'s",""),
  c("RPSID","Real Property & Service Integration Directorate"),
  c("RSCAD",""),
  c("SIR\'s",""),
  c("SIAD","Security and Internal Affairs Directorate"),
  c("SP 02",""),
  c("SP02",""),
  c("SP2",""),
  c("SP05",""),
  c("SP5",""),
  c("SP5s",""),
  c("SP07",""),
  c("SP3",""),
  c("TETSO",""),
  c("TNTSO",""),
  c("TSO\'s",""),
  c("TSOS",""),
  c("TWTSO","west?"),
  c("WFH",""),
  c("","")
)

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

dualWords <- rbind(
  c("AD","Assistant Director"),
  c("AD\'s","Assistant Directors"),
  c("AC",""),
  c("FAB",""),
  c("OR","Operating Revenue"),
  c("SIP",""),
  c("CRA","Canada Revenue Agency"),
  c("CRA\'s","Canada Revenue Agency's")
)

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

wordsForElimination <- rbind(
  c("\\bbuilding\'s\\b",""),
  c("\\bhttps://",""),
  c("\\b\\(IAR\\)\\b","")
)

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
d <- "off toff staffed on the cuff ff (fford's)"
str_replace_all(d,"\\(fford\'s\\)","gg")
str_replace_all(d,"\\bff","gg")
