library(dplyr)
library(skimr)
library(purrr)
release_names_nda <- read.csv("2.0Release_Sheetnames_from_NDA.csv")
spread_short_names <- release_names_nda$ShortNameNDA

local_short_names <- data.frame(list.files(pattern = ".txt"))

colnames(local_short_names)[1] <- "local_shortname"
local_short_names$local_shortname <- gsub(".txt","", local_short_names$local_shortname)

local_short_names$NIMH_shortname <- release_names_nda$ShortNameNDA[match(local_short_names$local_shortname, release_names_nda$ShortNameNDA)]
local_short_names$measure_name <- release_names_nda$Measure[match(local_short_names$local_shortname, release_names_nda$ShortNameNDA)]
local_short_names$category <- release_names_nda$Category[match(local_short_names$local_shortname, release_names_nda$ShortNameNDA)]
local_short_names$category <- as.factor(local_short_names$category)

local_short_names <- local_short_names %>% 
  mutate(local_matches_NDAshortname = case_when(!is.na(release_names_nda$ShortNameNDA[match(local_short_names$local_shortname, release_names_nda$ShortNameNDA)]) ~ "Yes",
                                                is.na(release_names_nda$ShortNameNDA[match(local_short_names$local_shortname, release_names_nda$ShortNameNDA)]) ~ "No")
  )

View(local_short_names)

write.csv(local_short_names %>% arrange(category), "matched_and_categorized_measures_2.0.csv", na = "")

##### BIG FILE MERGE -------- <- <- <- <- <- <- 

Alexi_vars <- read.csv("variable names in 1 year analyses ASP notes.csv")

local_files <- (gsub(".txt", "", list.files(pattern = ".txt")))

not_in_local <- list()

for(file in (Alexi_vars$Textfile.Name)) {
  if(file %in% local_files){
    next;
  } else {
    print(file)
  }
}

text_files <- list()
for(file in unique(Alexi_vars$Textfile.Name)){
  if(file %in% local_files){
    text_files[[length(text_files) + 1]] <- paste0("/Users/phil/Desktop/ABCD/2.0NDA/",file, ".txt")
  } else {
    print(paste(file, "is not here ***"))
  }
}


csv_files <- lapply(text_files, function(i){
  a <- read.csv(i, 
                sep = "\t", header = TRUE, row.names=NULL, check.names=FALSE, quote = "", comment.char = "")
  a = as.data.frame(sapply(a, function(x) gsub("\"", "", x)))
  names(a) = as.list(sapply(names(a), function(x) gsub("\"","",x)))
  a
})

for(p in 1:length(csv_files)){
  dt = csv_files[[p]]
  dt = dt[-1,]
  dt = droplevels(dt)
  csv_files[[p]] = dt
}

for (p in 1:length(csv_files)) {
  dt = csv_files[[p]]
  dt = droplevels(dt)
  csv_files[[p]] = dt
}

csv_files[[2]] %>% glimpse()

reduced_files_left <- csv_files %>% reduce(left_join, by = c("src_subject_id","gender","eventname"))
reduced_files_full <- csv_files %>% reduce(full_join, by = c("src_subject_id","gender","eventname"))

Alexi_select <- as.character(Alexi_vars$Variable.Name)

Alexi_left <- reduced_files_left %>% select(Alexi_select)
Alexi_full <- reduced_files_full %>% select(Alexi_select)
