# EGU_Visualizations
Visualizations for EGU conference work on carbon tracking
# Hector Tracking Visualizations

These visualizations were developed for EGU 2021 conference work on carbon tracking in Hector ([PNNL's simple climate model](https://github.com/JGCRI/hector)) and general debugging of Hector's carbon tracking. 

Here are the different visualizations you can make using this code with examples of the output. 

### TrackingVisuals.R

#### Inputs:
You will need to have the file path of the Hector output CSV that you want to run. This will only work on the Hector tracking output CSVs, which have names like: "tracking_rcp85.csv". You also need to give the string name of the RCP run on Hector (e.g. "RCP 8.5") so this can be used in making the plot titles.

#### Outputs:
There are two types of visualizations that are made by running TrackingVisuals.R. The first is stacked area charts for the atmosphere, soil, vegetation, detritus, ocean, and top of the ocean (i.e. the new carbon added over the course of the run). Here is an example of the stacked area plot for atmosphere:

<img width="500" alt="Atmosphere Stacked Area" src="https://user-images.githubusercontent.com/60117338/117550492-8baab180-aff5-11eb-92c6-0474c7ed9cb9.png">

The second type of plot you get from running TrackingVisuals.R is the total size of the atmopshere, soil, vegetation, and detritus carbon pools. This is standard Hector output and meant to be compared to the stacked area plots. Here is the graph: 

<img width="500" alt="Size of Carbon Pools" src="https://user-images.githubusercontent.com/60117338/117550560-e6440d80-aff5-11eb-8c85-81f069ecf69b.png">

### PoolTreeMaps.R

#### Inputs:
This requires the filepath of the Hector output CSV that you want to run. This will only work on the Hector tracking output CSVs, which have names like: "tracking_rcp85.csv".  You also need to provide the year that you want the treemap generated for.

#### Outputs: 
This script creates treemaps for the atmosphere, soil, vegetation, and ocean pools for a given year. Here is what the atmosphere treemap looks like in year 2100:

<img width="500" alt="Atmosphere Treemap" src="https://user-images.githubusercontent.com/60117338/117550850-7898e100-aff7-11eb-9acb-8d476350337e.png">

The treemaps turn out quite large on the R plots screen so you may need to click on the 'Zoom' to see them at actual size with correct proportions to the legend. 

### Animations.R

#### Inputs:
In order to make this animation, there are considerably more inputs. First, like all of the other visualization scripts, it requires the filepath of the Hector output tracking CSV. It then additionally needs the type of the pool you want to create the visualization for, which is a string. The options are: "Atmosphere", "Soil", "Vegetation", and "Ocean". It also needs the string name of the RCP to create the appropriate title for the animation (e.g. "RCP 8.5"). Also, you need the year you want the animation to start in, as well as the width and height of the animation. A word of warning that the timing of these gifs is tricky to work out. The animated the pie charts require two frames per year while the line charts seem to fit their runtime to the number of frames requested. The timing works when we start at 1850, but other starting times have not been tested extensivley.

#### Outputs:
Here we have a gif that shows the size of the atmosphere pool and its composition over time.

<img width="350" alt="Atmosphere Gif" src="https://user-images.githubusercontent.com/60117338/117551196-5a33e500-aff9-11eb-82d3-d5f467dc1b81.gif">

### TrackingDiffs.R

#### Inputs:
This only needs a filepath of the Hector output tracking CSV.

#### Outputs:
This visual is used for debugging in the tracking design process, not for pretty visualizations. It shows the difference between the pools sizes after all fluxes are applied versus what Hector's ODE solver calcualtes as the size of the fluxes every timestep. This gives us an idea of how completly the fluxes we currently have implemented account for the change calculated by the solver for those same fluxes. Here is an example output from one point in the design process. As we can see some of the pools have values larger than those calculated by the ODE solver (like soil and atmosphere) and some have values smaller (like detritus). 

<img width="400" alt="Tracking Diffs" src="https://user-images.githubusercontent.com/60117338/117551435-d4189e00-affa-11eb-8dea-3736e6482c54.png">


### cleanData.R
This is not a visualization script, but rather a script that cleans the input CSVs to give them appropriate string names for printing in legends (e.g. "Atmsophere" instead of "atmos_c"). It also takes out the Diff variables (used above in TrackingDiffs.R).