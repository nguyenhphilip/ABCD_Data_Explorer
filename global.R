sapply(c("shiny","dplyr", "purrr", "here", "readr"), require, character.only = TRUE)

abcd_instruments <- read.csv(here("abcd_instruments_v2.csv"), 
                                     row.names = NULL) %>% select(-X)

age_event_site <- readRDS(here("2.0-ABCD-Release-R-format", "ABCD Longitudinal Tracking.Rds"))
income_ed_bl <- readRDS(here("2.0-ABCD-Release-R-format", "ABCD Parent Demographics Survey.Rds"))
race_eth_family <- readRDS(here("2.0-ABCD-Release-R-format", "ABCD ACS Post Stratification Weights.Rds"))
income_ed_y1 <- readRDS(here("2.0-ABCD-Release-R-format", "ABCD Longitudinal Parent Demographics Survey.Rds"))

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
    for(file in list.files(here("2.0-ABCD-Release-R-format"))){
      for(spread in spreads){
        if(file == paste0(spread,".Rds")){
          df <- readRDS(here("2.0-ABCD-Release-R-format", file))
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
  return(all_vars)
}