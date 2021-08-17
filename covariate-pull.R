sapply(c("dplyr", "here", "readr", "janitor", "readxl"), require, character.only = TRUE)

# load codebook from Shana / Leigh-Anne

la_cb_demo <- read_xlsx("cb.xlsx", sheet = "Demo_covariates") %>% clean_names()

# make a function to check if variables match between codebook and actual datasets

check_vars <- function(var_list, dataset){
  for(i in var_list){
    if(i %in% names(dataset)){
      next;
    } else {
      print(paste(i, "not present"))
    }
  }
}

##########################################
###### DEMOGRAPHICS AND COVARIATES #######
##########################################

# create base database that all other sheets will merge onto

age_event_site <- read_csv(here("2-0and2-0-1", "ABCD Longitudinal Tracking.csv"))

income_ed_bl <- read_csv(here("2-0and2-0-1", "ABCD Parent Demographics Survey.csv"))

race_eth_family <- read_csv(here("2-0and2-0-1", "ABCD ACS Post Stratification Weights.csv"))

covariate_vars <- c("src_subject_id",
                    "eventname",
                    "interview_age", 
                    "demo_sex_v2", 
                    "demo_comb_income_v2",
                    "race_ethnicity", 
                    "demo_prnt_ed_v2", 
                    "demo_prtnr_ed_v2", 
                    "site_id_l", 
                    "rel_family_id",
                    "demo_prim")

covariates <- age_event_site %>% 
  full_join(income_ed_bl, by = c("src_subject_id","eventname")) %>%
  full_join(race_eth_family, by = c("src_subject_id", "eventname")) %>%
  select(covariate_vars) %>% 
  filter(eventname == "baseline_year_1_arm_1")

# convert specific columns from factor to numeric

cols.num <- c("interview_age",
              "demo_prim", 
              "demo_sex_v2", 
              "demo_prtnr_ed_v2", 
              "demo_prnt_ed_v2", 
              "demo_comb_income_v2")

# create highest ed house, highest ed categories, and combined income categories
covariates <- covariates %>% mutate(highest_ed_house = case_when(demo_prim > 4 ~ 0,
                                                                 demo_prnt_ed_v2 == 777 | demo_prnt_ed_v2 == 999 ~ 0,
                                                                 is.na(demo_prtnr_ed_v2) & is.na(demo_prnt_ed_v2) ~ 0,
                                                                 is.na(demo_prtnr_ed_v2) ~ demo_prnt_ed_v2,
                                                                 !is.na(demo_prnt_ed_v2) & demo_prtnr_ed_v2 == 777 | demo_prtnr_ed_v2 == 999 ~ demo_prnt_ed_v2,
                                                                 demo_prim < 5 & demo_prnt_ed_v2 > demo_prtnr_ed_v2 ~ demo_prnt_ed_v2,
                                                                 demo_prim < 5 & demo_prnt_ed_v2 < demo_prtnr_ed_v2 ~ demo_prtnr_ed_v2,
                                                                 demo_prim < 5 & demo_prnt_ed_v2 == demo_prtnr_ed_v2 ~ demo_prnt_ed_v2),
                                    highest_ed_category = case_when(highest_ed_house == 0 ~ 0,
                                                                    highest_ed_house < 13 ~ 1,
                                                                    highest_ed_house == 13 | highest_ed_house == 14 ~ 2,
                                                                    highest_ed_house > 14 & highest_ed_house < 18 ~ 3,
                                                                    highest_ed_house == 18 ~ 4,
                                                                    highest_ed_house > 18 & highest_ed_house < 22 ~ 5,
                                                                    highest_ed_house == 777 ~ 0),
                                    combined_income_cat = case_when(demo_comb_income_v2 == 999 ~ 0,
                                                                    demo_comb_income_v2 == 777 ~ 0,
                                                                    is.na(demo_comb_income_v2) ~ 0,
                                                                    demo_comb_income_v2 > 8 ~ 3,
                                                                    demo_comb_income_v2 > 6 ~ 2,
                                                                    demo_comb_income_v2 <= 6 ~ 1)) %>% clean_names()


# clear objects

remove("age_event_site","income_ed_bl","race_eth_family")

## DEV HISTORY Q

dhx <- read_csv(here("2-0and2-0-1//ABCD Developmental History Questionnaire.csv"))

dhx_vars <- la_cb_demo$element_name[2:39]

check_vars(dhx_vars, dhx)

dhx <- dhx %>% select(dhx_vars)

## Family history part 1 & 2

fhxp1_var <- la_cb_demo$element_name[42:51]

fhxp1 <- read_csv(here("2-0and2-0-1/ABCD Family History  Assessment Part 1.csv"))

check_vars(fhxp1_var, fhxp1)

fhxp1 <- fhxp1 %>% select(fhxp1_var)

sapply(fhxp1, class)

fhxp2_var <- la_cb_demo$element_name[54:62]

fhxp2 <- read_csv(here("2-0and2-0-1/ABCD Family History Assessment Part 2.csv"))

check_vars(fhxp2_var, fhxp2)

fhxp2 <- fhxp2 %>% select(fhxp2_var)

sapply(fhxp2, class)

## Parent self report ASEBA

asrs_vars <- la_cb_demo$element_name[97:118]

asrs <- read_csv(here("2-0and2-0-1/ABCD Parent Adult Self Report Scores Aseba (ASR).csv"))

check_vars(asrs_vars, asrs)

asrs <- asrs %>% select(asrs_vars)

sapply(asrs, class)

# parent diag interview DSM-5 background

dibf_vars <- la_cb_demo$element_name[121:138]

dibf <- read_csv(here("2-0and2-0-1/ABCD Parent Diagnostic Interview for DSM-5 Background Items Full (KSADS-5).csv"))

