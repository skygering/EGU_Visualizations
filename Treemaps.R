library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(treemapify)
library(gganimate)
library(magick)
require(gridExtra)
library(RColorBrewer)

colors3<- c("#332288", "#88CCEE", "#117733", "#999933","#DDCC77", "#DDDDDD", "#44AA99")
label_names <- c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked")

year_start = 1850
type = "atmos_c"

csv <- read.csv("hector/inst/output/tracking_rcp85.csv", header=TRUE)
csv %>% filter(pool_name == type) -> csv_type
csv_type %>% filter(year > year_start) -> csv_year

# Create data
year  <- csv_year$year
frames <- csv_year$year - min(csv_year$year)
source <-csv_year$source_fraction
value <-  csv_year$pool_value
group <-  csv_year$source_name
pie_data <- data.frame(year, group, source)
line_data <- data.frame(year, value)

data_names <- c("atmos_c", "detritus_c_global", "veg_c_global", "soil_c_global", "earth_c", "ocean_c", "untracked")
label_names <- c("Atmosphere", "Detritus", "Vegetation", "Soil", "Fossil Fuels", "Ocean", "Untracked")

pie_plot <- ggplot(pie_data, aes(x="", y=source, fill=group)) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void()  + 
  ggtitle("Origin of Carbon in Atmosphere by Percent") +
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  labs(fill = "Origin Pools") +
  transition_states(
      year,
      transition_length = 1,
      state_length = 1)



line_plot <- ggplot(line_data, aes(x=year, y=value)) +
  geom_line() +
  geom_point() +
  ggtitle("Total Carbon in Atmosphere") +
  ylab("Total Carbon (PgC)") +
  xlab ("Time (Year)") +
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  transition_reveal(year)



pie_gif <- animate(pie_plot, nframes = length(unique(year)), duration = 15, width = 500, height = 400, renderer = gifski_renderer())
line_gif <-animate(line_plot, nframes = length(unique(year)), duration = 15, width = 500, height = 400, renderer = gifski_renderer())

pie_mgif <- image_read(pie_gif)
line_mgif <- image_read(line_gif)
final_gif <- image_append(c(pie_mgif[1], line_mgif[1]), stack = TRUE)
for(i in 2:length(unique(year))){
  combined <- image_append(c(pie_mgif[i], line_mgif[i]), stack = TRUE)
  final_gif <- c(final_gif, combined)
}
#anim_save("atmos.gif", animation = last_animation(), path="Documents/EGU")
image_write(final_gif, path = "Documents/EGU/atmos.gif", format = "gif")