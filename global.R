sapply(c("shiny","dplyr", "purrr", "here", "readr", "data.table"), require, character.only = TRUE, lib.loc)

read_abcd_table <- function(t){
  a = read.table(file = t, sep = "\t", header = T, na.strings = c("", NA), colClasses = "character")[-1,]
  a = a[,!(names(a) %in% c("collection_id", "collection_title", "promoted_subjectkey", "subjectkey", "study_cohort_name", "dataset_id"))]
  if ("visit" %in% names(a)){
    a$eventname = a$visit
  }
  
inst_name = gsub("_id", "", colnames(a)[1])
  if (inst_name=="abcd_midabwdp201"){
    #both "abcd_midabwdp201" and "abcd_midabwdp01" have the same variables (same values), delete one;
    a = a[,!(names(a) %in% c("tfmri_mid_all_antic.large.vs.small.reward_beta_cort.destrieux_g.front.inf.orbital.rh","visit","interview_age","interview_date","gender"))]
  } else if (inst_name == "abcd_dmdtifp201"){ 
    #both abcd_dmdtifp101 and abcd_dmdtifp201 have the same variable, delete one;
    a = a[,!(names(a) %in% c("dmri_dtifull_visitid","visit","interview_age","interview_date","gender"))]
  } else if (inst_name != "abcd_lt01"){
    a = a[,!(names(a) %in% c("visit","interview_age","interview_date","gender", "sex"))] 
  }
  a = droplevels(a)
  return (a)
}

is_all_numeric <- function(x) {
  !any(is.na(suppressWarnings(as.numeric(na.omit(x))))) & is.character(x)
}

age_event_site_sex <- read_abcd_table(here("data", "abcd_lt01.txt")) # age, event, site, sex
income_ed_bl <- read_abcd_table(here("data", "abcd_lpds01.txt")) # household income, parent highest ed
race_eth_family <- read_abcd_table(here("data", "acspsw03.txt")) # race and ethnicity, family id
scanner <- read_abcd_table(here("data","abcd_mri01.txt"))  %>% mutate(scanner_num = group_indices(., mri_info_deviceserialnumber)) # scanner number

covariate_vars <- c("src_subject_id",
                    "eventname",
                    "sex",
                    "interview_age", 
                    "race_ethnicity",
                    "demo_comb_income_v2_l", 
                    "demo_prnt_ed_v2_l", 
                    "demo_prtnr_ed_v2_l", 
                    "site_id_l", 
                    "rel_family_id",
                    "scanner_num")

covariates <- age_event_site_sex %>% 
  full_join(income_ed_bl, by = c("src_subject_id","eventname")) %>%
  full_join(race_eth_family, by = c("src_subject_id", "eventname")) %>%
  full_join(scanner, by = c("src_subject_id","eventname")) %>%
  select(covariate_vars)

remove(list = c("age_event_site_sex", "income_ed_bl", "race_eth_family"))

createVars <- function(spreads){ #spreads = input$datasets
  all_vars <- c()
  for(file in list.files(here("data"))){
    for(spread in spreads){
      if(file == paste0(spread,".txt")){
        df <- read_abcd_table(here("data", file))
        for(variable in names(df)){
            all_vars[length(all_vars) + 1] <- variable
        }
      }
    }
  }
  return(all_vars)
}

myPaths <- .libPaths()
myPaths <- c(myPaths[2], myPaths[1])
myPaths <- c(myPaths, "C:/path/to/Package")
.libPaths(myPaths)