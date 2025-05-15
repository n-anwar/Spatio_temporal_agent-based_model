
source('~/ABM/set_up_model_environemnt.R')
source('~/ABM/model_parameters.R')

mean_seasonality<-rowMeans(seasonal_MAP_hh)
scaled_seasonal_MAP <-seas_param_a*(seasonal_MAP_hh^(seas_param_alph))

  
hh_bite_prop<-((1-bite_reduction_IRS)^(1*(hh_treatment==2 | hh_treatment==3)))*((1-bite_reduction_LLIN)^(1*(hh_treatment==4 | hh_treatment==3)))
hh_deathonbite<-1-((1-death_IRS)^(1*(hh_treatment==2 | hh_treatment==3)))*((1-death_LLIN)^(1*(hh_treatment==4 | hh_treatment==3)))
propto_mozzycreation <-(transHM_per_bite/transMH_per_bite)*hh_bite_prop*(1-hh_deathonbite)/N
seasonal_creation<-matrix(0,nrow=sum(N),ncol=12) 

for(ii in 1:length(hh_labels)){
  for(jj in 1:N[ii]){
    #specifies the row of the data set
    if(ii!=1){
      row_num<-sum(N[1:(ii-1)])+jj
    }else{
      row_num<-jj
    }
    hh_row_indicies<-which(hh_labels==ind_level_data$hh_id[row_num])
    seasonal_creation[row_num,] <- scaled_seasonal_MAP[hh_row_indicies,]*propto_mozzycreation[hh_row_indicies]
    
  }
}

hh_level_data_base<-data.frame(matrix(0,nrow=length(hh_labels),ncol=5))
names(hh_level_data_base)<-c("hh_id","long","lat","N",'treatment')
hh_level_data_base$hh_id<-hh_labels
hh_level_data_base$long<-people_locations_LATLONG[,1]
hh_level_data_base$lat<-people_locations_LATLONG[,2]
hh_level_data_base$N <-N[,1]
hh_level_data_base$treatment <-hh_treatment

