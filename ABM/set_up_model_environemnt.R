
library('raster')
library(tidyverse)
library(ggpubr)

######################################
##read_human data
######################################
hh_data<-read.csv("~/data/synthetic_household_data.csv")
hh_full_case_data<-read.csv("~/data/synthetic_case_data.csv")

hh_case_data<-hh_full_case_data[hh_full_case_data$malaria_type!="",]
Mtype_to_num<-matrix(data=NA,nrow=length(hh_case_data$malaria_type),ncol=1)

#actual case data has infection with these three parasite
Mtype_to_num[hh_case_data$malaria_type=="P.f",]=1
Mtype_to_num[hh_case_data$malaria_type=="P.m",]=2
Mtype_to_num[hh_case_data$malaria_type=="P.v",]=3

#######
Treatment_type<-matrix(data=NA,nrow=length(hh_data$malaria_prevention),ncol=1)
Treatment_type[hh_data$malaria_prevention=="Don't know",]=1
Treatment_type[hh_data$malaria_prevention=="IRS",]=2
Treatment_type[hh_data$malaria_prevention=="IRS + LLINs",]=3
Treatment_type[hh_data$malaria_prevention=="LLINs",]=4
Treatment_type[hh_data$malaria_prevention=="None",]=5
######################################


#get the raster for mosquito suitability
setwd("~/data/mosq_suitability_rasters")
suitability_map<-raster("Month1.gri") ## global map


#find all household id's without duplicate
hh_labels<-unique(rbind(matrix(hh_full_case_data$id_household,nrow=length(hh_full_case_data$id_household)),matrix(hh_data$id_household,nrow=length(hh_data$id_household))))


#create empty matrix to store data
people_locations<-matrix(NA,nrow=length(hh_labels),ncol=2) #latitude & longitude
indicie_MAP<-matrix(NA,nrow=length(hh_labels),ncol=2) # identify individual's closest location to the mosquito suitability map

hh_treatment<-matrix(1,nrow=length(hh_labels),ncol=1) # intervention


N<-matrix(NA,nrow=length(hh_labels),ncol=1)    #Household size (actual)
N_guess<-matrix(FALSE,nrow=length(hh_labels),ncol=1) #Household size (actual or guessing from individual id)


#find the x and y grid of the raster
Xvector<-xFromCol(suitability_map)   
Yvector<-yFromRow(suitability_map)

Xbounds<-c(min(hh_data$longitude),max(hh_data$longitude)) # lower and upper bound for longitude of interested region
Ybounds<-c(min(hh_data$latitude),max(hh_data$latitude)) # lower and upper bound for latitude of interested region

therows<-which(Yvector>=Ybounds[1] & Yvector<=Ybounds[2]) # restricting longitude to contain interested region
thecols<-which(Xvector>=Xbounds[1] & Xvector<=Xbounds[2]) # restricting latitude to contain interested region

Xvector<-Xvector[thecols] # selected raster latitudes for chosen region
Yvector<-Yvector[therows] # selected raster longitudes for chosen region

#########
#record HH sizes for where we have these data
initial_HH_distribution <- hh_data$hh_number[!duplicated(hh_data$id_household)]

#find a relevant vector (list) of locations and (corresponding) treatments for all the house id
for(ii in 1:length(hh_labels)){  
   print(ii)
  
   temp<-hh_data$longitude[which(hh_data$id_household==hh_labels[ii])]
  #if the household is in case data but not in other data, we do not have its size and must sample
  if(length(temp)==0){
    indicie<-which(hh_full_case_data$id_household==hh_labels[ii])
    temp_loc<-cbind(hh_full_case_data$longitude[indicie],hh_full_case_data$latitude[indicie])
    N_guess[ii]<-TRUE
    
    #this is the minimum possible number of individuals in the household
    min_size<-length(unique(hh_full_case_data$id_individual[indicie]))
    N[ii]<-sample(initial_HH_distribution[initial_HH_distribution>=min_size],1)
    
  }else{
    indicie<-which(hh_data$id_household==hh_labels[ii])
    temp_loc<-cbind(temp,hh_data$latitude[indicie])
    treatments<-Treatment_type[indicie]
    hh_treatment[ii]<-treatments[1]
    

    Ns<-hh_data$hh_number[indicie]
    N[ii]<-Ns[1]
    
  }
  people_locations[ii,]<-temp_loc[1,]
  
  
  indicie_MAP[ii,]<-c(which.min((temp_loc[1,2]-Yvector)^2),which.min((temp_loc[1,1]-Xvector)^2)) # identify individual's closest location to the mosquito suitability map coordinates
}
#a factor to scale the suitability (just so we can differentiate between the bite rate and travel rate, whereas the creation rate is a product)
MAP_rate_scaling<-1

