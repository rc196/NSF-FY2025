
options(java.parameters = "- Xmx4096m")
library("tidyverse")
library("readxl")
library("writexl")
library("RODBC")
library("rlist")
library("gdata")
setwd("C:/Users/rchan/Box/IRAP Shared/Data Usage and Reporting/Research/NSF/FY2024/")

# READ SQL FILE TO CREATE SPONSOR LOOKUP TABLE #################################
# Changed this to an excel file so we don't have to run it every single time
#query1 <- read_file("SponsorLookupTbl.sql")
#cnxn <- odbcConnect("dwp04_aws", uid = "rchan", pwd = "")
#sponsor_lookup <- sqlQuery(cnxn,query1) %>% mutate_if(is.factor, as.character) %>% as_tibble()

#This maps sponsors to federal agency abbreviations as defined in REMS, because agency is not part of the financial data
sponsor_lookup <- read_excel("Data/sponsorcd-to-agency.xlsx") %>% as_tibble()

#This maps the agency abbreviation to the full description that NSF wants
agency_xw <- read_excel("Data/sponsors-to-funding.xlsx", sheet = "spon_agcy_shrt") %>% as_tibble()

#This remaps the FFRDCs into their respective federal agencies, because they are classified in REMS as non-federal. It also maps the local/state sponsors into state/local government, because they are "other" in the REMS system
sponsor_xw <- read_excel("Data/sponsors-to-funding.xlsx", sheet = "sponsor_id") %>% as_tibble()

#This uses data from campuses to map departments to NSF codes
departments <- read_excel("Data/departments-to-nsf.xlsx", sheet = "departments") %>% as_tibble()

#This uses data from campuses to map by award code to NSF code
awards <- read_excel("Data/awards-to-nsf.xlsx", sheet = "awards") %>% as_tibble()

#This is a mapping of NSF codes to their descriptions
nsf_xw <- read_excel("Data/departments-to-nsf.xlsx", sheet = "nsf_xw") %>% as_tibble()

#This rolls up the funding source category into the broad NSF categories
funding_xw  <- read_excel("Data/sponsors-to-funding.xlsx", sheet = "funding_source_category") %>% as_tibble()

#Maps clinical trials by department, based on campus data
clinical_xw_dept <- read_excel("Data/clinical-trials.xlsx", sheet = "department") %>% as_tibble()

#Maps clinical trials by project, based on campus data
clinical_xw_proj <- read_excel("Data/clinical-trials.xlsx", sheet = "project") %>% as_tibble()

#Indirect cost rates
icr_ccoa <- read_excel("Data/Input-icr.xlsx", sheet = "Sheet2") %>% as_tibble()
sicr_ccoa <- read_excel("Data/Input-sicr.xlsx",sheet="Campuses_CCOA") %>% as_tibble()

#Cost sharing
cost_sharing <- read_excel ("Data/cost-share.xlsx") %>% as_tibble()

#The proportion of awards by category of research, used to prorate the research expenditures
award_category <- read_excel("Data/FY2024-awards.xlsx") %>% as_tibble()
award_category<-rename(award_category,location=LOCATION,federal_sponsorship=FEDERAL_SPONSORSHIP,project_category=PROJECT_CATEGORY)
award_category[is.na(award_category)] <- ""

#UCSD exclusions
ucsd_excl_dept <- read_excel("Data/ucsd-exclude.xlsx", sheet = "departments") %>% as_tibble()
ucsd_excl_award <- read_excel("Data/ucsd-exclude.xlsx", sheet = "awards") %>% as_tibble()





# This will use an ODBC connection for AWS FDW
exp_query <- read_file("Research_Expenditures_CCOA.sql")
awscnxn <- odbcConnect("AWS FDW")

#The true, true...is to make sure character doesn't get converted to numeric
#expenditures_raw <- sqlQuery(awscnxn,exp_query,as.is=c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE))



expenditures_raw <- sqlQuery(awscnxn,exp_query,as.is=c(TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,TRUE,FALSE,FALSE,FALSE,TRUE))



expenditures_ccoa<-expenditures_raw %>%  as_tibble()
expenditures_ccoa$fiscal_year<-2025

# UCSD Exclusions
expenditures_ccoa <- left_join(expenditures_ccoa, ucsd_excl_dept, by = c('location','department_id')) 
expenditures_ccoa <- left_join(expenditures_ccoa, ucsd_excl_award, by = c('location','award_id')) 

