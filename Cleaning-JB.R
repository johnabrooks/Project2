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

# If you want to see the data 
# View(cleanData)

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

pathToOfflineFiles <- "/Users/johnbrooks/Dropbox/R_files/Users/johnbrooks/Dropbox/Synced/R/STAT 5702/Store"

if(!file.exists(paste(pathToOfflineFiles,"frenchToEnglish.rds",sep="/"))){
  translationFeed <- forTranslation$response[!(forTranslation$response == "")]
  
  translationFrame <- gl_translate(
    t_string,
    target = "en",
    format = "text",
    source = "fr",
    model = "nmt"
  )
  
  for (i in 2:length(translationFeed)){
    if(i!=8){
      translationEnFr <- gl_translate(
        translationFeed[i],
        target = "en",
        format = "text",
        source = "fr",
        model = "nmt"
      )
    }
    translationFrame <- rbind(translationFrame, translationEnFr)
  }
  
  # Save the feed 
  saveRDS(translationFrame,
          paste(pathToOfflineFiles,"frenchToEnglish.rds",sep="/"))
  write.xlsx(translationFrame, paste(pathToOfflineFiles,"frenchToEnglish",sep="/"))
} else {
  # How to read / write the file: just adjust the path
  translationFrame <- readRDS(paste(pathToOfflineFiles,"frenchToEnglish",sep="/"))
}

# Read in improved matrix
if(file.exists(paste(pathToOfflineFiles,"frenchToEnglishM.xlsx",sep="/"))){
  translationFrame <- 
    readxl::read_xlsx(paste(pathToOfflineFiles,"frenchToEnglishM.xlsx",sep="/"))
}

# Create master translated tibble
if(file.exists(paste(pathToOfflineFiles,"masterResponse.xlsx",sep="/"))){
forTranslation %>%
  filter(response != "") %>%
  mutate(english = translationFrame$translatedText) -> FrenchSegmentResponse

forTranslation %>%
  filter(response == "") %>% 
  mutate(english = "") -> FrenchSegmentNonResponse

pivtData %>%
  # Take out french
  filter(c_2 == "EN") %>%
  mutate(english = response) -> EnglishTibble

# Master Response
MasterResponse <- rbind(
  FrenchSegmentResponse,
  FrenchSegmentNonResponse,
  EnglishTibble
) %>% 
  arrange(c_1,c_2,column)

write.xlsx(MasterResponse, paste(pathToOfflineFiles,"masterResponse.xlsx",sep="/"))
} else {
  readxl::read_xlsx(paste(pathToOfflineFiles,"masterResponse.xlsx",sep="/"))
}



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

# Comprehensive source
wordfile <- read.csv("/Users/johnbrooks/Desktop/Course Work/STAT5702/Project2/words.txt",sep="\n")
wordsList <- tolower(wordfile$X2)

