# Wildfires and Environmental Justice: Future Wildfire Events Predicted to Disproportionally Impact Socioeconomically Vulnerable Communities in North Carolina

Script that associates with 'Wildfires and Environmental Justice: Future Wildfire Events Predicted to Disproportionally Impact Socioeconomically Vulnerable Communities in North Carolina', published in 2024 in Frontiers. doi: https://doi.org/10.3389/fpubh.2024.1339700

> This study sought to identify regions of high risk to future wildfire events and determine what communities are most vulnerable to those effects based on socioeconomic and sociodemographic factors. This information will be disseminated through North Carolina ENVIROSCAN, which helps communities increase awareness of key environmental and societal factors that can impact health.
> All analyses in this respository are designated by their figure number or table number in the manuscript in parantheses.

In the instance that the files are unable to rendered on Github the files can be viewed using NBViewer [here](https://nbviewer.org/github/UNC-CEMALB/Wildfires-and-Environmental-Justice-Future-Wildfire-Events-Predicted-to-Disproportionally-Impact-So/tree/main/).

<br>

# 1. WHP Data Cleaning
- Cleaning up the wildfire hazard data including adding in county names

# 2. Imputation
- Sociodemographic Imputation: Using random forest (RF) to generate missing sociodemographic and socioeconomic data from the 2010 American Community Survey (ACS)
- Housing Imputation: Using random forest (RF) to generate missing housing data from the 2010 American Community Survey (ACS)
- Wildfire Imputation: Using random forest (RF) to generate missing wildfire potential data and put those data into quintiles

# 3. Sociodemographic Clustering
- Using kmeans to cluster GEO ids based on sociodemographic data

# 4. Cluster Variable Averages (Figure 4 & S1)
- Plotting scaled and unscaled sociodemographic and housing variable averages per cluster

# 5. North Carolina (NC) Mapping (Figure 1, Figure 3, & Table S1)
- Mapping (Figure 1 & Figure 3): Visualizing wildfire hazard potential (WHP) mean by GEO id and county, visualizing wildfire hazard potential (WHP) quintile by GEO id and county, and
comparing WHP mean to sociodemographic clusters and housing clusters all by GEO id
- WHP County Averages (Table S1): Creating a table that contains WHP values averaged within each county

# 6. Wildfire Risk Spatial Analysis (Figure 2 & Table S3)
- Determining if there is spatial autocorrelation of wildfire potential across the state of NC using Moran's tests

# 7. Manuscript Statistics
- Generating catchy statistics regarding WHP and social vulnerability clustering for the manuscript
