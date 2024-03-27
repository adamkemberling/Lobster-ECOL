# Maine Coastal Current Notes:

Just dropping some links/notes from Matt's foray into MCC work. 

I believe he used data from stat zones 511-513:
https://dzaugis.github.io/Ecosystem_Indicators/Code/MCC_Analysis.html#Developing_Indicators_of_Habitat_and_Ecosystem_Change_in_the_Gulf_of_Maine

The {fvcom} R package was used to get the data from the 30-year GOM3 hindcast.
https://github.com/dzaugis/Ecosystem_Indicators/blob/6d21e553614cb06eb7ea02e4546535cf038d7678/Code/FVCOM_shp_extract.Rmd#L30-L141 

Then monthly means were processed with the help of the FVCOM package:

For reference code on how temperature was accessed/processed: https://github.com/dzaugis/PhysOce/blob/de97bbf1b32bdd02b0879781f2dfae26bc73214a/Code/obs_sst_functions.R#L595-L703

Monthly Means were stored on Box. Once we had monthly means, Matt then iterated over them and pulled out the variables of interest using the first index of siglay for surface and the max for bottom.

https://github.com/dzaugis/Ecosystem_Indicators/blob/6d21e553614cb06eb7ea02e4546535cf038d7678/Code/FVCOM_shp_extract.Rmd#L30-L141 