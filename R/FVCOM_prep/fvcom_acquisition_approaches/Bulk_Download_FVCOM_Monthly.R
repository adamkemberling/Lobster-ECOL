####  Dowloading FVCOM Monthly Files  ####



#### About:  ####
# FVCOM hindcast is available as monthly mean files
# the full timeseries spans a few model versions: GOM3, GOM4, GOM5



# This function will download monthly files to a detination folder using their
# access points in the UMASS Dartmouth THREDDS Catalog




# Function options
start_year <- 2017
end_year <- 2018

# Folder locations on box
gom3_dest_folder <- cs_path("res", "FVCOM/monthly_means/gom3_mon_means")
gom4_dest_folder <- cs_path("res", "FVCOM/monthly_means/gom4_mon_means")
gom5_dest_folder <- cs_path("res", "FVCOM/monthly_means/gom5_mon_means")






####  GOM3-FVCOM Monthly  ####


# For downloading 1978-2016 from GOM3
download_GOM3_FVCOM_monthly <- function(dest_folder, start_year, end_year){
  
  
  # Stop if the dates are incompatible
  if(start_year < 1978 | start_year > 2016){stop("Starting year (start_year) out of range for GOM3 availability (1978-2016).")}
  if(end_year < 1978 | start_year > 2016){stop("Ending year (end_year) out of range for GOM3 availability (1978-2016).")}
  
  # Build THREDDS Link Structure
  seaplan_hcast <- "http://www.smast.umassd.edu:8080//thredds/fileServer/models/fvcom/NECOFS/Archive/Seaplan_33_Hindcast_v1/monthly_mean/"
  gom3_base <- "gom3_monthly_mean_"
  
  
  # Assemble year/month structure for file names
  yrs <- c(start_year:end_year)
  mons <- c("01","02","03","04","05","06","07","08","09","10","11","12")
  
  # File names
  fnames <- map(yrs, ~str_c(gom3_base, .x, mons, ".nc") ) %>% unlist()
  
  # Now step through each one and download/save
  purrr::walk(fnames, function(file_name){
    
    # Build the download url and out paths for saving
    url_full <- str_c(seaplan_hcast, file_name)
    save_full <- str_c(dest_folder, file_name)
    
    # Download and save
    message(str_c("Downloading: ", file_name))
    download.file(
      url = url_full, 
      destfile = save_full)
  })
  
  
}





####  GOM4-FVCOM Monthly  ####


# For downloading 2018-2020 from GOM4
download_GOM4_FVCOM_monthly <- function(dest_folder, start_year, end_year){
  
  
  # Stop if the dates are incompatible
  if(start_year < 2018 | start_year > 2020){stop("Starting year (start_year) out of range for GOM3 availability (1978-2016).")}
  if(end_year < 2018 | start_year > 2020){stop("Ending year (end_year) out of range for GOM3 availability (1978-2016).")}
  
  # Build THREDDS Link Structure
  seaplan_hcast <- "http://www.smast.umassd.edu:8080//thredds/fileServer/models/fvcom/NECOFS/Archive/Seaplan_33_Hindcast_v1/monthly_mean/"
  gom4_base <- "gom4_monthly_mean_temp_"
  
  
  # Assemble year/month structure for file names
  yrs <- c(start_year:end_year)
  mons <- c("01","02","03","04","05","06","07","08","09","10","11","12")
  
  # File names
  fnames <- map(yrs, ~str_c(gom4_base, .x, mons, ".nc") ) %>% unlist()
  
  # Now step through each one and download/save
  purrr::walk(fnames, function(file_name){
    
    # Build the download url and out paths for saving
    url_full <- str_c(seaplan_hcast, file_name)
    save_full <- str_c(dest_folder, file_name)
    
    # Download and save
    message(str_c("Downloading: ", file_name))
    download.file(
      url = url_full, 
      destfile = save_full)
  })
  
  
}




####  GOM5-FVCOM Monthly  ####


# For downloading 2017 from GOM5
download_GOM5_FVCOM_monthly <- function(dest_folder, start_year, end_year){
  
  
  # Stop if the dates are incompatible
  if(start_year < 2017 | start_year > 2017){stop("Starting year (start_year) out of range for GOM3 availability (1978-2016).")}
  if(end_year < 2017 | start_year > 2017){stop("Ending year (end_year) out of range for GOM3 availability (1978-2016).")}
  
  # Build THREDDS Link Structure
  seaplan_hcast <- "http://www.smast.umassd.edu:8080//thredds/fileServer/models/fvcom/NECOFS/Archive/Seaplan_33_Hindcast_v1/monthly_mean/"
  gom5_base <- "gom5_monthly_mean_temp_"
  
  
  # Assemble year/month structure for file names
  yrs <- c(start_year:end_year)
  mons <- c("01","02","03","04","05","06","07","08","09","10","11","12")
  
  # File names
  fnames <- map(yrs, ~str_c(gom5_base, .x, mons, ".nc") ) %>% unlist()
  
  # Now step through each one and download/save
  purrr::walk(fnames, function(file_name){
    
    # Build the download url and out paths for saving
    url_full <- str_c(seaplan_hcast, file_name)
    save_full <- str_c(dest_folder, file_name)
    
    # Download and save
    message(str_c("Downloading: ", file_name))
    download.file(
      url = url_full, 
      destfile = save_full)
  })
  
  
}



#### Downloading a Complete Monthly Inventory  ####
# I broke it into 3 functions to be explicit about what years come from which version

# Clean up env, download
rm(dest_folder, start_year, end_year)
#download_GOM3_FVCOM_monthly(start_year = 1978, end_year = 2016, dest_folder = gom3_dest_folder) # the most files, was previously downloaded
download_GOM4_FVCOM_monthly(start_year = 2018, end_year = 2020, dest_folder = gom4_dest_folder)
download_GOM5_FVCOM_monthly(start_year = 2017, end_year = 2017, dest_folder = gom5_dest_folder)




####  Renaming to match online directory  ####
# This code fixes an inconsistency where file names did not explain what the data was or where it came from

# Renaming the inventory of GOM3 we have
old_files_long <- list.files(gom3_dest_folder, pattern = ".nc", full.names = T)
old_files_short <- list.files(gom3_dest_folder, pattern = ".nc", full.names = F)
new_files <- str_c(gom3_dest_folder, "gom3_monthly_mean_", old_files_short)

# Copy from old to new
file.copy(from = old_files_long, to = new_files)

# Remove the old
file.remove(old_files_long)
