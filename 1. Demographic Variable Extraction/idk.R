setwd("/Users/alexis/Library/CloudStorage/OneDrive-UniversityofNorthCarolinaatChapelHill/CEMALB_DataAnalysisPM/Projects/P1009. NC ENVRIOSCAN/P1009.3. Analyses/P1009.3.3. Demographic Variable Extraction")

cur_date = "092322"

library(readxl)
library(tidyverse)
library(tidycensus)
library(ggpubr)
library(quantreg)

# reading in files
acs_df = data.frame(read_excel("Input/ACS_Data_091422.xlsx", sheet = 2)) #R13168684_SL140.csv
wildfire_tract_df = data.frame(read_excel("Input/Wildfire_tract_053022.xls")) #WFH_tract.csv

# getting col names in the wildfire tract df that we're interested in 
wildfire_tract_df = wildfire_tract_df %>%
  select(GEOID, NAME, NAMELSAD, ALAND, AWATER, Avg_Wildfire.Hazard.Potential.Min, Min_Wildfire.Hazard.Potential.Max,
  Max_Wildfire.Hazard.Potential.Min, Avg_Wildfire.Hazard.Potential.Max, Min_Wildfire.Hazard.Potential.Max,
  Max_Wildfire.Hazard.Potential.Max, Avg_Wildfire.Hazard.Potential.Mean, Min_Wildfire.Hazard.Potential.Mean,
  Max_Wildfire.Hazard.Potential.Mean, Avg_ACRES, Min_ACRES, Max_ACRES) 

# renaming to create a FIPS col so we can merge the two dataframes
acs_df = acs_df %>%
  rename(GEOID = Geo_FIPS)


# merging the Wildfire data to ACS data
wildfire_tract_acs_df <- merge(wildfire_tract_df, acs_df, by = "GEOID")

# pulling data from the census using an API key
# request your own API key at http://api.census.gov/data/key_signup.html 
census_api_key("26887b197b0785a54a045f3be1cd67622a569fb1", install = TRUE, overwrite = TRUE) 

# necessary to access data
readRenviron("~/.Renviron")

# obtaining data and feature geometry for the ACS
NC_income <- get_acs(
  geography = "tract", 
  variables = "B19013_001",
  state = "NC", 
  year = 2020,
  geometry = TRUE
)

head(NC_income)


# creating a df that only contains feature geometry
NC_feature_geometry_df = NC_income %>%
  select(GEOID, geometry)

# merging geometry (extracted acs data) with the wildfire hazard and census data
wildfire_hazard_acs_geometry_df = merge(NC_feature_geometry_df, wildfire_tract_acs_df, by = "GEOID")

head(wildfire_hazard_acs_geometry_df)

# the acs geometry data provides number of individuals, which will be converted into a percentage
wildfire_hazard_acs_geometry_df = wildfire_hazard_acs_geometry_df %>%
  # SE_A00001_001 = total population column
  filter(SE_A00001_001 > 0) %>%
  # only keeping the census tract data
  select(-contains("Geo_"))

# before the some of the percentages can be calculated we need to obtain the total non-white and poverty populations
wildfire_hazard_acs_geometry_df$NonWhite <- (wildfire_hazard_acs_geometry_df$SE_A00001_001 - wildfire_hazard_acs_geometry_df$SE_B04001_003)
wildfire_hazard_acs_geometry_df$Poverty <- (wildfire_hazard_acs_geometry_df$SE_A13003A_002 + wildfire_hazard_acs_geometry_df$SE_A13003B_002 + wildfire_hazard_acs_geometry_df$SE_A13003C_002)


