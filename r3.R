library(tidyverse)
library(readr)
library(plotly)
library(shiny)
library(DT)

# Function to read and preprocess the dataset
prepare_data <- function() {
  read_csv("dataset/modern-renewable-prod.csv") %>%
    filter(str_length(Code) == 3) %>%
    arrange(Code, Year) %>%
    group_by(Code) %>%
    fill(`Electricity from wind - TWh`, `Electricity from hydro - TWh`, 
         `Electricity from solar - TWh`, `Other renewables including bioenergy - TWh`,
         .direction = "down") %>%
    ungroup() %>%
    mutate(Total_Renewable = `Electricity from wind - TWh` + `Electricity from hydro - TWh` + 
             `Electricity from solar - TWh` + `Other renewables including bioenergy - TWh`) %>%
    group_by(Code) %>%
    filter(Year == max(Year)) %>%
    summarise(
      Total_Wind = sum(`Electricity from wind - TWh`, na.rm = TRUE),
      Total_Hydro = sum(`Electricity from hydro - TWh`, na.rm = TRUE),
      Total_Solar = sum(`Electricity from solar - TWh`, na.rm = TRUE),
      Total_Other_Renewables = sum(`Other renewables including bioenergy - TWh`, na.rm = TRUE),
      Total_Renewable = sum(Total_Renewable, na.rm = TRUE)
    ) %>%
    ungroup()
}

# Define UI for map and pie chart
map_piechart_ui <- function(id) {
  ns <- NS(id)
  fluidRow(
    column(8, plotlyOutput(ns("choroplethMap"))),
    column(4, plotlyOutput(ns("pieChart")))
  )
}

# Server logic for interactive map and pie chart
map_piechart_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    data <- prepare_data()  # Load and prepare the data
    
    # Render the interactive choropleth map
    output$choroplethMap <- renderPlotly({
      plot_geo(data, locations = ~Code, z = ~Total_Renewable, text = ~Code,
               color = ~Total_Renewable, colors = "Blues") %>%
        layout(title = 'Click on a Country to Show its Renewable Energy Mix',
               geo = list(showcountries = TRUE))
    })
    
    # React to click events on the map to update the pie chart
    observeEvent(input$choroplethMap_click, {
      iso_code <- input$choroplethMap_click$pointData$location
      selected_data <- filter(data, Code == iso_code)
      output$pieChart <- renderPlotly({
        plot_ly(selected_data, labels = c("Wind", "Hydro", "Solar", "Other"),
                values = c(selected_data$Total_Wind, selected_data$Total_Hydro,
                           selected_data$Total_Solar, selected_data$Total_Other_Renewables),
                type = 'pie', textinfo = 'label+percent',
                insidetextorientation = 'radial') %>%
          layout(title = paste("Renewable Energy Mix for", iso_code))
      })
    })
  })
}