# Written by: Skylar Gering April 2021

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(treemapify)
library(gganimate)
library(magick)
require(gridExtra)
library(RColorBrewer)
source("EGU_Visualizations/cleanData.R")

natural_colors<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")

# Animation specifics
type = "Soil"
RCP = "RCP 8.5"
year_start = 1850
anim_width = 800
anim_height = 500
save_path = paste("EGU_Visualizations/", type, ".gif")

# File name
file_name <- "hector/inst/output/tracking_rcp85.csv"

# cleans CSV and pulls out data for particular pool and years greater than 'year_start'
clean_hector_csv(file_name) %>% filter(pool_name == type) %>% filter(year >= year_start) -> csv_year

# Create data
year  <- csv_year$year
num_years <- length(unique(year))
#frames <- unique(csv_year$year - min(csv_year$year))
source <-csv_year$source_fraction
value <-  csv_year$pool_value
group <-  csv_year$source_name
combined_data <- data.frame(year, group, source, value)
#pie_data <- data.frame(year, group, source)
#line_data <- data.frame(year, value)

# Creating Pie Plot
  combined_data  %>%
  # orders data in aesthetic order
  mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) %>%
  # create pie plot using geom_bar with polar coordiantes
  ggplot(aes(x="", y=source, fill=group)) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void()  + 
  theme(plot.title = element_text(hjust = 0.5, size=30, face="bold"), 
        legend.title=element_text(size=25,face="bold"), 
        legend.text=element_text(size=25)) +
  transition_states(year) + 
  labs(fill = "Origin Pools", title = "Soil Carbon Origins\n Year: {closest_state}") +
    scale_fill_manual(values = natural_colors)-> pie_plot

# Creating Line Plot
  line_plot <- ggplot(combined_data, aes(x=year, y=value)) +
  geom_line() +
  geom_point() +
  ggtitle("Total Carbon in Soil") +
  ylab("Carbon Storage (PgC)") +
  xlab ("Time (Year)") +
  theme(legend.key = element_rect(fill="white"),
        axis.text=element_text(size=23),
        axis.title=element_text(size=25,face="bold"),
        plot.title=element_text(size=30,face="bold", hjust = 0.5),
        plot.background = element_rect(fill = "white"), 
        panel.background = element_rect(fill = "white"),
        panel.grid.minor = element_line(colour = "gray", linetype = "dotted"),
        panel.grid.major = element_line(colour = "gray")) +
        transition_reveal(year) + scale_color_manual(values = natural_colors)


# Animating pie and line plots
# Number of frames is 2* number of years due to pie plot needing two frames per year
# Might be limit on duration due to limit on frames per second
pie_gif <- animate(pie_plot, nframes = 2*num_years, duration = 20, width = anim_width, height = anim_height, renderer = gifski_renderer())
line_gif <-animate(line_plot, nframes = 2*num_years, duration = 20, width = anim_width, height = anim_height, renderer = gifski_renderer())

# Uses magick image gif to combine animations
# used ideas from: https://towardsdatascience.com/how-to-combine-animated-plots-in-r-734c6c952315
pie_mgif <- image_read(pie_gif)
line_mgif <- image_read(line_gif)
final_gif <- image_append(c(pie_mgif[1], line_mgif[1]), stack = TRUE)
for(i in 2:(2*num_years)){
  combined <- image_append(c(pie_mgif[i], line_mgif[i]), stack = TRUE)
  final_gif <- c(final_gif, combined)
}

#save final gif to 'save_path'
image_write(final_gif, path = save_path, format = "gif")
