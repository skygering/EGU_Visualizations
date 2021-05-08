# Written by: Skylar Gering April 2021

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gganimate)
library(tidyverse)
library(RColorBrewer)

source("EGU_Visualizations/cleanData.R")

# Color blind friendly color palette with "natural" color scheme 
natural_colors<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")

# Inputs:
file_name = "hector/inst/output/tracking_rcp85.csv"
RCP = "RCP 8.5"

# Theme for plots - purely aesthetic
theme_track <- function(){
    theme(plot.title = element_text(hjust = 0.5, size=15, face="bold"),
          plot.background = element_rect(fill = "white"),
          panel.background = element_rect(fill = "white"),
          panel.grid.minor = element_line(colour = "gray", linetype = "dotted"),
          panel.grid.major = element_line(colour = "gray"),
          axis.text=element_text(size=13),
          axis.title=element_text(size=15,face="bold"),
          legend.title=element_text(size=13,face="bold"), 
          legend.text=element_text(size=13),
          legend.key=element_blank()
          )
}

# Separates data for one pool and creates data frame with year, origin pool size in PgC, and source pool name
# Input: data frame with multiple pools and string name of pool to separate
# Output: data frame of just 'pname' pool data
create_pool_data <- function(data, pname){
  data %>% filter(pool_name == pname) -> pool
  pvalue <- pool$source_fraction * pool$pool_value 
  pdata <- data.frame("year" = pool$year, "value" = pvalue, "group" = pool$source_name)
}

# Plots pool 
#Input: pool data frame, string title for plot, vector of colors
plot_pool <- function(data, title, colors){
  data %>%
    # Changes the order to carbon pools for aesthetic reasons
    mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) %>%
    ggplot(aes(x=year, y=value, fill=group)) +
    geom_area() + ggtitle(title) + labs(y="Carbon Storage (PgC)", x = "Time (Year)", fill="Carbon Origin Pools") +
    scale_fill_manual(values = colors) + theme_track()
}


# cleans CSV - function in cleanData.R
csv <- clean_hector_csv(file_name)

#creation and plotting of Hector pools
atmos_data <- create_pool_data(csv, "Atmosphere")
plot_pool(atmos_data, paste("Atmosphere Carbon Origins:", RCP), natural_colors)
soil_data <- create_pool_data(csv, "Soil")
plot_pool(soil_data, paste("Soil Carbon Origins:", RCP), natural_colors)
veg_data <- create_pool_data(csv, "Vegetation")
plot_pool(veg_data, paste("Vegetation Carbon Origins:", RCP), natural_colors)
det_data <- create_pool_data(csv, "Detritus")
plot_pool(det_data, paste("Detritus Carbon Origins:", RCP), natural_colors)
ocean_data <- create_pool_data(csv, "Ocean")
ocean_plot<-plot_pool(ocean_data, paste("Ocean Carbon Origins:", RCP), natural_colors)
ocean_plot

# top of ocean is a special case - need to only look at top of ocean plot
csv %>% filter(pool_name == "Ocean") -> ocean
ocean_min <- min(ocean$pool_value) # min and max of total carbon in the ocean pool
ocean_max <- max(ocean$pool_value)
top_ocean <- ocean_plot + coord_cartesian(ylim= c(ocean_min, ocean_max))
top_ocean

# Plotting size of carbon pools over time - exclude ocean and fossil fuels
# Ocean is too big, fossil fuels are not 'natural' carbon pool
csv %>% filter(pool_name != "Ocean") %>% filter(pool_name != "Fossil Fuels") %>%
ggplot(aes(x=year, y=pool_value)) +
  geom_line(aes(colour=pool_name), size = 1.3) +
  ggtitle(paste("Carbon Pool Values", RCP)) + 
  labs(color="Carbon Origin Pools", y="Carbon (PgC)", 
       x = "Time (Year)") +
  scale_color_manual(values = natural_colors) + theme_track()


