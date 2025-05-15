
#maximum simulation time
max_t<-300#5*365

#model parameters 
bite_rate<-1 # mosq biting rate
transMH_per_bite<-0.3 #prob of transmission from mosq to human
transHM_per_bite<-0.1 #prob of transmission from human to mosq

bite_reduction_IRS<-0.3 #reduction in bites due to IRS
bite_reduction_LLIN<-0.56 #reduction in bites due to LLINs
death_IRS<-0.56 #mosquito death rate due to IRS 
death_LLIN<-0.19 #mosquito death rate due to LLINs 

sigmaH<-1/9.9 #expected exposed period in humans is 9.9 days
sigmaM<-1/14  #expected exposed period in mozzys is 14 days

gammaM<-1/(5*7) #death rate of mosq
gammaH<-1/30    #recovery rate of human

eta<-1/2       #expected time the mosquito is full is 2 days
flight_rate<-5 #rate of travel

multiple_meal<-0.18 #prob of multiple blood meal

#seasonal parameters
seas_param_a<- 1
seas_param_alph <- .062
