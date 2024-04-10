library(tidyverse)
library(readr)
library(plotly)

# Read in datasets
modern_renewable_energy <- read_csv("dataset/renewable-share-energy.csv")

# Convert year to numeric if it's not already
modern_renewable_energy$Year <- as.numeric(modern_renewable_energy$Year)

# Create a ggplot object for the line graph
p <- ggplot(modern_renewable_energy, aes(x = Year, y = `Renewables (% equivalent primary energy)`, group = Entity, color = Entity)) +
  geom_line() + # Add a line for each country
  theme_minimal() +
  labs(title = "Renewable Energy Share by Country Over the Years",
       x = "Year",
       y = "Renewable Energy Share (%)")

# Convert ggplot object to a plotly object
p_interactive <- ggplotly(p)

# Enable user to select which entities to display
p_interactive %>% layout(dragmode = "select")
