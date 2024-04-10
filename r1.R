library(shiny)
library(tidyverse)
library(readr)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(plotly)
library(countrycode)

# Read in and preprocess the dataset
modern_renewable_energy <- read_csv("dataset/modern-renewable-energy-consumption.csv") %>%
  mutate(Year = as.numeric(Year),
         Code = as.character(Code)) %>%
  filter(str_length(Code) == 3) %>%
  group_by(Code) %>%
  complete(Year = full_seq(Year, 1)) %>%
  fill(everything(), .direction = "updown") %>%
  ungroup() %>%
  mutate(total_generation = round(`Other renewables (including geothermal and biomass) electricity generation - TWh` +
                                    `Solar generation - TWh` + 
                                    `Wind generation - TWh` + 
                                    `Hydro generation - TWh`, 2))

# Function to create UI for the map component
map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("selected_year"), "Year:",
                choices = sort(unique(modern_renewable_energy$Year))),
    actionButton(ns("update"), "Update Map"),
    plotlyOutput(ns("energy_map"))
  )
}

# Function to create server logic for the map component
map_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Reactive expression for the selected year
    reactive_year <- reactiveVal()
    
    # Load world shapefile
    world <- ne_countries(scale = "medium", returnclass = "sf")
    
    observeEvent(input$update, {
      reactive_year(input$selected_year)
    })
    
    output$energy_map <- renderPlotly({
      # Check if the reactive_year has been set, otherwise use the default
      year_to_use <- reactive_year() %||% min(sort(unique(modern_renewable_energy$Year)))
      
      # Filter and calculate the total renewable electricity generation
      data_for_year <- modern_renewable_energy %>%
        filter(Year <= year_to_use) %>%
        group_by(Code) %>%
        summarize(total_generation = last(total_generation), .groups = 'drop') %>%
        ungroup()
      
      # Join the dataset with the world map
      world_map_for_year <- world %>%
        left_join(data_for_year, by = c("iso_a3" = "Code"))
      
      # Create the choropleth map for the selected year
      map_for_year <- ggplot(data = world_map_for_year) +
        geom_sf(aes(fill = total_generation), color = "white", size = 0.25) +
        scale_fill_viridis_c(name = "Total Renewable Energy (TWh)", labels = scales::comma) +
        labs(title = paste("Total Renewable Energy Generation in", year_to_use),
             caption = "Source: Modern Renewable Energy Consumption Dataset") +
        theme_minimal() +
        theme(legend.position = "bottom",
              plot.title = element_text(size = 20, face = "bold"),
              plot.caption = element_text(size = 8))
      
      # Convert ggplot object to plotly object for interactivity
      ggplotly(map_for_year)
    })
    
    # Initialize reactive_year with the first available year
    observe({
      updateSelectInput(session, "selected_year", 
                        choices = sort(unique(modern_renewable_energy$Year)))
      reactive_year(min(sort(unique(modern_renewable_energy$Year))))
    })
  })
}