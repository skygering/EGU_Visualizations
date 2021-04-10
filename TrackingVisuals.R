library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gganimate)
library(tidyverse)
library(RColorBrewer)

colors <- c("#1B9E77", "#D95F02", "#88419D", "#E7298A", "#7570B3","#66A61E", "#E6AB02","#666666")
colors2 <- c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3", "#A6D854", "#7570B3",
             "#E5C494", "#B3B3B3")
colors3<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")

change_data_names<- function(data, original, new){
  data %>% mutate(source_name = ifelse(source_name == original, new, as.character(source_name))) -> data
}

pool_val <- function(pool){
  pool$source_fraction * pool$pool_value
}

pool_data <- function(pool, pool_value){
  data.frame("year" = pool$year, "value" = pool_value, "group" = pool$source_name)
}

plot_pool <- function(data, title, colors){
  data %>%
  mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) %>%
  ggplot(aes(x=year, y=value, fill=group)) +
    geom_area() + ggtitle(title) + labs(y="Carbon (PgC)", x = "Year", fill="Carbon Origin Pools") +
    theme(plot.title = element_text(hjust = 0.5)) + scale_fill_manual(values = colors)+ 
    theme(plot.background = element_rect(fill = "white"), 
          panel.background = element_rect(fill = "white"),
          panel.grid.minor = element_line(colour = "gray", linetype = "dotted"),
          panel.grid.major = element_line(colour = "gray"))
}

clean_data_plot_pool <- function(data, pname, plot_title, plot_colors){
  data %>% filter(pool_name == pname) -> pool
  pvalue <- pool_val(pool) 
  pdata <- pool_data(pool, pvalue)
  plot_pool(pdata, plot_title, plot_colors)
}


read.csv("hector/inst/output/tracking_rcp85.csv", header=TRUE) %>% filter(pool_name != "Diff") %>%
  change_data_names("atmos_c", "Atmosphere") %>%
  change_data_names("detritus_c_global", "Detritus") %>%
  change_data_names("veg_c_global", "Vegetation") %>%
  change_data_names("soil_c_global", "Soil") %>%
  change_data_names("earth_c", "Fossil Fuels") %>%
  change_data_names("ocean_c", "Ocean") %>%
  change_data_names("untracked", "Untracked") ->csv

clean_data_plot_pool(csv, "atmos_c", "Atmosphere Proportions Over Time", colors3)
clean_data_plot_pool(csv, "soil_c_global", "Soil Proportions Over Time", colors3)
clean_data_plot_pool(csv, "veg_c_global", "Vegetation Proportions Over Time", colors3)
clean_data_plot_pool(csv, "detritus_c_global", "Detritus Proportions Over Time", colors3)
clean_data_plot_pool(csv, "ocean_c", "Ocean Proportions Over Time", colors3)

# top of ocean is a special case
csv %>% filter(pool_name == "ocean_c") -> ocean
ocean_added <- ocean[(ocean$source_name != "Ocean"),]
ocean_added_value <- pool_val(ocean_added)
ocean_added_data <- pool_data(ocean_added, ocean_added_value)
ocean_added_plot <- plot_pool(ocean_added_data, "Ocean Uptake Proportions Over Time", colors3)
  


