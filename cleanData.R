# Written by: Skylar Gering April 2021

# Changes pool names and souces pool names from 'original' to 'new' name
# Input: data frame 'data', string 'original', string 'new'
# Output: data frame data updated so that any pools or source pools named 'original' are now named 'new'
change_data_names<- function(data, original, new){
  data %>% mutate(source_name = ifelse(source_name == original, new, as.character(source_name))) %>%
    mutate(pool_name = ifelse(pool_name == original, new, as.character(pool_name))) -> data
}

# Reads in Hector output and filters our temporary Diff variables and changes pool and 
# source pool names to "nice" looking names for legend and graph presentations
# Input: CSV file path string
# Output: New CSV with changed names and without Diff variables
clean_hector_csv<- function(csv_file){
  read.csv(csv_file, header=TRUE) %>% filter(pool_name != "Diff") %>%
    change_data_names("atmos_c", "Atmosphere") %>%
    change_data_names("detritus_c_global", "Detritus") %>%
    change_data_names("veg_c_global", "Vegetation") %>%
    change_data_names("soil_c_global", "Soil") %>%
    change_data_names("earth_c", "Fossil Fuels") %>%
    change_data_names("ocean_c", "Ocean") %>%
    change_data_names("untracked", "Untracked")->csv
}

