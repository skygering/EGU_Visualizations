library(plyr)
library(dplyr)
library(tidyr)
library(tidyverse)
library(treemap)

map_year = 2100
colors3<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")

change_data_names<- function(data, original, new){
  data %>% mutate(source_name = ifelse(source_name == original, new, as.character(source_name))) %>%
    mutate(pool_name = ifelse(pool_name == original, new, as.character(pool_name))) -> data
}

read.csv("hector/inst/output/tracking_rcp85.csv", header=TRUE) %>% 
  filter(pool_name != "Diff") %>%
  change_data_names("atmos_c", "Atmosphere") %>%
  change_data_names("detritus_c_global", "Detritus") %>%
  change_data_names("veg_c_global", "Vegetation") %>%
  change_data_names("soil_c_global", "Soil") %>%
  change_data_names("earth_c", "Fossil Fuels") %>%
  change_data_names("ocean_c", "Ocean") %>%
  change_data_names("untracked", "Untracked")->csv

make_treemap <- function(name, plot_title){
  csv %>% filter(year == 2100) %>% filter(pool_name == name) -> pool_data
  pool_data
  data.frame(group = pool_data$source_name, value = pool_data$source_fraction*pool_data$pool_value) %>% 
  mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) -> pool_frame

  plot <- treemap(pool_frame,
        index="group",
        vSize="value",
        type = "index", 
        palette = colors3,
        title = plot_title, 
        fontsize.title=35,
        position.legend = "bottom",
        fontsize.labels = 0,
        fontsize.legend = 23)  
}

make_treemap("Atmosphere", "Atmosphere Pool by Origin in 2100")
make_treemap("Soil", "Soil Pool by Origin in 2100")
make_treemap("Vegetation", "Vegetation Pool by Origin in 2100")
make_treemap("Ocean", "Ocean Pool by Origin in 2100")

