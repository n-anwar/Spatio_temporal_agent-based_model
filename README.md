# Spatio-temporal agent-based modelling of malaria
This is the code repo to accompany the above-titled article.



# Project tree
 * [ABM](./ABM)
   * [agent-based_model.R](./ABM/agent-based_model.R)
   * [set_up_model_environemnt.R](./ABM/set_up_model_environemnt.R)
   * [model_parameters.R](./ABM/model_parameters.R)
* [Supplementary_video](./Supplementary_video)
   * [Mosquito_dynamics_5yr.mp4](./Supplementary_video/Mosquito_dynamics_5yr.mp4)
   * [Mosquito suitability all year.gif](./Supplementary_video/Mosquito_suitability_all_year.gif)
* [data](./data)
   * [synthetic_case_data.csv](./data/synthetic_case_data.csv)
   * [synthetic_household_data.csv](./data/synthetic_household_data.csv)
     * [mosq_suitability_rasters](./data/mosq_suitability_rasters)
 * [README.md](./README.md)


 # File description
The codes found in the [ABM](./ABM) directory are used to provide an overview of the model implementation with both humans and mosquitoes as agents. [agent-based_model.R](./ABM/agent-based_model.R) is the main script for the ABM and only needs to run this directly. This file loads other files within the directory. [model_parameters.R](./ABM/model_parameters.R) contains all the model parameters and can be changed by users. [set_up_model_environemnt.R](./ABM/set_up_model_environemnt.R) reads the human and mosquito data and calculates the mosquito generation rate at the individual level. Due to legal and ethical restrictions, the original data used in the study can not be shared, and instead, a synthetic human dataset is provided in the [data](./data) directory. The [synthetic_household_data.csv](./data/synthetic_household_data.csv) file ncontains the synthetic household data that consists of GPS location, household id, number of people in the household and types of vector intervention used. The [synthetic_case_data.csv](./data/synthetic_case_data.csv) file contains a synthetic case dataset (people that are infected with malaria with parasite type). The [mosq_suitability_rasters](./data/mosq_suitability_rasters) directory contains the mosquito suitability data (global) that is used to get the mosquito suitability data for the Vietnam province. The mosquito suitability data over the year (for both globally and in Vietnam province) is provided in the [Mosquito suitability all year.gif](./Supplementary_video/Mosquito_suitability_all_year.gif) file.

A video of mosquitoes progressing through different disease states over time within the model can be seen in the [Mosquito_dynamics_5yr.mp4](./Supplementary_video/Mosquito_dynamics_5yr.mp4) file. 

