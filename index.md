# Lobster-ECOL Directory


## FVCOM Data Acquisition Methods

FVCOM is a modeling framework, and a number of datasets exist that are referred to off-handedly as "FVCOM". One 
example of this is "NECOFS", which is a specific application of FVCOM for the Northeast US.  

FVCOM data can be accessed a number of ways, with a number of data products available through THREDDS, a 
data catalogue managed by Dr. Chen's lab at UMASS Dartmouth. Accessing data products over the THREDDS server
connection can be difficult/troublesome because of the size of the files and the upload/download bottleneck
that restricts how much data that can be accessed per request.

For this project we ultimately ended up reaching out to the Chen lab directly, with a data request 
for surface and bottom temperature, and surface currents from their hindcast product spanning 1978-2019.

The following links show some efforts/demos to access various products over thredds. But know that we 
ultimately moved our core analyses to work from the data we requested directly.

[Downloading Daily Hindcast Data](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/fvcom_acquisition_approaches/FVCOM_Daily_Hindcast_Download.html)

[Processing Daily Hindcast Data from Hourly](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/fvcom_acquisition_approaches/GOM3_Hindcast_Daily_from_Hourly_Processing.html)

[Processing Daily NECOFS Forecast Data from Hourly](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/fvcom_acquisition_approaches/NECOFS_Daily_from_Hourly_Processing.html)


More recently it was shared with me that the hindcast data was available on AWS, so in the future I
would recommend accessing it from [there](https://registry.opendata.aws/fvcom_gom3/), which can be done like [this](https://github.com/OpenScienceComputing/umassd-fvcom/blob/main/fvcom_gom3_explore.ipynb).


## Introductory Data Exploration

The following links were some of my earlier explorations of accessing the various 
FVOCM data products, working with the FVCOM package, and trying to extract data. Most of these 
did not lead directly to anything used in final analyses.

[Area Subsetting in R with {FVCOM}](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/fvcom_general_methods/FVCOM_Area_Subsetting_Demo.html)

[Interpolation Methods for Point Coordinates](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/fvcom_general_methods/FVCOM_interpolation.html)

[Exploring Pre-Downloaded Monthly Hindcast File Contents and Structures](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/gmri_inventory_exploration/FVCOM_GMRI-Monthly-Inventory-Check.html)


### LOB-ECOL Regional Timeseries Data Processing

The next set of links step through the data preparation code used to prepare FVCOm-based products for the lobster
ecology project. These pre-processing steps include the preparation of regional timeseries, some investigation into
the Maine coastal current, and pulling FVCOM temperatures that coincide with point locations from survey programs.


[Processing Regional Daily Surface/Bottom Temperature Timeseries](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/FVCOM_Regional_Temperature_Timeseries.html)

[Extracting Interpolated FVCOM Temperatures for NEFSC+VTS Survey Locations](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/Survey_Locations_FVCOMTemp_Interpolation.html)

[Extracting GLORYS Temperatures for NEFSC + VTS Survey Locations](https://adamkemberling.github.io/Lobster-ECOL/R/GLORYS_prep/Survey_Locations_GLORYSTemp_extractions.html)

#### Maine Coastal Current Processing

There was a goal in the project to try and develop an indicator for alongshore flow of the Maine Coastal Current 
using surface current data from FVCOM.

The initial/primary approach we tested was using a PCA, and evaluating whether it matched the flow patterns we were interested in.
I ultimately felt that it did not faithfully measure alongshore flow, although it was correlated.

[Maine Coastal Current Exploratory Monthly PCA](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/MaineCoastalCurrent/MaineCoastalCurrent_Exploratory_PCA.html)

[Maine Coastal Current Daily](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/MaineCoastalCurrent/MCC_Daily_Workup.html)

[Maine Coastal Current Alongshore Flow PCA Validation](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/MaineCoastalCurrent/AlongshoreOffshore_MCC_EOF.html)

A recommendation was made to transition to measuring alongshore flow/flux directly along some transect. This link goes over some wire-framing for that approach.

[Maine Coastal Current Flux Transport Transects](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/MaineCoastalCurrent/MCC_transect_fluxtransport.html)


### LOB-ECOL Temperature Data Evaluation

As an aside, there was some interest in evaluating the difference in regional temperatures between FVCOM and a
second oceanographic dataset: GLORYS. The following two links go over some checks into what GLORYS showed for our area.

[GLORYs Regional Temperatures](https://adamkemberling.github.io/Lobster-ECOL/R/GLORYs_prep/GLORYs_Temp_Exposure.html)

[Regional FVCOM & GLORYs Surface/Bottom Timeseries Comparison](https://adamkemberling.github.io/Lobster-ECOL/R/FVCOM_prep/FVCOM_regional_Temp_Exposure.html)


# Regime Shift Evaluation

Our regime shift testing methods follow the work of Sergei Rodionov, and subsequent methodoloy suggestions. I've 
expanded on the work of Luca Stirnimann's 2019 paper, where they implemented STARS methods in R and incorporated 
the suggested prewhitening procedures. A copy of Stirnimann's repository [RSTARS](https://github.com/LStirnimann/rstars) 
was downloaded locally, and their functions were adapted to return results in a way that could be applied to many timeseries.

These adaptations to the rSTARS functions can be found in the [rstars-master directory](https://github.com/adamkemberling/Lobster-ECOL/tree/main/rstars-master)

[rstars support code](https://github.com/adamkemberling/Lobster-ECOL/tree/main/rstars-master)


Before committing to RSTARS, other regime shift methods were explored/documented here:

[Regime Shift Common Methods](https://adamkemberling.github.io/Lobster-ECOL/R/regime_tests/regime_shift_methods.html)

Ultimately, we settled on STARS as our methodology. The following links go over results 
from testing FVCOM and GLORYS timeseries for regime changes.

[FVCOM Temperature + Salinity Regime Shifts](https://adamkemberling.github.io/Lobster-ECOL/R/regime_tests/STARS_FVCOM.html)

[GLORYs Temperature + Salinity Regime Shifts](https://adamkemberling.github.io/Lobster-ECOL/R/regime_tests/STARS_GLORYS.html)

The next link looks at breaks in timeseries of the first and second principal components from surface current vector data
off the coast of Penobscot Bay.

[Maine Coastal Current PCA Regime Shifts](https://adamkemberling.github.io/Lobster-ECOL/R/regime_tests/MCC_rstars.html)

This last link is a summary of all the different regime shift results for various spatial scales across the NE US 
continental shelf, and uses data from FVCOM and ECODATA.

[Summary of Regime Shift Results for FVCOM & Ecodata Timeseries](https://adamkemberling.github.io/Lobster-ECOL/R/regime_tests/RegimeShiftSummary.html)


# DEMO Notebooks

Here are some demos of how I would recommend working with the FVCOM data we acquired from the Chen lab to perform some common tasks:

[Process a timeseries from a shapefile](https://adamkemberling.github.io/Lobster-ECOL/R/Farewell_Demos/FVCOM_to_Timeseries.html)

[Extract values for point locations, that interpolate from nearby nodes](https://adamkemberling.github.io/Lobster-ECOL/R/Farewell_Demos/FVCOM_for_Pointlocations.html)
