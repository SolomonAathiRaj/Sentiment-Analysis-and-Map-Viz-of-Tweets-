library(shiny)
library(shinydashboard)
library(rCharts)
library(httr)
library(twitteR)
library(tm)# for text mining & computing word frequency
require(xts)
require(stringr)
library(rvest)
library(dplyr)
library(SnowballC) # for stemming of words
library(wordcloud) # generating word cloud
library(RColorBrewer) # for creating a cloud of multiple colors instead of having one single colour
library(leaflet)
library(markdown)



dheader <- dashboardHeader(title = "Prediction of Success of a movie with Twitter Data",
                           titleWidth = 500, dropdownMenu(type = "messages",  
                                                          messageItem(
                                                            from = "Welcome Cinephile!",
                                                            message = "Explore the app to the fullest!",
                                                            icon = icon("smile-o")
                                                          ),
                                                          
                                                          messageItem(
                                                            from = "New User?",
                                                            message = "Share your experiences with me!",
                                                            icon = icon("question")
                                                            
                                                          ),
                                                          messageItem(
                                                            from = "Support",
                                                            message = "Connect to @Solomon1195 on Twitter!",
                                                            href = "https://twitter.com/solomon1195",
                                                            icon = icon("life-ring")
                                                          ), badgeStatus = "success"),
                           
                           dropdownMenu(type = "notifications",
                                        notificationItem(
                                          text = "Restricted to be in use for 25 Active Hrs",
                                          icon = icon("exclamation-triangle"),
                                          status = "warning"
                                        ), badgeStatus = "danger"))

dsidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("State of mind of tweeple", tabName="plot", icon=icon("bar-chart"),selected = TRUE),
    menuItem("Critics about the movie", tabName="critics", icon=icon("pie-chart",lib="font-awesome")),
    menuItem("WordCloud", tabName = "wc", icon = icon("cloud", lib="font-awesome")),
    menuItem("Top Most 10 words in analysis", tabName = "words", icon = icon("bar-chart", lib="font-awesome")),
    menuItem("Location of Tweets", tabName="loc",icon = icon("street-view", lib="font-awesome")),
    menuItem("About", tabName = "about",icon = icon("mortar-board")),
    menuItem("Share your experiences:", tabName = "share", icon = icon("share-alt")),
    menuItem("Solomon AathiRaj", icon = icon("facebook-official"), href = "https://www.facebook.com/SolomonAathi"),
    menuItem("@Solomon1195", icon = icon("twitter"), href= "https://twitter.com/solomon1195"),
    menuItem("insanelyanalytics (blog)", icon = icon("wordpress"), href = "https://insanelyanalytics.wordpress.com/blog-author/"),
    menuItem("LinkedIn", icon = icon("linkedin"), href = "https://in.linkedin.com/in/solomonaathiraj"),
    menuItem("Solomon AthiRaj", icon = icon("google-plus"), href = "https://google.com/+SolomonPrabhu1195")
    ))
    
    dbody <- dashboardBody(
      tabItems(
        tabItem(tabName = "plot",
                fluidRow(
                  column(width = 2, 
                         tabBox( width = NULL,
                                 tabPanel(h4("INPUTS"), 
                                          textInput("searchkw","Name of the Movie to search:",value = "", placeholder = "Ex: #TheRevenant"),
                                          tags$div(
                                            HTML("Note: Prefer to enter the movie name with a prefix of 
                                       '#' and also ensure it was in trends on Twitter to fetch more number of tweets")
                                          ),
                                          sliderInput("nt","Number of tweets to be fetched:", value = 100,min = 10, max = 1000, step = 1),
                                          selectInput("lang","Language:", choices = list("English" = 1), selected = 1),
                                          actionButton(inputId='actb',icon =icon("twitter"), label="Hit it!")))),
                  verbatimTextOutput("n1Text"),
                  verbatimTextOutput("n2Text"),
                  
                  box(status = "primary", width = 10, showOutput("Chart1", "nvd3"), 
                      title = "How do tweeple feel about the movie?", solidHeader = TRUE,
                      collapsible = TRUE)),
                  fluidRow(
                
                  box(width = 8,status = "danger",color="red",includeHTML("rt.html"),title = "Recent Tweets: Trending on Twitter",solidHeader = FALSE, 
                      tableOutput("recentTweets1")))
                  
                  
                ),
        tabItem(tabName = "critics",
                fluidRow(
                  column(width = 4, 
                         tabBox( width = NULL,
                                 tabPanel(h4("Note!"), 
                                          
                                          tags$div(
                                            HTML("<h5>[1] You're viewing the critics about the movie for which you searched in 
                                               'the State of mind of tweeple' tab.</h5></br>")
                                          ),
                                          tags$div(
                                            HTML("<h5>[2] This chart will give you a cumulative opinion about 
                                               the movie and will tell you how good the movie is!</h5>")
                                          )
                                          
                                          
                                 )
                         )
                  ),
                  box(width = 8, showOutput("Chart2", "nvd3"), 
                      title = "How good the movie is? (consolidated)", solidHeader = TRUE,
                      collapsible = TRUE,status = "primary")
                )),
        
        tabItem(tabName = "wc",
                fluidRow(
                  column(width = 4,
                         tabBox( width = NULL,
                                 tabPanel(h4("Inputs"),
                                          sliderInput("minf","Minimum frequency of words:", value = 4 ,min = 1, max = 50, step = 1),
                                          sliderInput("maxnw","Maximum number of words:", value = 100, min = 10, max = 300, step = 1)
                                 )
                         )
                  ),
                  column(width = 8,
                         box(width = NULL, plotOutput("plotwc",height="500px"), collapsible = TRUE,
                             title = "Bag of words that were often used in the tweets", status = "primary", solidHeader = TRUE)
                        )
                )),
        
        tabItem(tabName = "words",
                fluidRow(
                  box(width = 12, showOutput("Chart3", "nvd3"), 
                      title = "Visualizing the Top Most 10 frequency of occurrences of the words in the tweets", solidHeader = TRUE,
                      collapsible = TRUE,status = "primary")
                  
                  )),
        tabItem(tabName = "loc",
                fluidRow(
                  column(width = 3,
                         tabBox(width = NULL,
                                tabPanel(h4("Inputs"),
                                         
                                         textInput("k","Name of the Movie to search:",value = "", placeholder = "#TheRevenant"),
                                         sliderInput("n","Number of tweets to be fetched:", value = 100, min = 50, max = 500, step = 1),
                                         selectInput("lang","Language:", choices = list("English" = 1), selected = 1),
                                         textInput("lat","Latitude:",value = "", placeholder = "Ex: 39.045435"),
                                         tags$div(
                                           HTML("Note: Do not fail to enter values in numbers(precisely, in double) for lat & long")
                                         ),
                                         textInput("long","Longitude:",value = "", placeholder = "Ex: 94.565432"),
                                         
                                         tags$div(
                                           HTML("Note: Most of the tweeple prefer not to disclose their 
                                              location while posting tweets. So, ultimately what you receive will be much lesser than what you asked for")
                                         ),
                                         numericInput("rad","Radius(in miles):",value = 500, min=1, max = 1500, step = 1),
                                         tags$div(
                                           HTML("Note: Use Up and Down Arrow keys to change values in steps of 100")
                                         ),
                                         actionButton("mapit","Map It!", icon = icon("map-marker"))
                                         
                                ))),
                  
                  column(width = 9,
                         box(width = NULL, solidHeader = TRUE,
                             leafletOutput("mymap", height = 500), title = "Visualization of the place where the tweets popped from", status = "primary"
                         ))
                
                         
                  
                )),
        tabItem(tabName = "about",
                fluidRow(column(width=12,
                                includeHTML("pbottc_report.html")))
        )))
        
        
        
      
    

dashboardPage(
  skin = "purple",
  dheader,
  dsidebar,
  dbody
)
