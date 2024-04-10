# R2.R

library(tidyverse)
library(readr)
library(plotly)

# Function to create UI for the line graph component
line_graph_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("line_graph"))
}

# Function to create server logic for the line graph component
line_graph_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Read in datasets
    modern_renewable_energy <- read_csv("dataset/renewable-share-energy.csv")
    
    # Convert year to numeric if it's not already
    modern_renewable_energy$Year <- as.numeric(modern_renewable_energy$Year)
    
    # Calculate non-renewable energy share
    modern_renewable_energy$`Non-Renewables (% equivalent primary energy)` <- 100 - modern_renewable_energy$`Renewables (% equivalent primary energy)`
    
    
    # Render the plotly line graph
    output$line_graph <- renderPlotly({
      # Create a ggplot object for the line graph
      p <- ggplot(modern_renewable_energy, aes(x = Year)) +
        geom_line(aes(y = `Renewables (% equivalent primary energy)`, group = Entity, color = Entity)) + # Add a line for each country's renewable energy
        geom_line(aes(y = `Non-Renewables (% equivalent primary energy)`, group = Entity, color = Entity), linetype = "dashed") + # Add a line for each country's non-renewable energy
        theme_minimal() +
        labs(title = "Renewable vs Non-Renewable Energy Share by Country Over the Years",
             x = "Year",
             y = "Energy Share (%)")
      
      # Convert ggplot object to a plotly object
      ggplotly(p) %>%
        layout(dragmode = "select")
    })
  })
}