# Detect if the isolate word appears in the English language
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
  c("DGFA",""), # French
  c("DGO",""),
  c("DGRH",""), # French
  c("DGs","Directors General"),
  c("DMC",""),
  c("DoF","Department of Finance"), #department of finance
  c("DSFA","Delegation of Spending and Financial Authority"),
  c("DTA",""),
  c("EA requests",""),
  c("EAP",""), #Careful as  appears in many words
  c("EBus",""),
  c("ECOTSO",""),
  c("EEs",""), #Careful as EEs 
  c("EFM",""),
  c("EFMS",""),
  c("EPS project (Synergy replacement)",""),
  c("EPS projects",""),
  c("EUR",""),
  c("F&A",""),
  c("FAB\'s",""),
  c("FAMF",""),
  c("FAMF",""),
  c("FandA",""),
  c("FAQ","Frequently Asked Quesions"),
  c("FIs",""), #alert
  c("FM"),
  c("FMA",""),
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
  c("GC Docs",""),
  c("GCSurplus",""),
  c("GCWCC",""),
  c("GLs",""),
  c("GoC","Government of Canada"),
  c("GS",""),
  c("GS\'s",""),
  c("HQ","Headquarters"),
  c("HR","Human Resources"),
  c("HRB",""),
  c("IAFCD",""),
  c("IAFCD",""),
  c("IAM","Identity and Access Management"),
  c("IAR",""),
  c("IBC",""),
  c("IBC\'s",""),
  c("ICD",""),
  c("ID offices",""),
  c("ID","identification"),
  c("ID\'s",""), #alert
  c("IO",""),
  c("IPRT",""),
  c("ISD",""), #alert
  c("ISS",""), # Alert
  c("ITB",""),
  c("ITB",""),
  c("ITSS",""),
  c("ITSSP",""),
  c("JV",""),
  c("JVs",""),
  c("KRP",""),
  c("KRP\'s",""),
  c("LR",""),
  c("MERKS",""),
  c("MG1",""),
  c("MG1\'s",""),
  c("MG2",""),
  c("MG2\'s",""),
  c("MG3",""),
  c("MG4",""),
  c("MIFI",""),
  c("ML3",""),
  c("MP",""),
  c("MTS",""),
  c("MyAccount",""),
  c("NCR",""),
  c("NFDC",""),
  c("NPSW",""),
  c("NPSW",""),
  c("OAG",""),
  c("OGD",""),
  c("OGD\'s",""),
  c("OGDs",""),
  c("OHS",""),
  c("OPIs",""),
  c("P3",""),
  c("P6",""),
  c("P7",""),
  c("PAB",""), #alert
  c("PB",""),
  c("PBF",""),
  c("PCCE",""),
  c("PMA",""),
  c("PMBOK",""),
  c("PMI",""),
  c("PMP",""),
  c("PO",""),
  c("PO\'s",""),
  c("PPSL",""),
  c("PRINCE2",""),
  c("PSP",""),
  c("PSPC",""),
  c("PSPC",""),
  c("PSS",""),
  c("PSSDSG",""),
  c("RARAD",""),
  c("RBA",""), #Alert
  c("RC02",""),
  c("RC02",""),
  c("RFAS",""),
  c("RH",""), #French
  c("RI",""), #French
  c("RL Security helpdesk",""),
  c("RMC bootcamps",""),
  c("RMC",""),
  c("RMD","Resource Management Directorate"),
  c("RP",""), 
  c("RP1","Tenant Request for work"),
  c("RPA",""), #Alert
  c("RPRD",""),
  c("RPRD\'s",""),
  c("RPSA",""),
  c("RPSID","Real Property & Service Integration Directorate"),
  c("RR","respendable revenue"),
  c("RR","RR section for FMASD-CVB"),
  c("RSCAD",""),
  c("RTA",""),
  c("SACO",""),
  c("SAE",""), # French
  c("SD agents","Service Desk Agents"),
  c("ServiceDesk","Service Desk"),
  c("SIAD","Security and Internal Affairs Directorate"),
  c("SIR\'s",""),
  c("SLA",""),
  c("SOP","Standard Operating Procedure"),
  c("SOW",""),
  c("SP 02",""),
  c("SP",""),
  c("SP02",""),
  c("SP05",""),
  c("SP07",""),
  c("SP2",""),
  c("SP3",""),
  c("SP5",""),
  c("SP5s",""),
  c("SPC",""),
  c("SPS+",""),
  c("SRA",""),
  c("SRC",""),
  c("SSB",""),
  c("SSC",""),
  c("SW",""),
  c("TB",""), #Like TB used to have
  c("TBS",""),
  c("TC",""),
  c("TETSO",""),
  c("TETSO",""), 
  c("TI","Information Technology"), #French
  c("TL",""),
  c("TN-TSO","Toronto North TSO"),
  c("TNTSO",""),
  c("TOC","Transformation Oversight Committee"),
  c("TSO",""),
  c("TSO\'s",""),
  c("TSOS",""),
  c("TWTSO","west?"),
  c("USF",""), #French
  c("WFH",""),
  c("ZDFA_RPT","")
)

## Words that were capitalized for emphasis
emphasisWords <- rbind(
  c("\\(TRUE\\)",""),
  c("a BAD client service example",""),
  c("AD HOC","not formally planned"), # in a french translation 
  c("Admin staff have been present DAILY","consistently worked every day"),
  c("Advise them to STOP IT",""),
  c("ALL the slack","extreme amounts of slack"),
  c("better service MY clients",""),
  c("Doing the job correctly THE FIRST TIME",""),
  c("Doing the job correctly THE FIRST TIME","providing quality work initially"),
  c("if I sent a request to our admin to order that equipment that SHE WOULD",""),
  c("Merci BEAUCOUP!","Thank you very much!"),
  c("My team and I take client service VERY seriously",""),
  c("THANK YOU",""),
  c("THANKFUL",""),
  c("The system is NOT being utilized in an efficient way",""),
  c("visited EVERY site regularly","consistently visited sites"),
  c("WE want to be the best place for a client","")
)

