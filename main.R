# main.R

library(shiny)
library(tidyverse)
library(readr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(plotly)
library(countrycode)

# Source R1 and R2 scripts
source('R1.R')
source('R2.R')

# UI
ui <- fluidPage(
  titlePanel("Energy Data Visualizations"),
  tabsetPanel(
    tabPanel("Renewable Energy Map", map_ui("map1")),
    tabPanel("Renewable Energy Share Line Graph", line_graph_ui("line_graph1"))
  )
)

# Server
server <- function(input, output, session) {
  map_server("map1")
  line_graph_server("line_graph1")
}

# Run the application 
shinyApp(ui = ui, server = server)