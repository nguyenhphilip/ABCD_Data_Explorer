sapply(c("shiny","dplyr", "purrr", "here"), require, character.only = TRUE)
measures_with_categories <- read.csv(here("2.0_NDA_Data","matched_and_categorized_measures_2.0.csv"), row.names = NULL)

index_remove <- c()
for(index in 1:length(measures_with_categories$NIMH_shortname)){
  if((gsub(".txt","",measures_with_categories$NIMH_shortname[index]) == "")){
    index_remove[length(index_remove)+1] <- index
  }
}
measures_with_categories <- measures_with_categories[-c(index_remove),]
unique_cats <- unique(measures_with_categories$category)

age_event_site <- read.csv(here("2.0_NDA_Data","Other Non-Imaging","ABCD Longitudinal Tracking.csv")) 
income_ed <- read.csv(here("2.0_NDA_Data","Mental Health", "ABCD Parent Demographics Survey.csv"))
income_ed_long <- read.csv(here("2.0_NDA_Data","Mental Health", "ABCD Longitudinal Parent Demographics Survey.csv"))

covariate_vars <- c("src_subject_id","eventname","interview_age", "demo_sex_v2","demo_gender_id_v2",
                    "demo_comb_income_v2", "demo_prnt_ed_v2", "demo_prtnr_ed_v2", "site_id_l")

covariates <- age_event_site %>% left_join(income_ed, by = c("src_subject_id","eventname"))

covariates <- covariates %>% left_join(income_ed_long, by = c("src_subject_id","eventname")) %>%
  select(covariate_vars)

createCSVS <- function(categories){
  all_csvs <- c()
  for(category in categories){
    if(length(categories) > 0){
      for(file in list.files(here("2.0_NDA_Data",category))){
        df <- (gsub(".csv", "", file))
        all_csvs[[length(all_csvs) + 1]] <- df
      }
    }
  }
  return(all_csvs)
}

createVars <- function(categories, spreads){ #spreads = input$datasets
  all_vars <- c()
  for(category in categories){
    for(file in list.files(here("2.0_NDA_Data",category))){
      for(spread in spreads){
        if(file == paste0(spread,".csv")){
          df <- read.csv(here("2.0_NDA_Data",category, file))
          for(variable in names(df)){
            if(variable %in% covariate_vars){
              next;
            } else {
              all_vars[length(all_vars) + 1] <- variable
            }
          }
        }
      }
    }
  }
  return(all_vars)
}