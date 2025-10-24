####  FVCOM Support Functions  ####

# Flag the locations that are within the domains
mesh_trim <- function(mesh, domain){
  
  # Will remove these columns after st_join
  names_drop <- names(domain)[which(names(domain)!="geometry")] 
  new_mesh <- mesh %>%
    st_join(domain, join = st_within) %>% 
    drop_na() %>% 
    #dplyr::select(-all_of(names_drop)) 
    dplyr::select(elem, p1, p2, p3, geometry)
  return(new_mesh)
}








#' @title Load Monthly FVCOM Paths
#'
#' @param start_yr numeric starting year
#' @param end_yr numeric ending year
#' @param fvcom_folder Location to FVCOM on Boc gmRi::cs_path("res", "FVCOM/monthly_means")
#' @param fvcom_vers Which mesh version matches the years requested: GOM3 = 1978-2016, GOM5 = 2017, GOM4 = 2018-2020
#'
#' @return
#' @export
#'
#' @examples
monthly_fvcom_inventory <- function(
    start_yr  = 1978, 
    end_yr    = 2016, 
    fvcom_folder = cs_path("res", "FVCOM/monthly_means"), 
    fvcom_vers = "GOM3"){
    
    # Path structures
    # file name differences between versions
    version_name <- switch(
      fvcom_vers,
      "GOM3" = "gom3_mon_means/gom3_monthly_mean_",
      "gom3" = "gom3_mon_means/gom3_monthly_mean_",
      "GOM4" = "gom4_mon_means/gom4_monthly_mean_temp_",
      "gom4" = "gom4_mon_means/gom4_monthly_mean_temp_",
      "GOM5" = "gom5_mon_means/gom5_monthly_mean_temp_",
      "gom5" = "gom5_mon_means/gom5_monthly_mean_temp_"
    )
    
    
    # Year and month components
    yrs <- start_yr:end_yr
    mons <- str_pad(1:12, side = "left", width = 2, pad = "0")
    date_labs <- map(yrs, ~str_c(.x, mons)) %>% unlist()
    file_list <- str_c(fvcom_folder, version_name, date_labs, ".nc")
    file_list <- setNames(file_list, date_labs)
    return(file_list)
}





# This was working, but I refactored so I could generate monthly inventory easier using inventory function,
#then just use that again here



#' @title Summarize Monthly FVCOM for Mesh Subset
#' 
#' 
#' @description Grabs surface and bottom measurements from fvcom data stored on box,
#' averages them across the full time dimension of each file, and returns the whole thing
#' as one timeseries with date, and surface/bottom measures for each variable
#' 
#' Performs these steps for GOM3, for 1978-2020
#'
#' @param start_yr starting year for range of dates
#' @param end_yr ending year for range of dates
#' @param mesh fvcom mesh sf object created with {fvcom} to determine nodes
#' @param folder path to folder where fvcom files are stored
#' @param var_names c() of variable names to grab at surface and bottom
#'
#' @return
#' @export
#'
#' @examples
local_fvcom_to_timeseries <- function(
    start_yr  = 1978, 
    end_yr    = 2016, 
    mesh      = vts_mesh, 
    fvcom_folder = cs_path("res", "FVCOM/FVCOM_gom3_mon_means"), 
    fvcom_vers = "GOM3",
    var_names = c("temp", "salinity")){
  
 
  # Get the files
  file_list <- monthly_fvcom_inventory(
    start_yr  = start_yr, 
    end_yr    = end_yr, 
    fvcom_folder = fvcom_folder, 
    fvcom_vers = fvcom_vers)
  
  # Map through the file paths and get the monthly averages as a dataframe
  monthly_vars <- imap_dfr(
    file_list,
    possibly(
      .f = function(fpath, date_info){
        
        # Open (lazy-load) the netcdf connection
        x <- nc_open(fpath)
        
        # Time dimension info
        time_dim <- fvcom_time(x)
        
        # Grab surface variables
        surface_vars <- get_mesh(
          x, # Dataset lazyloaded with ncdf4 from THREDDS 
          y = 1, # integer, or indices for siglay or siglev (depth indices)
          vars = var_names,  # Variables we want
          mesh = mesh, # Mesh to get them for
          time = c(1:length(time_dim))) # All time intervals
        
        # Grab Bottom Variables
        bottom_vars <- get_mesh(
          x, 
          y = dim(ncvar_get(x, "siglay"))[2], # Bottom depth layer
          vars = var_names, 
          mesh = mesh, 
          time = c(1:length(time_dim))) # All time intervals
        
        # regrid and get means
        surface_vars <- raster::stack(
          sapply(
            var_names, 
            function(f) { fvcom::rasterize(surface_vars, field = f) }, 
            simplify = FALSE)) %>% 
          cellStats(mean, na.rm = T) %>% 
          t() %>% 
          as.data.frame() %>% 
          setNames(str_c("surf_", names(.)))
        
        # and regrid the bottom
        bottom_vars <- raster::stack(
          sapply(
            var_names, 
            function(f) { fvcom::rasterize(bottom_vars, field = f) }, 
            simplify = FALSE)) %>% 
          cellStats(mean, na.rm = T) %>% 
          t() %>% 
          as.data.frame() %>% 
          setNames(str_c("bot_", names(.)))
        
        # Combine
        month_summs <- bind_cols(surface_vars, bottom_vars)
        
        # Close connection:
        nc_close(x)
        
        # Return the table
        return(month_summs)
      }, 
      # Spit out NA's if there's trouble
      otherwise = data.frame(
        "surf_temp" = NA, 
        "surf_salinity" = NA, 
        "bot_temp" = NA,
        "bot_salinity" = NA)), 
    .id = "date")
  
}



