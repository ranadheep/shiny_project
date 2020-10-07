library(leaflet)
library(shiny)
shinyUI(fluidPage( 
    
    tabsetPanel(
        tabPanel("MapApp", fluid = TRUE,
                 
                 titlePanel("2017 Car crash data in Allegheny County"),
                 sidebarLayout(
                     sidebarPanel(
                         #Slider to slice based on a month (or select all)
                         selectInput(
                             inputId =  "Month", 
                             label = "Select Month:", 
                             choices = c("All",month.name),
                             selected = "All"
                         ),
                         
                         #Create the slider for selecting the number of cars involved 
                         #The slider is a dynamic slider, as the maximum and minuim values 
                         # are based on the data 
                         sliderInput("slider", "Select Number of Cars involve (Range)", min = 1,
                                     max = 10, value = 1,step= 1),
                         
                         
                         #Submit button - control the changes       
                         submitButton("Submit")
                         
                     ),
                     #Main Panel 
                     mainPanel(
                         #Render the MAP
                         leafletOutput("map", width = "90%", height = "700px")
                     )
                 )
        ))))