## Words that truly are english but were not detected as such
otherWords <- rbind(
  c("CFO\'s","Cheif Financial Officer's"),
  c("checkin\'s",""),
  c("commissionaires",""),
  c("ebizz",""),
  c("efax",""),
  c("emails",""),
  c("false",""),
  c("group\'s",""),
  c("infozone",""),
  c("InfoZone",""),
  c("LAN","local area network"),
  c("lockdown",""),
  c("lockdowns",""),
  c("majorly",""),
  c("MSteam",""),
  c("MSTeams",""),
  c("NA",""),
  c("NOTE","note"),
  c("OK","okay"),
  c("ON","Ontario"),
  c("onsite","on-site"),
  c("PC","personal computer"),
  c("PC\'s","personal computers"),
  c("PDF",""),
  c("PEI","Prince Edward Island"),
  c("proactively",""),
  c("proactiveness","proactive"),
  c("PTSD","Post Traumatic Stress Disorder"),
  c("pushback","objections"),
  c("RAM","Random Access Memory"),
  c("RCMP","Royal Canadian Mounted Police"),
  c("resourced","supplied"),
  c("respendable",""),
  c("Screensharing",""),
  c("St Catharines",""),
  c("stakeholders",""),
  c("TEAM","Microsoft Teams"),
  c("team\'s",""),
  c("TEAMS","Microsoft Teams"),
  c("teleconferencing",""),
  c("voicemail",""),
  c("voip",""),
  c("VPN","Virtual Protective Network"),
  c("webcam",""),
  c("webex",""),
  c("website",""),
  c("wiki",""),
  c("WIKI",""),
  c("Winfast",""),
  c("WinFAST",""),
  c("WINFAST",""),
  c("workaround",""),
  c("workflow",""),
  c("workflows",""),
  c("worksite","on-site"),
  c("www.deepl.com","")
)

## Words that are english but are being used in a different way in the text
dualWords <- rbind(
  c("AC",""),
  c("AD","Assistant Director"),
  c("AD\'s","Assistant Directors"),
  c("ADs",""),
  c("CRA","Canada Revenue Agency"),
  c("CRA\'s","Canada Revenue Agency's"),
  c("FAB",""),
  c("FAD",""),
  c("FAM",""),
  c("FI",""),
  c("IT","Information Techology"),
  c("ITS",""),
  c("OR","Operating Revenue"),
  c("SAP",""),
  c("SIP","")
)

## Misspellings
misSpelled <- rbind(
  c("adminsitrave","administrative"),
  c("assesment","assessment"),
  c("back and forths","redundant communication"),
  c("beuracracy","bureaucracy"),
  c("carreer","career"),
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
  c("nintey percent","90\%"),
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
  c("admin ","assistant "),
  c("admins","assistants"),
  c("cell phone","phone"),
  c("cell phones","phones"),
  c("cellphone","phone"),
  c("cellphones","phones"),
  c("covid 19","covid"),
  c("covid-19","covid"),
  c("cross boarding","transferring"),
  c("depts.","departments"),
  c("doctor\'s","doctor"),
  c("e.g","like"),
  c("Floorplan","floor plan"),
  c("googling","researching"),
  c("how-to\'s","procedures"),
  c("i.e.","like"),
  c("i.e","like"),
  c("I.T","information technology"),
  c("IDEA","excel protocol"),
  c("importants","important information"),
  c("inbox","mailbox"),
  c("iphone","phone"),
  c("iphones","phones"),
  c("IT ServiceDesk",""),
  c("JIRA","application 1"),
  c("Kahoot","application 3"),
  c("Kantech","application 4"),
  c("kinda","somewhat"),
  c("KnowHow","application 5"),
  c("leaving them hanging",""),
  c("mailroom","mail room"),
  c("mastercard","credit"),
  c("Microsoft Office",""),
  c("Microsoft Outlook",""),
  c("microsoft team",""),
  c("Microsoft Teams",""),
  c("Microsoft teams",""),
  c("Microsoft Vista",""),
  c("MobiliKey",""),
  c("MS","Microsoft"),
  c("msteams",""),
  c("na",""),
  c("onboarding","initiating"),
  c("OneNote",""),
  c("PowerPivot",""),
  c("powerpoint",""),
  c("PowerPoint",""),
  c("PowerQuery",""),
  c("PPE","Personal Protective Equipment"),
  c("Samsung smartphone","phone"), #usual reference is desire for iphone
  c("Samsung","phone"),
  c("smart phone","phone"),
  c("smart phones","phones"),
  c("smartphone","phone"),
  c("smartphones","phones"),
  c("SnagIT",""),
  c("SnipIt",""),
  c("staff\'s","subordinate's"),
  c("telecom","telephone companies"),
  c("telework","telecommuting"),
  c("teleworking","telecommuting"),
  c("thank you\'s","commendations"),
  c("touchpoints","interactions"),
  c("transferees within the organization","transferees"),
  c("unknows","uncertainty"),
  c("USERID","name"),
  c("USERID\'s","names"),
  c("videoconferencing","teleconferencing"),
  c("webform","electronic form"),
  c("webinars","internet seminars"),
  c("What is the product number for XXX","What is the product number for this"),
  c("widescreen","wider"),
  c("WiFI","wireless internet access"),
  c("WiFi","wireless internet access"),
  c("wifi","wireless internet access"),
  c("WIKI","application 2"),
  c("Wiki","application 2"),
  c("workplaces","work space")
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