val_mat<-matrix(NA,nrow=length(therows),ncol=length(thecols)) #value from raster data
season_val_mat<-data.frame(matrix(0,nrow=length(therows),ncol=(length(thecols)+1)))

for(ii in 1:length(therows)){
  val_mat[ii,]<-getValues(suitability_map,row=therows[ii])[thecols]
}

norm_const<-((length(Xvector)*length(Yvector))/sum(val_mat))**MAP_rate_scaling
val_mat<-val_mat*norm_const

season_val_mat[1:length(therows),1:length(thecols)]<-val_mat
season_val_mat[1:length(therows),length(thecols)+1]<-1

seasonal_MAP_hh<-matrix(NA,nrow=length(indicie_MAP[,1]),ncol=12)

seasonal_MAP_hh[,1]<-val_mat[indicie_MAP]

for(ii in 2:12){
  suitability_map<-raster(paste("Month",as.character(ii),".gri",sep=""))
  for(jj in 1:length(therows)){
    val_mat[jj,]<-getValues(suitability_map,row=therows[jj])[thecols]
  }
  val_mat<-val_mat*norm_const
  season_val_mat[(length(therows)*(ii-1)+1):(length(therows)*ii),1:length(thecols)]<-val_mat
  season_val_mat[(length(therows)*(ii-1)+1):(length(therows)*ii),length(thecols)+1]<-ii
  seasonal_MAP_hh[,ii]<-val_mat[indicie_MAP]
}

#####make sure suit. data is non zero (
for(i in 1:length(seasonal_MAP_hh[,1])){
  for (j in 1:12){
    if(seasonal_MAP_hh[i,j]<.000001){
      seasonal_MAP_hh[i,j]<-.1 #this doesn't add anything but makes sure to run without error
    }
  }
}

people_locations_LATLONG<-data.frame(cbind(people_locations,hh_treatment))
names(people_locations_LATLONG)<-c("long","lat","treatments")
ind_level_data<-data.frame(matrix(NA,nrow=sum(N),ncol=7)) #for additional intervention and mos_rate (because of 2 different interventions)
names(ind_level_data)<-c("hh_id","ind_id","treatment","long","lat","N","malaria")

people_locations<-latlong2grid(people_locations)  

people_locations[,1]<-people_locations[,1]-min(people_locations[,1])
people_locations[,2]<-people_locations[,2]-min(people_locations[,2])

seasonal_MAP_ind<-matrix(NA,nrow=sum(N),ncol=12)

for(ii in 1:length(hh_labels)){
  for(jj in 1:N[ii]){
    #specifies the row of the data set
    if(ii!=1){
      row_num<-sum(N[1:(ii-1)])+jj
    }else{
      row_num<-jj
    }#
    ind_level_data$hh_id[row_num]<-hh_labels[ii]
    ind_level_data$ind_id[row_num]<-jj
    ind_level_data$treatment[row_num]<-hh_treatment[ii]

    ind_level_data$long[row_num]<-people_locations[ii,1]
    ind_level_data$lat[row_num]<-people_locations[ii,2]
    ind_level_data$N[row_num]<-N[ii]
    seasonal_MAP_ind[row_num,]<-seasonal_MAP_hh[ii,]
  }
  
  indicie<-which(hh_full_case_data$id_household==hh_labels[ii])
  if(sum(indicie)!=0){
    #unique list of IDs in the household
    inds_sick<-unique(hh_full_case_data$id_individual[indicie])
    for(jj in 1:length(inds_sick)){
      
      if(ii!=1){
        row_num<-sum(N[1:(ii-1)])+jj
      }else{
        row_num<-jj
      }
      #for each ID in the household check list of malaria test results (only consider last result)
      malaria_ind<-hh_full_case_data$malaria_type[which(hh_full_case_data$id_individual==inds_sick[jj])]
      if(malaria_ind[length(malaria_ind)]=="P.f"){
        ind_level_data$malaria[row_num]<-1
      }else if(malaria_ind[length(malaria_ind)]=="P.m"){
        ind_level_data$malaria[row_num]<-2
      }else if(malaria_ind[length(malaria_ind)]=="P.v"){
        ind_level_data$malaria[row_num]<-3
      }
    }
    
  }
  
}