check_vars(dibf_vars, dibf)

dibf <- dibf %>% select(dibf_vars)

sapply(dibf, class)

# parent family env scale

fes_vars <- la_cb_demo$element_name[141:151]

fes <- read_csv(here("2-0and2-0-1/ABCD Parent Family Environment Scale-Family Conflict Subscale Modified from PhenX (FES).csv")) %>%
  filter(eventname == "baseline_year_1_arm_1")

check_vars(fes_vars, fes)

fes <- fes %>% select(fes_vars)

sapply(fes, class)

# parent med hx q

pmedx_vars <- la_cb_demo$element_name[154:156]

pmedx <- read_csv(here("2-0and2-0-1/ABCD Parent Medical History Questionnaire (MHX).csv"))

check_vars(pmedx_vars, pmedx)

pmedx <- pmedx %>% select(pmedx_vars)

# sum scores phys health parent

ssphp_vars <- la_cb_demo$element_name[159:162]

ssphp <- read_csv(here("2-0and2-0-1/ABCD Sum Scores Physical Health Parent.csv")) %>%
  filter(eventname == "baseline_year_1_arm_1")

check_vars(ssphp_vars, ssphp)

ssphp <- ssphp %>% select(ssphp_vars)

sapply(ssphp, class)
# sum scores phys health youth

ssphy_vars <- la_cb_demo$element_name[165:168]

ssphy <- read_csv(here("2-0and2-0-1/ABCD Sum Scores Physical Health Youth.csv")) %>%
  filter(eventname == "baseline_year_1_arm_1")

check_vars(ssphy_vars, ssphy)

ssphy <- ssphy %>% select(ssphy_vars)

sapply(ssphy, class)

### COVARIATE MERGE ###

demo_covariates <- covariates %>%
  left_join(dhx, by = c("src_subject_id","eventname")) %>%
  left_join(fhxp1, by = c("src_subject_id", "eventname")) %>%
  left_join(fhxp2, by = c("src_subject_id","eventname")) %>%
  left_join(asrs, by = c("src_subject_id", "eventname")) %>%
  left_join(dibf, by = c("src_subject_id","eventname")) %>%
  left_join(fes, by = c("src_subject_id", "eventname")) %>%
  left_join(pmedx, by = c("src_subject_id","eventname")) %>%
  left_join(ssphp, by = c("src_subject_id", "eventname")) %>%
  left_join(ssphy, by = c("src_subject_id","eventname"))

# create puberty average scores

demo_covariates <- demo_covariates %>% mutate(average_puberty = case_when(demo_sex_v2 == 1 & is.na(pds_y_ss_male_category) & !is.na(pds_p_ss_male_category) & is.na(pds_y_ss_female_category) & is.na(pds_p_ss_female_category) ~ pds_p_ss_male_category,
                                                                          demo_sex_v2 == 1 & !is.na(pds_y_ss_male_category) & is.na(pds_p_ss_male_category) & is.na(pds_y_ss_female_category) & is.na(pds_p_ss_female_category) ~ pds_y_ss_male_category,
                                                                          demo_sex_v2 == 2 & is.na(pds_y_ss_male_category) & is.na(pds_p_ss_male_category) & is.na(pds_y_ss_female_category) & !is.na(pds_p_ss_female_category) ~ pds_p_ss_female_category,
                                                                          demo_sex_v2 == 2 & is.na(pds_y_ss_male_category) & is.na(pds_p_ss_male_category) & !is.na(pds_y_ss_female_category) & is.na(pds_p_ss_female_category) ~ pds_y_ss_female_category,
                                                                          demo_sex_v2 == 2 & is.na(pds_y_ss_male_category) & is.na(pds_p_ss_male_category) & !is.na(pds_y_ss_female_category) & !is.na(pds_p_ss_female_category) ~ (pds_p_ss_female_category + pds_y_ss_female_category)/2,
                                                                          demo_sex_v2 == 1 & !is.na(pds_p_ss_male_category) & !is.na(pds_y_ss_male_category) & is.na(pds_y_ss_female_category) & is.na(pds_p_ss_female_category) ~ (pds_p_ss_male_category + pds_y_ss_male_category)/2
))


#handedness

la_cb_psy <- read_excel('cb.xlsx', sheet = "Psychiatric") %>% clean_names()

hand_vars <- la_cb_cog$element_name[36:38]

hand <- read_csv(here("2-0and2-0-1/ABCD Youth Edinburgh Handedness Inventory Short Form (EHIS).csv"))

check_vars(hand_vars, hand)

hand <- hand %>% select(hand_vars)


# mri info
old_cov <- read_csv(here("2.0-covars.csv"))
mri_info <- read_csv(here("2-0and2-0-1","ABCD MRI Info.csv"))
mri <- old_cov %>% left_join(mri_info, by = "src_subject_id") %>% select("src_subject_id","scanner_num","mri_info_deviceserialnumber")

# fMRI exists?

fmri <- read_csv(here("2.0-covars-with-imaging.csv")) %>% select("src_subject_id",contains("exists"))

covariate_final <- demo_covariates %>% 
  left_join(hand, by = c("src_subject_id","eventname")) %>%
  left_join(mri, by = c("src_subject_id")) %>%
  left_join(fmri, by = c("src_subject_id")) %>%
  select(covariate_vars, "ehi_y_ss_scoreb", "average_puberty", "highest_ed_category","combined_income_cat", "scanner_num", contains("exists")) %>%
  mutate(site_id_l = as.numeric(str_replace(site_id_l, "site", "")))

### ### ### ### ### ### ### ### ### #
# save current spread as a csv file #
write_csv(covariate_final, "2p0p1-covariates.csv", na = "")
### ### ### ### ### ### ### ### ### #
