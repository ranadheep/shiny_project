library(shiny)
shinyServer(function(input, output,session) {
    
    #Load libraries   
    library(leaflet)
    library(tidyr)
    library(dplyr)
    
    
    # Read 2017 Car crash data in Allegheny County.
    #  Data is loaded from :
    #    https://data.wprdc.org/datastore/dump/bf8b3c7e-8d60-40df-9134-21606a451c1a
    
    DF<-read.csv("CarCrash2017.csv") 
    
    #Subset the location of the car crash (Latitude and longtiutiate)
    # To show the information on  a Leaflet MAP 
    
    #Subset only the accidents which the at least one car is involved.
    
    #Keep the data about the month of the accident.
    #Create a new column with the month's names instead of a number. 
    #Since there is a large number of the crash 
    #There will be an option to show car crash per specific month
    #For information to present in a popup :
    #AUTOMOBILE_COUNT -  the number of cars involved 
    #FATAL_COUNT - Total number of death 
    #ILLEGAL_DRUG_RELATED - Ilegal drug involvement 
    #DRINKING_DRIVER Number of Drunk People involved in the car accident 
    #INJURY_COUNT - Number of injuries 
    #Fatal And INJURY - Will be used to classifying the type of the accident 
    #And create different Icons 
    
    dfCrash<-select(DF,DEC_LAT,DEC_LONG,CRASH_MONTH,AUTOMOBILE_COUNT,DRINKING_DRIVER,
                    FATAL_COUNT,ILLEGAL_DRUG_RELATED,INJURY_COUNT,FATAL,INJURY)
    colnames(dfCrash)<-c("latitude","longitude","Month Crash","No.Cars.Involved","Drinking.Driver",
                         "Death.Count","Drug.Involved","Injury.Count","Fatality.ind","Injury.ind")
    #Drop all NA columns
    dfCrash<-dfCrash %>% drop_na()
    
    #Create a column with the accident month names (instead of a number)
    dfCrash<-mutate(dfCrash,Month.Crash.Name=month.name[dfCrash$`Month Crash`])
    
    #Subset - remove all accident with zero cars 
    dfCrash <-subset(dfCrash,dfCrash$No.Cars.Involved > 0)
    DF.Crash.subset<-dfCrash
    
    #Create a Factor column to indicate Fatality, Injuries or no Fatalities or injuries 
    dfCrash = mutate(dfCrash,Death_Injuries = ifelse(dfCrash$Fatality.ind == 1,"Death",
                                                     ifelse(dfCrash$Fatality.ind == 0 & dfCrash$Injury.ind==1,"Injury",
                                                            ifelse(dfCrash$Fatality.ind == 0 & dfCrash$Injury.ind==0,"None","None"))))
    
    dfCrash$Death_Injuries<-as.factor(dfCrash$Death_Injuries)
    #Calculate the Maximum and Minimum number of cars involved 
    #Send it as output to the UI (Slider to select the range of cars involved) 
    Max_No_Car <- max(dfCrash$No.Cars.Involved)
    Min_No_Car <- min(dfCrash$No.Cars.Involved)
    
    DF.Crash.subset<-dfCrash
    
    
    
    #Icon's list 
    CrashIcons <- iconList(
        None = makeIcon("CarsIconGreen.png",iconWidth = 45, iconHeight = 45),
        Death = makeIcon("CarsIconRed.png",iconWidth = 45, iconHeight = 45),
        Injury = makeIcon("CarsIconYellow.png",iconWidth = 45, iconHeight = 45)
    )
    
    #Use the Min and Max values to updates the slider input 
    updateSliderInput(session, "slider", max=Max_No_Car,min=Min_No_Car)
    
    
    #Reactive function to get the Selected month (or all year).
    Month<- reactive({
        input$Month
    })
    
    
    #Reactive function to get the Selected number of cars involved.
    Cars<- reactive({
        input$slider
    })
    
    
    #Create the MAP. 
    output$map <- renderLeaflet({
        
        #Get the Month and slice the Data Frame accordingly.
        Sel.Month<-Month()
        if (Sel.Month == "All")
            DF.Crash.subset<-dfCrash
        else
            DF.Crash.subset <-subset(dfCrash,dfCrash$Month.Crash.Name==Sel.Month)
        
        #Get No of Cars and slice the data frame accordingly.
        Sel.Cars<-Cars()
        DF.Crash.subset <-subset(DF.Crash.subset,DF.Crash.subset$No.Cars.Involved<=Sel.Cars)
        
        
        
        
        #Build the MAP   
        leaflet(DF.Crash.subset) %>%
            addTiles()%>%  # Add default OpenStreetMap map tiles
            #Add Markers and popup.
            addMarkers(icon = ~CrashIcons[Death_Injuries],clusterOptions = markerClusterOptions(),
                       popup = paste("Car involved:", DF.Crash.subset$No.Cars.Involved ,"<br>",
                                     "Fatality:",DF.Crash.subset$Death.Count,"<br>",
                                     "Injuries:",DF.Crash.subset$Injury.Count,"<br>",
                                     "Drugs Involved :", DF.Crash.subset$Drug.Involved,"<br>",
                                     " Alcohol involved:",DF.Crash.subset$Drinking.Driver))
        
        
    })
    
    
    
    
    
    
    
    
})