#' #' @title Summarize Monthly FVCOM for Mesh Subset
#' #' 
#' #' 
#' #' @description Grabs surface and bottom measurements from fvcom data stored on box,
#' #' averages them across the full time dimension of each file, and returns the whole thing
#' #' as one timeseries with date, and surface/bottom measures for each variable
#' #' 
#' #' Performs these steps for GOM3, for 1978-2020
#' #'
#' #' @param start_yr starting year for range of dates
#' #' @param end_yr ending year for range of dates
#' #' @param mesh fvcom mesh sf object created with {fvcom} to determine nodes
#' #' @param folder path to folder where fvcom files are stored
#' #' @param var_names c() of variable names to grab at surface and bottom
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples
#' local_fvcom_to_timeseries <- function(
#'     start_yr  = 1978, 
#'     end_yr    = 2016, 
#'     mesh      = vts_mesh, 
#'     folder    = cs_path("res", "FVCOM/FVCOM_gom3_mon_means"), 
#'     fvcom_vers = "GOM3",
#'     var_names = c("temp", "salinity")){
#'   
#'   # Path structures
#'   box_fvcom <- folder
#'   # file name differences between versions
#'   version_name <- switch(
#'     fvcom_vers,
#'     "GOM3" = "gom3_monthly_mean_",
#'     "gom3" = "gom3_monthly_mean_",
#'     "GOM4" = "gom4_monthly_mean_temp_",
#'     "gom4" = "gom4_monthly_mean_temp_",
#'     "GOM5" = "gom5_monthly_mean_temp_",
#'     "gom5" = "gom5_monthly_mean_temp_"
#'   )
#'   
#'   
#'   # Year and month components
#'   yrs <- start_yr:end_yr
#'   mons <- str_pad(1:12, side = "left", width = 2, pad = "0")
#'   file_list <- map(yrs, ~str_c(version_name, .x, mons)) %>% unlist()
#'   file_list <- setNames(file_list, file_list)
#'   
#'   # Map through the file paths and get the monthly averages as a dataframe
#'   monthly_vars <- imap_dfr(
#'     file_list,
#'     possibly(
#'       .f = function(date_info, file_time){
#'         
#'         # Build the full path to the netcdf file
#'         fpath <- str_c(box_fvcom, date_info, ".nc")
#'         
#'         # Open (lazy-load) the netcdf connection
#'         x <- nc_open(fpath)
#'         
#'         # Time dimension info
#'         time_dim <- fvcom_time(x)
#'         
#'         # Grab surface variables
#'         surface_vars <- get_mesh(
#'           x, # Dataset lazyloaded with ncdf4 from THREDDS 
#'           y = 1, # integer, or indices for siglay or siglev (depth indices)
#'           vars = var_names,  # Variables we want
#'           mesh = mesh, # Mesh to get them for
#'           time = c(1:length(time_dim))) # All time intervals
#'         
#'         # Grab Bottom Variables
#'         bottom_vars <- get_mesh(
#'           x, 
#'           y = dim(ncvar_get(x, "siglay"))[2], # Bottom depth layer
#'           vars = var_names, 
#'           mesh = mesh, 
#'           time = c(1:length(time_dim))) # All time intervals
#'         
#'         # regrid and get means
#'         surface_vars <- raster::stack(
#'           sapply(
#'             var_names, 
#'             function(f) { fvcom::rasterize(surface_vars, field = f) }, 
#'             simplify = FALSE)) %>% 
#'           cellStats(mean, na.rm = T) %>% 
#'           t() %>% 
#'           as.data.frame() %>% 
#'           setNames(str_c("surf_", names(.)))
#'         
#'         # and regrid the bottom
#'         bottom_vars <- raster::stack(
#'           sapply(
#'             var_names, 
#'             function(f) { fvcom::rasterize(bottom_vars, field = f) }, 
#'             simplify = FALSE)) %>% 
#'           cellStats(mean, na.rm = T) %>% 
#'           t() %>% 
#'           as.data.frame() %>% 
#'           setNames(str_c("bot_", names(.)))
#'         
#'         # Combine
#'         month_summs <- bind_cols(surface_vars, bottom_vars)
#'         
#'         # Close connection:
#'         nc_close(x)
#'         
#'         # Return the table
#'         return(month_summs)
#'       }, 
#'       # Spit out NA's if there's trouble
#'       otherwise = data.frame(
#'         "surf_temp" = NA, 
#'         "surf_salinity" = NA, 
#'         "bot_temp" = NA,
#'         "bot_salinity" = NA)), 
#'     .id = "date")
#'   
#' }