expenditures_ccoa <-filter(expenditures_ccoa, is.na(award_exclude)==TRUE)
expenditures_ccoa <-filter(expenditures_ccoa, is.na(department_exclude)==TRUE)

# FIX MISSING DISCIPLINES WITH SUPPLEMENTAL CAMPUS DATA
expenditures_ccoa <- left_join(expenditures_ccoa, awards, by = c('location','award_id')) %>% mutate(nsf_id = ifelse(nsf_id == '' & is.na(nsf_id_award) == FALSE, nsf_id_award, nsf_id)) %>% select(-nsf_id_award)
expenditures_ccoa <- left_join(expenditures_ccoa, departments, by = c('location','department_id')) 
expenditures_ccoa <- mutate(expenditures_ccoa, nsf_id = ifelse( is.na(nsf_id_department) == FALSE, nsf_id_department, nsf_id)) %>% select(-nsf_id_department)
expenditures_ccoa <- left_join(expenditures_ccoa, nsf_xw, by = c('nsf_id')) 

#Identify clinical trials
expenditures_ccoa$project_id <- str_trim(expenditures_ccoa$project_id)
expenditures_ccoa <- left_join(expenditures_ccoa, clinical_xw_dept, by = c('location','department_id')) 
expenditures_ccoa <- left_join(expenditures_ccoa, clinical_xw_proj, by = c('location','project_id')) %>% mutate(clinical_trial=ifelse(is.na(clinical_trial_proj)==TRUE,clinical_trial_dept, clinical_trial_proj)) %>%select(-clinical_trial_proj,clinical_trial_dept)

#Change funding source category for FFRDCs, local gov, etc.
expenditures_ccoa <- left_join(expenditures_ccoa, sponsor_lookup, by = c("sponsor_id" = "SPON_CD"))
expenditures_ccoa <- left_join(expenditures_ccoa, agency_xw, by = c('SPON_AGCY_SHRT_NAM')) %>% mutate(funding_source = ifelse(is.na(funding_source_agency) == FALSE, funding_source_agency, funding_source)) 
expenditures_ccoa <- left_join(expenditures_ccoa, sponsor_xw, by = c('sponsor_id')) %>% mutate(funding_source = ifelse(is.na(funding_source_sponsor) == FALSE, funding_source_sponsor, funding_source)) 
expenditures_ccoa <- left_join(expenditures_ccoa, funding_xw, by = c('funding_source')) 

#cost share
expenditures_ccoa <- left_join(expenditures_ccoa, cost_sharing, by = c('location','project_id'))

# UPDATE FEDERAL SPONSORSHIP INDICATOR BASED ON SPONSOR LOOKUP UPDATES #################################
expenditures_ccoa <- mutate(expenditures_ccoa, federal_sponsorship = 
                              case_when(funding_source=='FEDERAL_UNCLASSIFIED'|
                                          !is.na(funding_source_agency)|
                                          (!is.na(funding_source_sponsor)&funding_source_sponsor!='GOVERNMENT_STATE/LOCAL')~ 'Y'))



# OUTPUT TABLE WITH UNCLASSIFIED FEDERAL SPONSOR INFORMATION TO REVIEW FOR ANY NEW SPONSORS THAT SHOULD BE CLASSIFIED ABOVE #################################
#federal_unclass <- filter(expenditures_ccoa, funding_source=='FEDERAL_UNCLASSIFIED')
#write_xlsx(federal_unclass,"Data/federal_unclassified_dtl.xlsx")


# CREATE EXPENDITURES TABLE BY LEFT-JOINING the DEPARTMENTS, ICR, AND SICR TABLES TO FILTERED expenditures_ccoa TABLE #################################

expenditures <- left_join(expenditures_ccoa,icr_ccoa, by = c('fiscal_year','location')) 
expenditures <- left_join(expenditures,sicr_ccoa, by = c('fiscal_year','location','department_id')) 



#create missing discipline subset
missing_disciplines <- filter(expenditures, is.na(nsf_discipline)==TRUE)
missing_disciplines<-select(missing_disciplines,-c('campus_source','Discipline','SPON_AGCY_CD','SPON_AGCY_NAM','SPON_AGCY_SHRT_NAM','funding_source_agency',
                                           'sponsor_name_ref','spon_alt_name','ICR','OICR','department','clinical_trial_dept','funding_source_sponsor'))

#missing_disciplines<-missing_disciplines[1:40]

x <-sum(missing_disciplines$direct)

expenditures <- filter(expenditures, is.na(nsf_discipline)==FALSE)

