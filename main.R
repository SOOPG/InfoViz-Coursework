# main.R

library(shiny)

# Ensure all required libraries are loaded
library(tidyverse)
library(readr)
library(plotly)
library(shiny)

# Source the module scripts
source('R1.R')
source('R2.R')

# Define the UI
ui <- fluidPage(
  titlePanel("Energy Data Visualizations"),
  tabsetPanel(
    tabPanel("Renewable Energy Map", map_ui("map")),
    tabPanel("Renewable vs Non-Renewable Energy", line_graph_ui("linegraph"))
  )
)

# Define the server logic
server <- function(input, output, session) {
  map_server("map")
  line_graph_server("linegraph")
}

# Run the application
shinyApp(ui = ui, server = server)