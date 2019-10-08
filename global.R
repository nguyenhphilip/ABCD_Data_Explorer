sapply(c("shiny","dplyr", "purrr", "here", "readr"), require, character.only = TRUE)

age_event_site <- readr::read_csv(here("2.0-ABCD-Release-updated", "ABCD Longitudinal Tracking.csv"))
income_ed_bl <- readr::read_csv(here("2.0-ABCD-Release-updated", "ABCD Parent Demographics Survey.csv"))
race_eth_family <- readr::read_csv(here("2.0-ABCD-Release-updated", "ABCD ACS Post Stratification Weights.csv"))
income_ed_y1 <- readr::read_csv(here("2.0-ABCD-Release-updated", "ABCD Longitudinal Parent Demographics Survey.csv"))

covariate_vars <- c("src_subject_id",
                    "eventname",
                    "interview_age", 
                    "demo_sex_v2",
                    "race_ethnicity",
                    "demo_comb_income_v2", 
                    "demo_prnt_ed_v2", 
                    "demo_prtnr_ed_v2", 
                    "site_id_l", 
                    "rel_family_id")

covariates <- age_event_site %>% 
  full_join(income_ed_bl, by = c("src_subject_id","eventname")) %>%
  full_join(race_eth_family, by = c("src_subject_id", "eventname")) %>%
  full_join(income_ed_y1, by = c("src_subject_id","eventname")) %>%
  select(covariate_vars)

remove(list = c("age_event_site", "income_ed_bl", "race_eth_family", "income_ed_y1"))

createVars <- function(spreads){ #spreads = input$datasets
  all_vars <- c()
  for(file in list.files(here("2.0-ABCD-Release-updated"))){
    for(spread in spreads){
      if(file == paste0(spread,".csv")){
        df <- read_csv(here("2.0-ABCD-Release-updated", file))
        for(variable in names(df)){
            all_vars[length(all_vars) + 1] <- variable
        }
      }
    }
  }
  return(all_vars)
}
