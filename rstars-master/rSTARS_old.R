# R-package of Sequential T-test Analysis of Regime Shifts (rSTARS)





#' @title STARS Regime Shift Test
#' 
#' 
#' @description Sequential Test for Analysis of Regime Shifts based on methods 
#' of Rodionov et al. 2004 with prewhitening routines described in Rodionov 2006.
#' 
#' Three-part test approach for detecting shifts/changepoints in means OR 
#' variance/correlation shifts using sequential tests
#' 
#' For more information on the original methods please visit: 
#' https://sites.google.com/view/regime-shift-test/home?authuser=0
#'
#' @param data.timeseries dataframe or matrix containing two columns: 
#' 1. Time/date or some index for them
#' 2. Var of interest from which to test for shifts in mean/variance/correlation
#' @param l.cutoff 
#' @param pValue 
#' @param Huber 
#' @param Endfunction 
#' @param preWhitening 
#' @param OLS 
#' @param MPK 
#' @param IP4 
#' @param SubsampleSize 
#' @param returnResults 
#' @param save.data 
#' @param save.path 
#' @param ts_id 
#'
#' @return
#' @export
#'
#' @examples
rstars <- function(
    data.timeseries = PDO, 
    l.cutoff, 
    pValue = 0.05, 
    Huber = 1, 
    Endfunction = F,
    preWhitening = F, 
    OLS = F, 
    MPK = F, 
    IP4 = F, 
    SubsampleSize = (l + 1) / 3 ,
    returnResults = T,
    save.data = T,
    save.path = "", 
    ts_id = "",
    #show.plot = T,
    #timeseries = T
    FilteredData = T 
    )
{

  # Load all the sub-functions
  source(here::here("rstars-master", "Alpha.R"))
  source(here::here("rstars-master", "EqN.R"))
  source(here::here("rstars-master", "IMPK.R"))
  source(here::here("rstars-master", "IPN4.R"))
  source(here::here("rstars-master", "OLS.R"))
  source(here::here("rstars-master", "WeightedAverage.R"))
  source(here::here("rstars-master", "Stars_Citation.R"))
  # PDO <- read.table(here::here("rstars-master","PDO.txt"),header = T, dec = ".")




  #### Define main parameters ####

  TS    <- data.timeseries # data
  l     <- l.cutoff        # regime cutoff length
  #Plots <- show.plot      # Plot T/F
  Nsub  <- SubsampleSize   # Subsampling size for prewhitening & outliers

  # Determine if prewhitening, and if so, what method
  if (preWhitening == T){
    if (OLS == F & MPK == F &  IP4 == F){
      stop("preWhitening = T specify OLS, MPK or IP4")}
  }

  # Toggles that change based on prewhitening == F
  if (preWhitening == F){
    FilteredData = F 
    DT = 0
    if (OLS == T | MPK == T |  IP4 == T){
      stop("preWhitening = F")}
  }

  
  # Prewhitening matrices prep:
  if (preWhitening == TRUE){
    ts_length <- length(TS[, 1])
    RSI_mat   = matrix(0, nrow = ts_length - 1, length(TS[1, ]))
    TabTSpw   = matrix(0, nrow = ts_length - 1, length(TS[1, ]))
    TSpw      = vector(length = ts_length - 1)
    RMean_mat = matrix(0, nrow = ts_length - 1, length(TS[1, ]))
  }

  
  # No prewhitening matrices prep
  if (preWhitening == FALSE){
    ts_length <- length(TS[, 1])
    RSI_mat = matrix(0, nrow = ts_length, length(TS[1, ]))
    RMean_mat = matrix(0, nrow = ts_length, length(TS[1, ]))
  }


  ##### Prewhitening Subsampling  ####
  
  #### Attaching the data set as ts() and removing of red noise
  for (TIMESERIESindex in 2:length(TS[1, ])){

    # Get timeseries length
    X = ts(TS[, TIMESERIESindex])
    N = length(X)

    # l cannot be > timeseries length
    if (N < l){
      stop("CutOff cannot be > Time series length")
    }

    # test the subsample size (Nsub) limits
    if (Nsub < 5 &  MPK == TRUE){
      warning("The subsample size is too small. Automatically corrected - minimum value = 5")
      Nsub = 5
    }

    # test subsampling size is adequate for IP4/OLS
    if (Nsub < 3 & (IP4 == TRUE | OLS == TRUE)){
      Nsub = 3
      warning("The subsample size is too small. Automatically corrected - minimum value = 3")
    }

    # If it is sufficient, proceed
    if (Nsub > N){
      Nsub = N
    }

    ##### Apply Prewhitening  ####
    
    # Use prewhitening to remove red noise x(t) = x(t) - alpha * x(t-1)

    # Set alpha value based on PW method
    if (OLS == T | MPK == T | IP4 == T){
      alpha = AlphaEstf(X, N, Nsub, MPK, IP4, OLS)
    }
    
    
    # Use of prewhitening to remove red noise x(t)=x(t)-alpha*x(t-1)
    if (preWhitening == TRUE){
      
      for (i in 2:length(X)){
        TSpw[i - 1] = X[i] - (alpha * X[(i - 1)])
      }
      
      X = TSpw
      TabTSpw[, TIMESERIESindex] = TSpw
    }
    

    #===================#
    ####  STARS 3.2  ####
    #===================#
    

    # freedom degree
    df = 2 * l - 2

    # two tailed test
    t_stu = abs(qt(pValue / 2, df))

    #Variance and Sigma calcualation for DIFF formula
    A = var(X[1:l])
    for (i in 2:(length(X) - l + 1)){
      B = var(X[i:(i + l - 1)])
      A = rbind(A, B)
    }

    #Sigma square
    Sigma_s = mean(A)

    #between mean values of two subsequent regimes that would be statistically
    #significant according to the Student’s t-test
    diff = t_stu * sqrt((2 * Sigma_s) / l)

    
    
    #====================#
    #     core steps     #
    #====================#


    # Set up initial values, and vector to store RSI values
    vRMean = 0
    RSI = seq(0, 0, length.out = length(X))

    # Initial regime
    R1 = X[1:l]
    RegimeMean = WeightedAverage(R1, Sigma_s, Huber)
    changepoint = 1
    n1 = 0


    # Index through the timeseries
    # Perform regime shift index testing
    for (intYear in 2:length(X)){

      # If no RegimeMean, break
      if (is.na(RegimeMean) || RegimeMean == ''){
         break
      }

      # Behavior for end of timeseries
      if (Endfunction == T & intYear == (length(X) - l + 1)){
        
        if (preWhitening == F){
          RSI[(length(X) - l + 1):length(X)] == seq(0, 0, length.out = l)
          break
          }

        if (preWhitening == T){
          RSI[(length(X) - l + 1):(length(X) - 1)] == seq(0, 0, length.out = (l - 1))
          break
          }
        }

      if (X[intYear] > (RegimeMean + diff)){
        sumofWeights = 0
        cusumUP = 0
        Xdev = 0
        
        for (t in intYear:(intYear + l - 1)){
          if (t > length(X)){
            if (sumofWeights > 0){
              break
            }
          }

          Xdev = (X[t] - RegimeMean - diff) / sqrt(Sigma_s)

          #determine the weight of the normalized deviation
          if (Xdev == 0){
            Xweight = 1
          }

          else if (Xdev != 0){
            Xweight = min(1, (Huber / abs(Xdev)))
          }

          #sum weights and weighed values
          sumofWeights = sumofWeights + Xweight
          cusumUP = cusumUP + (Xdev * Xweight)

          #check if cusum turns zero
          if (cusumUP < 0){
            cusumUP = 0
            break
          }
        }
        cusumUP = cusumUP / sumofWeights

        RSI[intYear] = cusumUP
      }

      else if (X[intYear] < (RegimeMean - diff)){
        sumofWeights = 0
        cusumDown = 0
        Xdev = 0
        
        for (t in intYear:(intYear + l - 1)){
          if (t > length(X)){
            if (sumofWeights > 0){
              break
            }
          }

          Xdev = (X[t] - RegimeMean + diff) / sqrt(Sigma_s)
          
          #determine the weight of the normalized deviation
          if (Xdev == 0){
            Xweight = 1
          }
          
          else if (Xdev != 0){
            Xweight = min(1, (Huber / abs(Xdev)))
          }

          #sum weights and weighed values
          sumofWeights = sumofWeights + Xweight
          cusumDown = cusumDown + (Xdev * Xweight)

          #check if cusum turns zero
          if (cusumDown > 0){
            cusumDown = 0
            break
          }
        }
        
        cusumDown = cusumDown / sumofWeights
        RSI[intYear] = cusumDown
      }


      else if (RegimeMean - diff <= X[intYear] &
               X[intYear] <= RegimeMean + diff){
        RSI[intYear] = 0
      }

      #check for the situation when the test is not over for the last
      #change point, but we are too close to the end of the time series
      if (abs(RSI[intYear] > 0 & intYear > (length(X) - l + 1))){
        break
      }
      
      #------------------------------------------------------------------#

      if (RSI[intYear] == 0){
        
        #intYear is not a new changepoint
        if ((changepoint + l) <= intYear){
          
          #recalculate regime mean and Diff
          #currently Diff remains constant for the entire process /series
          n1 = intYear - changepoint + 1
          
          for (n in 1:n1){
            R1[n] = X[changepoint + n - 1]
          }
          
          RegimeMean = WeightedAverage(R1,Sigma_s,Huber)
        }
      }

      
      if (RSI[intYear] != 0){
        
        # Regime shift is detected
        # intYear is a new changepoint
      
        changepoint = intYear
        #recalculate regime mean and Diff
        #currently Diff remains constant for the entire process /series}
        R1 = 0
        for (n in 1:l){
          R1[n] = X[changepoint + n - 1]
        }
        
        RegimeMean = WeightedAverage(R1, Sigma_s, Huber)

      }
    }

    
    #####  Return Mean Values  ####
    
    # Inputs here:
    # TS = timeseries object
    # Sigma_s = Sigma squared
    # Huber = hubers weight
    # RSI = regime shift index
    
    
    
    # Returning means for regimes - without prewhitening
    if (FilteredData == F){
      X1 = TS[, TIMESERIESindex]
      
      # Start at index 1
      S = 1
      
      # Walk through RSI values
      for (i in 1:length(RSI)){
        
        # If RSI != 0, mark endpoint, get mean
        if (RSI[i] != 0){
          E = (i - 1)
          MeanRegime = WeightedAverage(X1[S:E], Sigma_s, Huber)
          vRMean1 = rep(MeanRegime, length(X1[S:E]))
          vRMean = c(vRMean, vRMean1)
          # shift the starting index
          S = i
        }
        
        # Calculate last mean when at the end
        if (i == length(RSI)){
          E = (length(RSI))
          MeanRegime = WeightedAverage(X1[S:E], Sigma_s, Huber)
          vRMean1 = rep(MeanRegime, length(X1[S:E]))
          vRMean = c(vRMean, vRMean1)
        }
      }
    }
    
    
    
    #Series of RegimeMeans - with prewhitening
    # Uses matrix X
    # if (FilteredData == T){
    vRMean_pw <- 0 # set constant
    if (preWhitening == T){
      
      # Start at index 1
      S = 1
      
      # Original, when arg was filteredData
      # for (i in 1:length(RSI)){
      #   
      #   # If RSI != 0, mark endpoint, get mean
      #   if (RSI[i] != 0){
      #     E = (i - 1)
      #     MeanRegime = WeightedAverage(X[S:E], Sigma_s, Huber)
      #     vRMean1 = rep(MeanRegime, length(X[S:E]))
      #     vRMean = c(vRMean, vRMean1)
      #     # Shift S to new index
      #     S = i
      #   }
      #  
      #   # Calculate last mean when at the end
      #   if (i == length(RSI)){
      #     E = (length(RSI))
      #     MeanRegime = WeightedAverage(X[S:E], Sigma_s, Huber)
      #     vRMean1 = rep(MeanRegime, length(X[S:E]))
      #     vRMean = c(vRMean, vRMean1)
      #   }
      # }
      
      # Do this again for prewhitened values regardless
      for (i in 1:length(RSI)){

        # If RSI != 0, mark endpoint, get mean
        if (RSI[i] != 0){
          E = (i - 1)
          MeanRegime = WeightedAverage(X[S:E], Sigma_s, Huber)
          vRMean1_pw = rep(MeanRegime, length(X[S:E]))
          vRMean_pw = c(vRMean_pw, vRMean1_pw)
          # Shift S to new index
          S = i
        }

        # Calculate last mean when at the end
        if (i == length(RSI)){
          E = (length(RSI))
          MeanRegime = WeightedAverage(X[S:E], Sigma_s, Huber)
          vRMean1_pw = rep(MeanRegime, length(X[S:E]))
          vRMean_pw = c(vRMean_pw, vRMean1_pw)
        }
      }
     
      
      
      }



    # Return these pieces from RSI testing:
    vRMean = vRMean[-1]                  
    RSI_mat[, TIMESERIESindex]   = RSI    # rsi values
    RMean_mat[, TIMESERIESindex] = vRMean # mean values
    
    # Do some renaming before save
    colnames(RMean_mat) <- c(colnames(data.timeseries)[[1]], "regime_mu")
    colnames(RSI_mat)   <- c(colnames(data.timeseries)[[1]], "RSI")
    
    
    
    # prep the prewhitened means to go with
    if(preWhitening== T){
      # Take dimesnions of non-prewhitened mean matrix
      RMean_mat_pw <- RMean_mat
      
      # Use prewhitened data means
      RMean_mat_pw[, TIMESERIESindex] <- vRMean_pw[-1]   
      
      # And rename again
      colnames(RMean_mat_pw) <- c(colnames(data.timeseries)[[1]], "regime_mu_pw")
      
    }

  }

  
  #### Saving tables  #### 
  
  # regimes average      (tsMean.csv) 
  # Regime Shift Index   (RSI.csv) 
  # Filtered time series (Filredts.csv)

  
  
  
  # Adjust RSI_mat & RMean_mat and timeseries for prewhitening before save
  if (preWhitening == T){
   
    # Adjust the RSI Matrix for prewhitening
    # Zero vector with length of timeseries
    zeri = seq(0, 0, length.out = length(TS[1, ]))
    RSI_mat = rbind(zeri, RSI_mat)

    # Adjust the regime means for prewhitening
    # NA vector with length of timeseries
    empties = rep(NA, length(TS[1, ]))
    RMean_mat = rbind(empties, RMean_mat)
    
    
    # Adjust the regime means for prewhitening, filteredData
    # NA vector with length of timeseries
    empties = rep(NA, length(TS[1, ]))
    RMean_mat_pw = rbind(empties, RMean_mat_pw)
    

    # Prep the prewhitened timeseries for saving
    TabTSpw = rbind(empties, TabTSpw)
    colnames(TabTSpw) <- c(
      colnames(data.timeseries)[[1]], 
      paste0(colnames(data.timeseries)[[2]], "_pw"))
    
    # Rename before saving
    TabTSpw_save = TabTSpw
    
    # Make dataframe for date class to work
    TabTSpw_save     <- as.data.frame(TabTSpw_save)
    TabTSpw_save[,1] <- data.timeseries[,1]
    
    }

  
  
  
  #### Returning Data  ####
  
  # Rename some matrices for saving
  RMean_mat_save = as.data.frame(RMean_mat)
  RSI_mat_save   = as.data.frame(RSI_mat)
  
  RMean_mat_save[,1] <- data.timeseries[,1]
  RSI_mat_save[,1]   <- data.timeseries[,1]
  
  
  # Build one table for export
  if(returnResults == T){
    
    # Data with RSI & Means
    dat_all <- data.timeseries %>% 
      left_join(RSI_mat_save) %>% 
      left_join(RMean_mat_save)
    
    # Add prewhitened timeseries and regime means in anomalies
    if(preWhitening){
    
      dat_all <- dat_all %>%  
        left_join(TabTSpw_save) %>%    # timeseries prewhitened
        left_join(as.data.frame(RMean_mat_pw))
      }
      
     # Return that data if desired 
      return(dat_all)
  }
  
  

  ####  Exporting Files  ####
  if (save.data == TRUE){
    
    # Regime means
    path_temp = paste0(toString(save.path), "Timeseries_Means/", ts_id, "_tsMean.csv")
    write_csv(RMean_mat_save, file = path_temp)
  
    # RSI's
    path_temp = paste0(toString(save.path), "RSI/", ts_id, "_RSI.csv")
    write_csv(RSI_mat_save, file = path_temp)
  
    # Saving prewhitened timeseries
    if (preWhitening == T){
      
      # File path
      path_temp = paste0(toString(save.path), "Prewhitened_timeseries/", ts_id, "_Filteredts.csv")
      write_csv(x = TabTSpw_save, file = path_temp)}
  
  }

  
  # Message about citation
  cat("STARS has completed the analysis. Please, run stars_citation() for references")
  
}





