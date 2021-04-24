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
  data %>% mutate(source_name = ifelse(source_name == original, new, as.character(source_name))) %>%
    mutate(pool_name = ifelse(pool_name == original, new, as.character(pool_name))) -> data
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
    geom_area() + ggtitle(title) + labs(y="Carbon Storage (PgC)", x = "Time (Year)", fill="Carbon Origin Pools") +
    theme(plot.title = element_text(hjust = 0.5)) + scale_fill_manual(values = colors)+ 
    theme(plot.background = element_rect(fill = "white"), 
          panel.background = element_rect(fill = "white"),
          panel.grid.minor = element_line(colour = "gray", linetype = "dotted"),
          panel.grid.major = element_line(colour = "gray"), 
          axis.text=element_text(size=13),
          axis.title=element_text(size=15,face="bold"),
          plot.title=element_text(size=15,face="bold"),
          legend.title=element_text(size=13,face="bold"), 
          legend.text=element_text(size=13)
          )
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
  change_data_names("untracked", "Untracked")->csv

clean_data_plot_pool(csv, "Atmosphere", "Atmosphere Carbon Origins: RCP 8.5", colors3)
clean_data_plot_pool(csv, "Soil", "Soil Carbon Origins: RCP 8.5", colors3)
clean_data_plot_pool(csv, "Vegetation", "Vegetation Carbon Origins: RCP 8.5", colors3)
clean_data_plot_pool(csv, "Detritus", "Detritus Carbon Origins: RCP 8.5", colors3)
ocean_plot <- clean_data_plot_pool(csv, "Ocean", "Ocean Carbon Origins: RCP 8.5", colors3)
ocean_plot

# top of ocean is a special case
csv %>% filter(pool_name == "Ocean") -> ocean
ocean_min <- min(ocean$pool_value)
ocean_max <- max(ocean$pool_value)
#ocean_added_data <- pool_data(ocean_added, ocean_added_value)
#ocean_added_plot <- plot_pool(ocean_added_data, "Ocean Uptake Proportions Over Time", colors3)
top_ocean <- ocean_plot + coord_cartesian(ylim= c(ocean_min, ocean_max))
top_ocean

csv %>% filter(pool_name != "Ocean") %>% filter(pool_name != "Fossil Fuels") %>%
ggplot(aes(x=year, y=pool_value)) +
  geom_line(aes(colour=pool_name), size = 1.3) +
  ggtitle("Carbon Pool Values: RCP 8.5") + 
  labs(color="Carbon Origin Pools", y="Carbon (PgC)", 
       x = "Time (Year)") + 
  theme(plot.background = element_rect(fill = "white"), 
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_line(colour = "gray", linetype = "dotted"),
        panel.grid.major = element_line(colour = "gray"), 
        legend.key = element_rect(fill="white"), 
        axis.text=element_text(size=13),
        axis.title=element_text(size=15,face="bold"),
        plot.title=element_text(size=15,face="bold", hjust = 0.5),
        legend.title=element_text(size=13,face="bold"), 
        legend.text=element_text(size=13)) +
        scale_color_manual(values = colors3)

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
    mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels"))) %>% #add in ocean and untracked
    ggplot(aes(x=year, y=value, fill=group)) +
    geom_area() + ggtitle(title) + labs(y="Carbon Storage (PgC)", x = "Year", fill="Carbon Origin Pools") +
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


