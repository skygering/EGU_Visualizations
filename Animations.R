library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(treemapify)
library(gganimate)
library(magick)
require(gridExtra)
library(RColorBrewer)

colors3<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#44AA99", "#DDDDDD")
year_start = 1850
type = "soil_c_global"

change_data_names<- function(data, original, new){
  data %>% mutate(source_name = ifelse(source_name == original, new, as.character(source_name))) -> data
}

read.csv("hector/inst/output/tracking_rcp85.csv", header=TRUE) %>% 
  filter(pool_name == type) %>%
  change_data_names("atmos_c", "Atmosphere") %>%
  change_data_names("detritus_c_global", "Detritus") %>%
  change_data_names("veg_c_global", "Vegetation") %>%
  change_data_names("soil_c_global", "Soil") %>%
  change_data_names("earth_c", "Fossil Fuels") %>%
  change_data_names("ocean_c", "Ocean") %>%
  change_data_names("untracked", "Untracked") -> csv_type

csv_type %>% filter(year >= year_start) -> csv_year

# Create data
year  <- csv_year$year
frames <- unique(csv_year$year - min(csv_year$year))
source <-csv_year$source_fraction
value <-  csv_year$pool_value
group <-  csv_year$source_name
combined_data <- data.frame(year, group, source, value)
pie_data <- data.frame(year, group, source)
line_data <- data.frame(year, value)

#data_names <- c("atmos_c", "detritus_c_global", "veg_c_global", "soil_c_global", "earth_c", "ocean_c", "untracked")
#label_names <- c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked")


  combined_data  %>%
  mutate(group = factor(group, levels=c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked"))) %>%
  ggplot(aes(x="", y=source, fill=group)) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void()  + 
  theme(plot.title = element_text(hjust = 0.5, size=30, face="bold"), 
        legend.title=element_text(size=25,face="bold"), 
        legend.text=element_text(size=25)) +
  transition_states(year) + 
  labs(fill = "Origin Pools", title = 'RCP 8.5 Soil Carbon Origins\n Year: {closest_state}') +
    scale_fill_manual(values = colors3)-> pie_plot


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
        transition_reveal(year) + scale_color_manual(values = colors3)



pie_gif <- animate(pie_plot, nframes = 900, duration = 20, width = 800, height = 500, renderer = gifski_renderer())
line_gif <-animate(line_plot, nframes = 900, duration = 20, width = 800, height = 500, renderer = gifski_renderer())

pie_mgif <- image_read(pie_gif)
line_mgif <- image_read(line_gif)
final_gif <- image_append(c(pie_mgif[1], line_mgif[1]), stack = TRUE)
for(i in 2:900){
  combined <- image_append(c(pie_mgif[i], line_mgif[i]), stack = TRUE)
  final_gif <- c(final_gif, combined)
}
#anim_save("atmos_with_year.gif", animation = last_animation(), path="Documents/EGU")
#anim_save("atmos_line.gif", animation = last_animation(), path="Documents/EGU")
image_write(final_gif, path = "Documents/EGU/soil_color.gif", format = "gif")