####____________________####
  

rstars_plot <- function(TS, Plots, timeseries, preWhitening, FilteredData){
  
  
  #### Returning PLOTS ####
  if (Plots == TRUE)
  {
    if (timeseries == TRUE)
    {
      require(xts)
      Time <- as.POSIXct(TS[,1], optional = TRUE, origin = TS[1,1])
      
      if (preWhitening == F)
      {
        for (i in 2:length(TS[1, ]))
        {
          table_plot = cbind(as.data.frame(RMean_mat)[,i],TS[,i])
          colnames(table_plot) <- c(colnames(as.data.frame(RMean_mat)[i]),colnames(TS[i]))
          p <- plot(
            xts(table_plot, order.by = Time),
            col = c("#EB4C43","#3081B5"),
            #lwd = c(1, 2),
            main = paste("Regime Shift detection in",colnames(TS[i]),"using STARS")
          )
          addLegend('topright',
                    legend.names = c("Time series", "Regimes"),
                    col = c("#3081B5", "#EB4C43"),
                    lwd = c(2, 2)
          )
          
          print(p)
          
          rsi <- abs(data.frame(RSI_mat, row.names = NULL))
          nome <- colnames(rsi[i])
          rsi = xts(rsi[,i], order.by = Time)
          colnames(rsi) <- nome
          q <- plot(rsi, type = "h",
                    main = paste("Regime shift index values for", colnames(rsi)))
          print(q)
          
        }
      }
      else if (preWhitening == T)
      {
        if (FilteredData == F)
        {
          for (i in 2:length(TS[1, ]))
          {
            table_plot = cbind(as.data.frame(RMean_mat)[,i],TS[,i])
            colnames(table_plot) <- c(colnames(as.data.frame(RMean_mat)[i]),colnames(TS[i]))
            p <- plot(
              xts(table_plot,order.by = Time),
              col = c("#EB4C43","#3081B5"),
              #lwd = c(1, 2),
              main = paste("Regime Shift detection in",colnames(TS[i]),"using STARS")
            )
            addLegend('topright',
                      legend.names = c("Time series", "Regimes"),
                      col = c("#3081B5", "#EB4C43"),
                      lwd = c(2, 2)
            )
            
            print(p)
            
            rsi <- abs(data.frame(RSI_mat, row.names = NULL))
            nome <- colnames(rsi[2])
            rsi = xts(rsi[,2], order.by = Time)
            colnames(rsi) <- nome
            
            q <- plot(rsi, type = "h",
                      main = paste("Regime shift index values for", colnames(rsi)))
            print(q)
          }
        }
        else if (FilteredData == T)
        {
          
          
          for (i in 2:length(TS[1, ]))
          {
            table_plot = cbind(as.data.frame(RMean_mat)[,i],as.data.frame(TabTSpw)[,i],TS[,i])
            colnames(table_plot) <- c(colnames(as.data.frame(RMean_mat)[i]),colnames(as.data.frame(TabTSpw)[i]),colnames(TS[i]))
            require(xts)
            
            
            p <- plot(
              xts(table_plot,order.by = Time),
              col = c( "#EB4C43","#3081B5","#ECDA61"),
              #lwd = c(1, 1, 2),
              main = paste("Regime Shift detection in",colnames(TS[i]),"using STARS")
            )
            addLegend('topright',
                      legend.names = c("Time series", "Filtered ts", "Regimes"),
                      col = c("#ECDA61", "#3081B5", "#EB4C43"),
                      lwd = c(2, 2, 2)
            )
            
            
            print(p)
            
            
            rsi <- abs(data.frame(RSI_mat, row.names = NULL))
            nome <- colnames(rsi[i])
            rsi = xts(rsi[,i], order.by = Time)
            colnames(rsi) <- nome
            
            q <- plot(rsi, type = "h",
                      main = paste("Regime shift index values for", colnames(rsi)))
            
            print(q)
            
          }
        }
      }
    }
    
    if (timeseries == FALSE)
    {
      tTS = ts(TS)
      tRMean_mat = ts(RMean_mat)
      
      if (preWhitening == F)
      {
        for (i in 2:length(TS[1, ]))
        {
          ts.plot(
            tTS[, i],
            tRMean_mat[, i],
            col = c("blue", "red"),
            lwd = c(1, 2),
            xlim = c(0, (length(tTS[, i]) + (
              0.3 * length(tTS[, i])
            )))
          )
          legend(
            x = (length(tTS[, i]) + (0.05 * length(tTS[, i]))),
            y = (max(tTS[, i]) - ((
              max(tTS[, i]) - mean(tTS[, i])
            ) / 2)),
            c("Observed data", "Regimes"),
            col = c("blue", "red"),
            lwd = c(1, 2)
          )
        }
      }
      else if (preWhitening == T)
      {
        if (FilteredData == F)
        {
          for (i in 2:length(TS[1, ]))
          {
            ts.plot(
              tTS[, i],
              tRMean_mat[, i],
              col = c("blue", "red"),
              lwd = c(1, 2),
              xlim = c(0, (length(tTS[, i]) + (
                0.3 * length(tTS[, i])
              )))
            )
            legend(
              x = (length(tTS[, i]) + (0.05 * length(tTS[, i]))),
              y = (max(tTS[, i]) - ((
                max(tTS[, i]) - mean(tTS[, i])
              ) / 2)),
              c("Observed data", "Regimes"),
              col = c("blue", "red"),
              lwd = c(1, 2)
            )
          }
        }
        else if (FilteredData == T)
        {
          for (i in 2:length(TS[1, ]))
          {
            ts.plot(
              tTS[, i],
              TabTSpw[, i],
              RMean_mat[, i],
              col = c("grey", "blue", "red"),
              lwd = c(1, 1, 2),
              xlim = c(0, (length(tTS[, i]) + (
                0.3 * length(tTS[, i])
              )))
            )
            legend(
              x = (length(tTS[, i]) + (0.05 * length(tTS[, i]))),
              y = (max(tTS[, i]) - ((
                max(tTS[, i]) - mean(tTS[, i])
              ) / 2)),
              c("Observed data", "Filtered ts", "Regimes"),
              col = c("grey", "blue", "red"),
              lwd = c(1, 1, 2)
            )
          }
        }
      }
    }
    
  }
  
  

  
  
  }
  
  
  
  
  

