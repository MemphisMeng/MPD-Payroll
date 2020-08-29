library(shiny)
library(shinythemes)
library(tidyverse)
library(magrittr)
library(maps)
library(dplyr) 
library(DescTools)
library(naniar)
library(ggplot2)
# library(hrbrthemes)
library(viridis)
library(leaflet)
library(leaflet.extras)


Boston = read_csv('data/Boston.csv')
Brockton = read_csv('data/Brockton.csv')
Cambridge = read_csv('data/Cambridge.csv')
Lynn = read_csv('data/Lynn.csv')
Springfield = read_csv('data/Springfield.csv')
rotation = read.csv('data/rotation.csv', sep=",", row.names=1)

drops <- c("_type")
Boston <- Boston[ , !(names(Boston) %in% drops)]
Brockton <- Brockton[ , !(names(Brockton) %in% drops)]
Cambridge <- Cambridge[ , !(names(Cambridge) %in% drops)]
Lynn <- Lynn[ , !(names(Lynn) %in% drops)]
Springfield <- Springfield[ , !(names(Springfield) %in% drops)]
data = rbind(rbind(rbind(rbind(Boston, Brockton), Cambridge), Lynn), Springfield)
colnames(data) <- c("Annual_Wage", "Employer", "Job_Title", "Monthly_Wage", "Name", "Year", "Gender", "Race")


ui <- fluidPage(theme=shinytheme("superhero"),
                navbarPage(
                  "MPD Payroll investigation",
                  tabPanel("Gender",
                           sidebarPanel(
                             HTML("<h3>Annual/Monthly</h4>"),
                             radioButtons("radios_1", "Please select one:",
                                          c("Annual" = "Annual_Wage",
                                            "Monthly" = "Monthly_Wage")
                             )
                            ),
                           mainPanel(
                             plotOutput("barplot")
                           )
                           ),
                  
                  tabPanel("City",
                           sidebarPanel(
                             HTML("<h3>Cities</h4>"),
                             radioButtons("radios_2", "Please select one:",
                                          c("Boston" = "Boston",
                                            "Cambridge" = "Cambridge",
                                            "Brockton" = "Brockton",
                                            "Lynn" = "Lynn",
                                            "Springfield" = "Springfield")
                             )
                           ),
                           mainPanel(
                             plotOutput("histogram")
                           )
                  ),
                  
                  tabPanel("Ethnics",
                           sidebarPanel(
                             HTML("<h3>Ethnics</h4>"),
                             checkboxGroupInput("checkboxes_3", "Please select as many cities as you want:",
                                          c("Black" = "Black",
                                            "White" = "White",
                                            "Latin" = "Hispanic/Latin",
                                            "Asian" = "Asian")
                             )
                           ),
                           mainPanel(
                             plotOutput("violin")
                           )
                  ),
                  
                  tabPanel("Title",
                           sidebarPanel(
                             HTML("<h3>Title</h4>"),
                             checkboxGroupInput("checkboxes_4", "Please select as many cities as you want:",
                                                c("Lieutenant" = "Lieutenant",
                                                  "Sergeant" = "Sergeant",
                                                  "Captain" = "Captain",
                                                  "Officer" = "Officer",
                                                  "Detective" = 'Detective',
                                                  "Commissioner" = "Commissioner",
                                                  "Director" = "Director",
                                                  "Others" = "Others")
                             )
                           ),
                           mainPanel(
                             plotOutput("box")
                           )
                  ),
                  
                  tabPanel("Year",
                           sidebarPanel(
                             HTML("<h3>Year</h4>"),
                             sliderInput("slider_5", "Year:",
                                         min = 2015, max = 2018,
                                         value = 1),
                           ),
                           mainPanel(
                             plotOutput("scatter")
                           )
                  ),
                  
                  tabPanel("Location",
                           mainPanel(
                             leafletOutput("mymap"))
                           ),
                  
                  tabPanel("Predictor",
                           sidebarPanel(
                             HTML("<h3>Input</h4>"),
                             sliderInput("year", "Year:",
                                         min = 2015, max = 2018,
                                         value = 1),
                             radioButtons("gender", "Gender:",
                                          c("male" = "male",
                                            "female" = "female")
                             ),
                             selectInput("title", "Position title:",
                                         c("Lieutenant" = "Lieutenant",
                                           "Sergeant" = "Sergeant",
                                           "Captain" = "Captain",
                                           "Officer" = "Officer",
                                           "Detective" = 'Detective',
                                           "Commissioner" = "Commissioner",
                                           "Director" = "Director",
                                           "Others" = "Others")),
                           radioButtons("city", "City:",
                                        c("Boston" = "Boston",
                                          "Cambridge" = "Cambridge",
                                          "Brockton" = "Brockton",
                                          "Lynn" = "Lynn",
                                          "Springfield" = "Springfield")
                           ),
                          selectInput("race", "Race:",
                                      c("Black" = "Black",
                                         "White" = "White",
                                         "Latin" = "Hispanic/Latin",
                                         "Asian" = "Asian"))
                           ),
                           mainPanel(
                             h4("Predicted Annual Wage (dollars): "),
                             verbatimTextOutput("annual"),
                             h4("Predicted Monthly Wage (dollars): "),
                             verbatimTextOutput("monthly")
                           )
                  )
            )
)

