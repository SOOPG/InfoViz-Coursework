# main.R

library(shiny)
library(tidyverse)
library(readr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(plotly)
library(countrycode)

# Define the user interfaces from R1 and R2 as functions
source('R1.R')
source('R2.R')

# UI
ui <- fluidPage(
  titlePanel("Energy Data Visualizations"),
  tabsetPanel(
    tabPanel("Renewable Energy Map", R1_ui()),  # Assuming R1_ui is a function returning R1's UI
    tabPanel("Renewable Energy Share", R2_ui()) # Assuming R2_ui is a function returning R2's UI
  )
)

# Server
server <- function(input, output, session) {
  R1_server(input, output, session)  # Assuming R1_server is a function with R1's server logic
  R2_server(input, output, session)  # Assuming R2_server is a function with R2's server logic
}

# Run the Shiny app
shinyApp(ui, server)