# ADD CALCULATED FINANCIAL VARIABLES TO EXPENDITURES TABLE AND THEN REMOVE MTDC and ICR, OICR, ETC RATES FROM TABLE 
expenditures <- mutate(expenditures, indirect = case_when(supplemental_flag=='Y' & location=='Irvine' ~ 0,
                                                          account_level_b_code=='40840B' ~ 0,
                                                          funding_source != 'INSTITUTIONAL' & on_off_campus == '1' & SICR>0 ~ mtdc * SICR, 
                                                          funding_source != 'INSTITUTIONAL' & on_off_campus == '2' & SOICR>0 ~ mtdc * SOICR,
                                                          funding_source != 'INSTITUTIONAL' & on_off_campus == '1' ~ mtdc * ICR, 
                                                          funding_source != 'INSTITUTIONAL' & on_off_campus == '2' ~ mtdc * OICR,
                                                          TRUE ~ 0)) %>% 
                                                          mutate(funded_amount = direct + reimbursement, unrecovered_amount = indirect - reimbursement, total_amount = direct + indirect)


expenditures<- expenditures %>% mutate_if(is.character,~replace_na(.,""))

#Adjust funding source categories or disciplines in expenditures table to eliminate negative amounts for unique
#location/discipline/funding source combinations. Convert funding source to INSTITUTIONAL if it results in a nonnegative 
#sum, else convert discipline to I1-Other Sciences in records associated with combination.

# Commenting out this entire negative adjustment thing because it might create more problems than it solves


expenditures_adjustment <- left_join((group_by(expenditures, fiscal_year, location, nsf_discipline, funding_source_category) %>%
      summarize(funded_sum = mean(funded_amount)*n(), .groups = 'keep')), (group_by(expenditures, fiscal_year, location, nsf_discipline) %>%
      summarize(unrecovered_sum = mean(unrecovered_amount*n()), .groups = 'keep')), by = c('fiscal_year','location','nsf_discipline'))
expenditures_adjustment <- mutate(expenditures_adjustment, amount = ifelse(funding_source_category == 'INSTITUTIONAL', funded_sum + unrecovered_sum, funded_sum)) %>%
      select(1:4,7)
expenditures_adjustment <- mutate(expenditures_adjustment, amount = round(amount/1000)) %>% left_join((filter(expenditures_adjustment, funding_source_category == 'INSTITUTIONAL') %>%
      group_by(fiscal_year, location, nsf_discipline) %>%
      summarize(amount2 = round(mean(amount)*n()/1000), .groups = 'keep')), by = c('fiscal_year','location','nsf_discipline')) %>%
      left_join((filter(expenditures_adjustment, nsf_discipline == 'I1-Other Sciences') %>%
      group_by(fiscal_year, location, funding_source_category) %>%
      summarize(amount3 = round(mean(amount)*n()/1000), .groups = 'keep')), by = c('fiscal_year','location','funding_source_category')) %>%
      filter(amount < 0 ) %>% mutate(nsf_discipline_adj = ifelse(amount2 + amount < 0, 'Y', 'N' )) %>%
      mutate(funding_source_category_adj = ifelse(amount2 + amount < 0, 'N', 'Y')) %>% select(1:4,8,9)

expenditures <- left_join(expenditures, expenditures_adjustment, by = c('fiscal_year','location','nsf_discipline','funding_source_category')) %>%
    mutate(nsf_discipline_adj = ifelse(is.na(nsf_discipline_adj), 'N', nsf_discipline_adj),
    funding_source_category_adj = ifelse(is.na(funding_source_category_adj), 'N', funding_source_category_adj))
expenditures <- mutate(expenditures, nsf_discipline = ifelse(nsf_discipline_adj == 'Y', 'I1-Other Sciences', nsf_discipline),
    federal_sponsorship = ifelse(funding_source_category_adj == 'Y', '', federal_sponsorship),
    funding_source_category = ifelse(funding_source_category_adj == 'Y', 'INSTITUTIONAL', funding_source_category),
    funding_source = ifelse(funding_source_category_adj == 'Y', 'INSTITUTIONAL', funding_source))
expenditures <- mutate(expenditures, nsf_discipline_adj = ifelse(is.na(nsf_discipline_adj), 'N', nsf_discipline_adj),
    funding_source_category_adj = ifelse(is.na(funding_source_category_adj), 'N', funding_source_category_adj))


#Logic to exclude expenditures that Berkeley said to exclude
bk_exclude <- read_excel("Data/BK exclude.xlsx", sheet = "BK-Exclude") %>% as_tibble() 
bk_exclude[is.na(bk_exclude)] <- ""

