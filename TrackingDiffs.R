# Written by: Skylar Gering April 2021

library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(gganimate)
library(tidyverse)

csv <- read.csv("hector/inst/output/tracking_rcp85.csv", header=TRUE)
csv %>% filter(pool_name =="Diff") -> diffs

# Plots the difference in the pools from the value calculated by the ODE solver
# Used as a check for how well the fluxes match up with ODE solved pools
ggplot(data = diffs, aes(x=year, y=pool_value)) +
      geom_line(aes(colour=source_name)) +
      ggtitle("Difference in Pool from calcDerives Value") + 
      labs(y="PGC", x = "Year")