server <- function(input, output) {
  datasetInput1 <- reactive({
    male <- data[data$Gender == 'male', ]
    female <- data[data$Gender == 'female', ]
    genders <- c("male", "female")
    condition <- switch(input$radios_1,
                        "Annual_Wage" = rep(c("Annual_Wage") , 2),
                        "Monthly_Wage" = rep(c("Monthly_Wage") , 2)
    )
    value <- switch(input$radios_1,
                    "Annual_Wage" = c(colMeans(male[,1], na.rm=TRUE), colMeans(female[,1], na.rm=TRUE)),
                    "Monthly_Wage" = c(colMeans(male[,4], na.rm=TRUE), colMeans(female[,4], na.rm=TRUE))
                    )
    wages <- data.frame(genders,condition,value)
  })
  
  datasetInput2 <- reactive({
    employer <- switch(input$radios_2,
                       "Boston" = c("City of Boston", "City Of Boston"),
                       "Cambridge" = c("City of Cambridge", "City Of Cambridge"),
                       "Brockton" = c("City of Brockton", "City Of Brockton"),
                       "Lynn" = c("City of Lynn", "City Of Lynn"),
                       "Springfield" = c("City of Springfield", "City Of Springfield")
    )
  })
  
  datasetInput3 <- reactive({
    data$Race[data$Race == 'W_NL'] <- 'White'
    data$Race[data$Race == 'B_NL'] <- 'Black'
    data$Race[data$Race == 'HL'] <- 'Hispanic/Latin'
    data$Race[data$Race == 'A'] <- 'Asian'
    PlotData <- data[data$Race %in% input$checkboxes_3, ]
  })
  
  datasetInput4 <- reactive({
    data$Job_Title[(data$Job_Title %like% '%Detect%')] <- 'Detective'
    data$Job_Title[(data$Job_Title %like% '%Lieut%')] <- 'Lieutenant'
    data$Job_Title[(data$Job_Title %like% '%Serg%') | (data$Job_Title %like% '%serg%')] <- 'Sergeant'
    data$Job_Title[(data$Job_Title %like% '%Cap%')] <- 'Captain'
    data$Job_Title[(data$Job_Title %like% '%Dir%')] <- 'Director'
    data$Job_Title[(data$Job_Title %like% '%Commi%')] <- 'Commissioner'
    data$Job_Title[(data$Job_Title %like% '%Off%')] <- 'Officer'
    data$Job_Title[(data$Job_Title %like% '%Detect%')==FALSE & (data$Job_Title %like% '%Lieut%') == FALSE &(data$Job_Title %like% '%Serg%') == FALSE &
                     (data$Job_Title %like% '%serg%') == FALSE & (data$Job_Title %like% '%Cap%') == FALSE & (data$Job_Title %like% '%Dir%') == FALSE & 
                     (data$Job_Title %like% '%Commi%') == FALSE & (data$Job_Title %like% '%Off%') == FALSE & is.na(data$Job_Title) == FALSE] <- 'Others'
    
    PlotData <- data[data$Job_Title %in% input$checkboxes_4, ]
  })
  
  datasetInput5 <- reactive({
    PlotData <- data[data$Year == input$slider_5, ]
  })
  
  datasetInput6 <- reactive({
    MAcounties <- map_data("county", region='massachusetts')
    cities <- us.cities[(us.cities$name == 'Boston MA') | (us.cities$name == 'Brockton MA') | 
                          (us.cities$name == 'Cambridge MA') | (us.cities$name == 'Lynn MA') | 
                          (us.cities$name == 'Springfield MA'), ]
    data$Employer[(data$Employer == 'City Of Boston') | (data$Employer == 'City of Boston')] <- 'Boston MA'
    data$Employer[(data$Employer == 'City Of Brockton') | (data$Employer == 'City of Brockton')] <- 'Brockton MA'
    data$Employer[(data$Employer == 'City Of Cambridge') | (data$Employer == 'City of Cambridge')] <- 'Cambridge MA'
    data$Employer[(data$Employer == 'City Of Lynn') | (data$Employer == 'City of Lynn')] <- 'Lynn MA'
    data$Employer[(data$Employer == 'City Of Springfield') | (data$Employer == 'City of Springfield')] <- 'Springfield MA'
    average <- data %>%
      group_by(Employer) %>%
      summarize(Mean = mean(Annual_Wage, na.rm=TRUE))
    cities <- inner_join(cities, average, by = c("name"="Employer"))
  })
  
  datasetInput7 <- reactive({
    # initial
    INPUT <- matrix(0, 1, 19)
    # year
    INPUT[1] <- (input$year - 2016.5) / sqrt(5)
    # gender
    INPUT[2] <- ifelse(input$gender == "male", -1, 1)
    # city
    if (input$city == 'Boston') {
      INPUT[3] <- 1
    }
    else if (input$city == 'Brockton') {
      INPUT[4] <- 1
    }
    else if (input$city == 'Cambridge') {
      INPUT[5] <- 1
    }
    else if (input$city == 'Lynn') {
      INPUT[6] <- 1
    }
    else if (input$city == 'Springfield') {
      INPUT[7] <- 1
    }
    # title
    if (input$title == 'Lieutenant') {
      INPUT[8] <- 1
    }
    else if (input$title == 'Sergeant') {
      INPUT[9] <- 1
    }
    else if (input$title == 'Captain') {
      INPUT[10] <- 1
    }
    else if (input$title == 'Officer') {
      INPUT[11] <- 1
    }
    else if (input$title == 'Detective') {
      INPUT[12] <- 1
    }
    else if (input$title == 'Others') {
      INPUT[13] <- 1
    }
    else if (input$title == 'Commissioner') {
      INPUT[14] <- 1
    }
    else if (input$title == 'Director') {
      INPUT[15] <- 1
    }
    # Ethnics
    if (input$race == 'Black') {
      INPUT[17] <- 1
    }
    else if (input$race == 'White') {
      INPUT[16] <- 1
    }
    else if (input$race == 'Latin') {
      INPUT[18] <- 1
    }
    else if (input$race == 'Asian') {
      INPUT[19] <- 1
    }
    
    PROCESSED <- INPUT %*% as.matrix(rotation[, 1:15])
    WEIGHTS <- matrix(c(-2533.130, -211.215, 44.628, 53.110, 1161.727, -422.439, 22.454, 18.651, 125.202, -29.083, -3.022, -260.594, -816.033, -399.871, 734.638), nrow = 15, ncol = 1)
    RESULT <- PROCESSED %*% WEIGHTS
    RESULT <- -1 * RESULT[1][1] + 7975.508
  })
  
  datasetInput8 <- reactive({
    data <- 12 * datasetInput7() - 96
  })
  
  # Grouped
  output$barplot <- renderPlot({
    ggplot(datasetInput1(), aes(fill=genders, y=value, x=condition)) + 
      geom_bar(position="dodge", stat="identity") +  labs(y = "Wage", x="")
  })
  
  output$histogram <- renderPlot({
    options(repr.plot.width = 12, repr.plot.height = 6)
    layout(matrix(c(1,1,1,1,1,2,3,4,5,6), 2, 5, byrow = TRUE), heights=c(1,1), widths=c(1,1,1,1,1))
    ggplot(data[data$Employer %in% datasetInput2(), ], aes(x=Annual_Wage)) +
      geom_histogram(position="identity", alpha=0.5, bins=20) + 
      ggtitle(datasetInput2())
  })
  
  output$violin <- renderPlot({
    options(repr.plot.width = 6, repr.plot.height = 6)
    ggplot(datasetInput3(), aes(x=Race, y=Annual_Wage, fill=Race)) + geom_violin()
  })
  
  output$box <- renderPlot({
    options(repr.plot.width = 8, repr.plot.height = 8)
    ggplot(datasetInput4(), aes(x=Job_Title, y=Annual_Wage)) + 
      geom_boxplot() + 
      ggtitle("Cops' Salaries between Different Positions") +
      theme(legend.position="none") +
      scale_fill_brewer(palette="Dark2")
  })
  
  output$scatter <- renderPlot({
    datasetInput5() %>%
      ggplot( aes(x=Year, y=Annual_Wage, fill=Year, group=Year)) +
      geom_boxplot() +
      scale_fill_viridis(discrete = FALSE, alpha=0.6) +
      geom_jitter(color="pink", size=0.4, alpha=0.9) +
      # theme_ipsum() +
      theme(
        legend.position="none",
        plot.title = element_text(size=11)
      ) +
      ggtitle("Cops' Salaries over Years") +
      xlab("")
  })
  
  output$mymap <- renderLeaflet({
    pal <- colorNumeric(
      palette = c('gold', 'orange', 'dark orange', 'orange red', 'red'),
      domain = datasetInput6()$Mean)
    output$mymap <- renderLeaflet({
      leaflet(data) %>% 
        setView(lng = -71.3824, lat = 42.4072, zoom = 7)  %>% #setting the view over ~ center of North America
        addTiles() %>%
        addCircles(data = datasetInput6(), weight = 1, 
                   radius = ~sqrt(Mean)*30, popup = ~as.character(Mean), 
                   label = ~as.character(paste0("Magnitude: ", sep = " ", Mean)), 
                   color = ~pal(Mean), fillOpacity = 0.5)
    })
  })
  
  output$monthly <- renderText({
   paste(datasetInput7())
  })
  
  output$annual <- renderText({
    paste(datasetInput8())
  })
}

shinyApp(ui, server)