# it would be nice to make these lines more efficient , but that's not possible since the total population to calculqte each percentage are different for each column
# total population %  (further stratified by race, age)
wildfire_hazard_acs_geometry_df$Per_Black <- (wildfire_hazard_acs_geometry_df$SE_B04001_003 / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_NonWhite <- (wildfire_hazard_acs_geometry_df$NonWhite / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_White <- (wildfire_hazard_acs_geometry_df$SE_B04001_003 / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Native <- (wildfire_hazard_acs_geometry_df$SE_B04001_005 / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Asian <- (wildfire_hazard_acs_geometry_df$SE_B04001_006 / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Less5 <- (wildfire_hazard_acs_geometry_df$SE_A01001_002 / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100


# Poverty % (further stratified by race and age)
wildfire_hazard_acs_geometry_df$Per_Poverty <- (wildfire_hazard_acs_geometry_df$Poverty / wildfire_hazard_acs_geometry_df$SE_A00001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_NHWhite <- (wildfire_hazard_acs_geometry_df$SE_A13001I_002 / wildfire_hazard_acs_geometry_df$SE_A13001I_001) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_Black <- (wildfire_hazard_acs_geometry_df$SE_A13001B_002 / wildfire_hazard_acs_geometry_df$SE_A13001B_001) * 100
# some of the native american and asian rows have zeros, due to having a population of zero (0  denominator = undefined or NaN values)
wildfire_hazard_acs_geometry_df$Per_Poverty_Native <- (wildfire_hazard_acs_geometry_df$SE_A13001C_002 / wildfire_hazard_acs_geometry_df$SE_A13001C_001) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_Asian <- (wildfire_hazard_acs_geometry_df$SE_A13001D_002 / wildfire_hazard_acs_geometry_df$SE_A13001D_001) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_Hisp <- (wildfire_hazard_acs_geometry_df$SE_A13001H_002 / wildfire_hazard_acs_geometry_df$SE_A13001H_001) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_White <- (wildfire_hazard_acs_geometry_df$SE_A13001A_002 / wildfire_hazard_acs_geometry_df$SE_A13001A_001) * 100

wildfire_hazard_acs_geometry_df$Per_Poverty_Children <- (wildfire_hazard_acs_geometry_df$SE_A13003A_002 / (wildfire_hazard_acs_geometry_df$SE_A01001_002 + wildfire_hazard_acs_geometry_df$SE_A01001_003 + wildfire_hazard_acs_geometry_df$SE_A01001_004 + wildfire_hazard_acs_geometry_df$SE_A01001_005)) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_Adults <- (wildfire_hazard_acs_geometry_df$SE_A13001A_002 / (wildfire_hazard_acs_geometry_df$SE_A01001_006 + wildfire_hazard_acs_geometry_df$SE_A01001_007 + wildfire_hazard_acs_geometry_df$SE_A01001_008 + wildfire_hazard_acs_geometry_df$SE_A01001_009 + wildfire_hazard_acs_geometry_df$SE_A01001_010)) * 100
wildfire_hazard_acs_geometry_df$Per_Poverty_Seniors <- (wildfire_hazard_acs_geometry_df$SE_A13003C_002 / (wildfire_hazard_acs_geometry_df$SE_A01001_011 + wildfire_hazard_acs_geometry_df$SE_A01001_012 + wildfire_hazard_acs_geometry_df$SE_A01001_013)) * 100


# education level % 
wildfire_hazard_acs_geometry_df$Per_LHS_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_002 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_HS_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_003 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Some_College_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_004 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Bacehlors_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_005 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Masters_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_006 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Professional_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_007 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Doctorate_Edu <- (wildfire_hazard_acs_geometry_df$SE_A12001_008 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100
wildfire_hazard_acs_geometry_df$Per_At_Least_College_Edu <- (wildfire_hazard_acs_geometry_df$SE_B12001_004 / wildfire_hazard_acs_geometry_df$SE_A12001_001) * 100


# insurance status % (further stratified by race)
wildfire_hazard_acs_geometry_df$Per_No_Ins <- (wildfire_hazard_acs_geometry_df$SE_A20001_002 / wildfire_hazard_acs_geometry_df$SE_A20001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Ins <- (wildfire_hazard_acs_geometry_df$SE_A20001_003 / wildfire_hazard_acs_geometry_df$SE_A20001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Public_Ins <- (wildfire_hazard_acs_geometry_df$SE_A20001_004 / wildfire_hazard_acs_geometry_df$SE_A20001_001) * 100
wildfire_hazard_acs_geometry_df$Per_Private_Ins <- (wildfire_hazard_acs_geometry_df$SE_A20001_005 / wildfire_hazard_acs_geometry_df$SE_A20001_001) * 100


# EXPORT THE FILE HERE

# Determining if each SES variable is associated with avg wildfire hazard potential mean using linear and logistic regression

# getting the poverty col names to iterate through them using a loop in the function below
poverty_variables = colnames(wildfire_hazard_acs_geometry_df)[112:121]


# creating the linear regression function 
linear_regression = function (df, SES_variables){
  # """
  # Creating a function to perform linear regression.
  # :param (input): df (containing data to be analyzed), socioeconomic status (SES variables)
  # :output: df containing the model/method, SES variable, statistic, p value, and p adjust
  # """
  
  # creating an empty df to store the t and p values from the linear regression
  values_df = data.frame()
  for (i in 1:length(SES_variables)){
    # generalized linear model (GLM)
    linear_model = glm(as.formula(paste0("Avg_Wildfire.Hazard.Potential.Mean", "~", SES_variables[i])), data = df, family = gaussian)
    summarized_linear_model = summary(linear_model)
    
    # creating a row of data that specifies the method, variable, statistic, and p value
    linear_values = c("Linear Regression", SES_variables[i], summarized_linear_model$coefficients[c(6,8)])
    
    # adding just the name statistic and p value to the df
    values_df = rbind(values_df, linear_values)
    
  }  
  
  # adding colnames
  colnames(values_df) = c("Method", "Variable", "Statistic", "P Value")
  
  # adjusting p value
  values_df$`P Adj` = p.adjust(as.numeric(as.character(values_df$`P Value`)), method = "fdr")
  
  return(values_df)
}

# calling function
lm_results = linear_regression(wildfire_hazard_acs_geometry_df, poverty_variables)


# creating linear plots
plots = list()
for (i in 1:length(poverty_variables)){
  plots[[i]] = ggplot(data = wildfire_hazard_acs_geometry_df, mapping = aes_string(x = poverty_variables[i], y = "Avg_Wildfire.Hazard.Potential.Mean")) + 
    geom_point() + 
    geom_smooth(method = "lm", se = FALSE) + 
    theme_bw()
}
#viewing all plots
ggarrange(plotlist = plots)


# now trying quantile regression
# wildfire hazard potential (WHP) already seems to be grouping in strata, so quantile regression performs linear regression within each quantile

# creating the quantile regression function 
quantile_regression = function (df, SES_variables){
  # """
  # Creating a function to perform linear quantile regression.
  # :param (input): df (containing data to be analyzed), socioeconomic status (SES variables)
  # :output: df containing the model/method, SES variable, quantile, statistic, p value, and p adjust
  # """
  
  # creating a vector to loop through for the argument tau that specifies the quantile
  tau_values = c(0.2, 0.4, 0.6, 0.8) #seq(0, 1, by = 0.2)
  
  # creating an empty df to store the t and p values from the quantile regression
  values_df = data.frame()
  
  for (i in 1:length(SES_variables)){
    for (j in 1:length(tau_values)){
      # quantile linear regression
      print(SES_variables[i])
      print(tau_values[j])
      quantile_model = rq(as.formula(paste0("Avg_Wildfire.Hazard.Potential.Mean", "~", SES_variables[i])), data = df, tau = tau_values[j])
      summarized_quantile_model = summary(quantile_model)
      
      # creating a row of data that specifies the method, variable, tau, statistic, and p value
      quantile_values = c("Quantile Regression", SES_variables[i], tau_values[j], summarized_quantile_model$coefficients[c(6,8)])
      
      # adding just the name statistic and p value to the df
      values_df = rbind(values_df, quantile_values)
      
      }  
    }
  
  # adding colnames
  colnames(values_df) = c("Method", "Variable", "Quantile", "Statistic", "P Value")
  
  # adjusting p value within each quantile
  values_df = values_df %>%
    group_by(Quantile) %>%
    mutate(`P Adjust` = p.adjust(as.numeric(as.character(`P Value`)), method = "fdr")) %>%
    ungroup()
  
  return(values_df)
}

# calling function
quantile_results = quantile_regression(wildfire_hazard_acs_geometry_df, poverty_variables)


# creating quantile plots
plots = list()
for (i in 1:length(poverty_variables)){
  plots[[i]] = ggplot(data = wildfire_hazard_acs_geometry_df, mapping = aes_string(x = poverty_variables[i], y = "Avg_Wildfire.Hazard.Potential.Mean")) + 
    geom_point() + 
    geom_quantile(quantile = c(0.2, 0.4, 0.6, 0.8), method = "rq") + 
    theme_bw()
}
#viewing all plots
ggarrange(plotlist = plots)