#Only run this for Berkeley
#expenditures <- left_join(expenditures,bk_exclude,by=c('fund_level_d_code','account_level_e_code','project_id','department_id','function_id'))%>%filter(is.na(exclude))




#Create expenditures_summary table for unique location/source category/discipline combinations.
#
expenditures_summary <- full_join((group_by(expenditures, location, nsf_discipline, funding_source_category) %>% summarize(funded_sum = mean(funded_amount)*n(), .groups = 'keep')), (group_by(expenditures, location, nsf_discipline, funding_source_category) %>% mutate(funding_source_category='INSTITUTIONAL')%>% summarize(unrecovered_sum = mean(unrecovered_amount*n()), .groups = 'keep')), by = c('location','nsf_discipline','funding_source_category')) %>% replace(is.na(.),0)%>%mutate(amount = ifelse( funding_source_category == 'INSTITUTIONAL', round((funded_sum + unrecovered_sum)/1000), round(funded_sum/1000))) 





## this will create a table with all of the disciplines that should be captured for institutional column in Q11 (can compare to the above summary table to identify where there is missing data )
expenditures_summary3 <- (group_by(expenditures, location, nsf_discipline) %>% summarize(unrecovered_sum = mean(unrecovered_amount*n()), .groups = 'keep'))

#Create expenditures_summary2 table for unique location/minor federal source combinations.
#
expenditures_summary2 <- filter(expenditures, funding_source_category == 'FEDERAL_OTHER' & funding_source != 'FEDERAL_UNCLASSIFIED') %>% group_by(location, funding_source) %>% summarize(amount = mean(funded_amount)*n(), .groups = 'keep') %>% filter(amount > 0)

#write_xlsx(expenditures_summary,"Data/expenditures_summary.xlsx")
#write_xlsx(expenditures,"Data/expenditures.xlsx")
#write_xlsx(missing_disciplines,"Data/missing_disciplines.xlsx")


n_distinct(expenditures$department)



expenditures_clean<-select(expenditures,-c('campus_source','Discipline','SPON_AGCY_CD','SPON_AGCY_NAM','SPON_AGCY_SHRT_NAM','funding_source_agency',
                                     'sponsor_name_ref','spon_alt_name','ICR','OICR','nsf_discipline_adj','funding_source_category_adj','department','clinical_trial_dept','funding_source_sponsor'))




exp_projects_fed <- select(expenditures_clean,c('location','federal_sponsorship','funded_amount')) %>% 
  filter(federal_sponsorship=='Y')%>%
  group_by(location,federal_sponsorship) %>% 
  summarize(amount = mean(funded_amount)*n(), .groups = 'keep') 

  
exp_projects_nonfed <- select(expenditures_clean,c('location','federal_sponsorship','total_amount')) %>% 
  filter(federal_sponsorship!='Y')%>%
  group_by(location,federal_sponsorship) %>% 
  summarize(amount = mean(total_amount)*n(), .groups = 'keep') 

#This is to reclassify federally funded unrecovered as nonfed (institutional) so totals match up
exp_projects_unrec <- select(expenditures_clean,c('location','federal_sponsorship','unrecovered_amount')) %>% 
  filter(federal_sponsorship=='Y')%>%
  mutate(federal_sponsorship='N')%>%
  group_by(location,federal_sponsorship) %>% 
  summarize(amount = sum(unrecovered_amount)) 


exp_projects <-union_all(exp_projects_fed,exp_projects_nonfed)
expenditures_projects <- union_all(exp_projects,exp_projects_unrec) %>%
    inner_join(award_category, by = c('location','federal_sponsorship')) %>% 
  mutate(total_amount = amount * PROJECT_CATEGORY_SHARE) %>% 
  ungroup()



locations = as.list(t(expenditures_ccoa %>% distinct(location)))




  for (i in locations) {
 data<- assign(paste0(i),filter(expenditures_clean, location==as.name(i)))
 missing<-assign(paste0(i),filter(missing_disciplines, location==as.name(i)))
  write_xlsx(list(data=data,missing=missing),paste("To campuses/FY2024 ",i,"test.xlsx",sep=''))
}




#Writing the CCOA query output
#for (i in 'Berkeley') {
#  data<- assign(paste0(i),filter(expenditures_ccoa, location==as.name(i)))
#  write_xlsx(list(data=data),paste("To campuses/FY2024 ",i,"_CCOA.xlsx",sep=''))
#}


