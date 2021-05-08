# Written by: Skylar Gering April 2021

library(plyr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(treemap)

source("EGU_Visualizations/cleanData.R")


plot_year = 2100

natural_colors<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")

# Create a treemap of a given pool in time 'pyear' in pool 'name' with the title 'plot_title'
# Input: string 'name' of pool that we are creating tree map of in year'pyear' and with the title 'plot_title'
# Output: tree map
make_treemap <- function(name, plot_title, pyear){
  csv %>% filter(year == pyear) %>% filter(pool_name == name) -> pool_data
  data.frame(group = pool_data$source_name, value = pool_data$source_fraction*pool_data$pool_value) %>%
  # Changes the order to carbon pools for aesthetic reasons
  mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) -> pool_frame

  treemap(pool_frame,
          index="group",
          vSize="value",
          type = "index", 
          palette = natural_colors,
          title = plot_title, 
          fontsize.title=35,
          position.legend = "bottom",
          fontsize.labels = 0,
          fontsize.legend = 23)  
}

# cleans CSV - function in cleanData.R
csv <- clean_hector_csv(file_name)

# creates treemaps of largest carbon storage pools
make_treemap("Atmosphere", paste("Atmosphere Pool by Origin in", plot_year), plot_year)
make_treemap("Soil", paste("Soil Pool by Origin in", plot_year), plot_year)
make_treemap("Vegetation", paste("Vegetation Pool by Origin in", plot_year), plot_year)
make_treemap("Ocean", paste("Ocean Pool by Origin in", plot_year), plot_year)

