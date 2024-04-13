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
    tabPanel("Renewable Energy Generation Map and Pie Chart", map_piechart_ui("map_piechart_module"))
  )
)

# Define the server logic
server <- function(input, output, session) {
  map_server("map")
  line_graph_server("linegraph")
  map_piechart_server("map_piechart_module")
}

# Run the application
shinyApp(ui = ui, server = server)