# main.R

library(tidyverse)
library(readr)
library(plotly)
library(shiny)

# Source the module scripts
source('R1.R')
source('R2.R')
source('R3.R')


# Define the UI
ui <- fluidPage(
  titlePanel("Energy Data Visualizations"),
  tabsetPanel(
    tabPanel("Renewable Energy Map", map_ui("map")),
    tabPanel("Renewable vs Non-Renewable Energy", line_graph_ui("linegraph")),
    tabPanel("Renewable Energy Generation by Country Map", map_piechart_ui("map1")),
  )
)

# Define the server logic
server <- function(input, output, session) {
  map_server("map")
  line_graph_server("linegraph")
  map_piechart_server("map1")
}

# Run the application
shinyApp(ui = ui, server = server)