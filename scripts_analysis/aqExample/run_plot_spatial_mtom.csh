#!/bin/csh -f
# --------------------------------
# Spatial plot - Model to Model
# -----------------------------------------------------------------------
# Purpose:
#
# This code is part of the AMET-AQ system.  The Plot Spatial MTOM code
# takes a MYSQL database query for a single species from one or more
# networks and two model simulations and plots the minimum, maximum, and
# average difference between the two model simulations at the network
# sites. No observation data are used in the calculation, but at least
# one observation network must be specified.
#
# Initial version:  Alexis Zubrow IE UNC - Nov, 2007
#
# Revised verison:  Wyat Appel - Dec, 2012
# -----------------------------------------------------------------------

  
  #--------------------------------------------------------------------------
  # These are the main controlling variables for the R script
  
  #  Top of AMET directory
  setenv AMETBASE ~/AMET
  
  #  AMET database
  setenv AMET_DATABASE  amet

  #  AMET project id or simulation id
  setenv AMET_PROJECT   aqExample
  setenv AMET_PROJECT2  aqExample
  
  #  Directory where figures and text output will be directed
  setenv AMET_OUT       $AMETBASE/output/$AMET_PROJECT/plot_spatial_mtom

  #  Start and End Dates of plot (YYYYMMDD) - must match available dates in db
  setenv AMET_SDATE "20060701"
  setenv AMET_EDATE "20060711"

  #  Custom title (if not set will autogenerate title based on variables 
  #  and plot type)
  setenv AMET_TITLE "Difference spatial plot $AMET_PROJECT $AMET_SDATE - $AMET_EDATE"


  #  Plot Type, options are "pdf","png" or "both"
  setenv AMET_PTYPE both             

  ### Species to Plot ###
  ### Acceptable Species Names: SO4,NO3,NH4,HNO3,TNO3,PM_TOT,PM25_TOT,PM_FRM,PM25_FRM,EC,OC,TC,O3,O3_1hrmax,O3_8hrmax
  ### SO2,CO,NO,SO4_dep,SO4_conc,NO3_dep,NO3_conc,NH4_dep,NH4_conc,precip,NOy 
  ### AE6 (CMAQv5.0) Species
  ### Na,Cl,Al,Si,Ti,Ca,Mg,K,Mn,Soil,Other,Ca_dep,Ca_conc,Mg_dep,Mg_conc,K_dep,K_conc

  setenv AMET_AQSPECIES SO4

  ### Observation Network to plot -- One only
  ###  set to 'y' to turn on, default is off
  ###  NOTE: species are not available in every network
  setenv AMET_CSN y
  setenv AMET_IMPROVE y
  setenv AMET_CASTNET y
#  setenv AMET_CASTNET_Hourly y
#  setenv AMET_CASTNET_Drydep y 
#  setenv AMET_NADP y 
#  setenv AMET_AIRMON y 
#  setenv AMET_AQS_Hourly y
#  setenv AMET_AQS_Daily_O3 y
#  setenv AMET_AQS_Daily_PM y
#  setenv AMET_SEARCH y 
#  setenv AMET_SEARCH_Daily y
#  setenv AMET_CAPMON y
#  setenv AMET_NAPS_Hourly y

### Europe Networks ###

#  setenv AMET_AirBase_Hourly y
#  setenv AMET_AirBase_Daily y
#  setenv AMET_AURN_Hourly y
#  setenv AMET_AURN_Daily y
#  setenv AMET_EMEP_Hourly y
#  setenv AMET_EMEP_Daily y
#  setenv AMET_AGANET y
#  setenv AMET_ADMN y
#  setenv AMET_NAMN y

  # Log File for R script
  setenv AMET_LOG plot_spatial_mtom.log

##--------------------------------------------------------------------------##
##                Most users will not need to change below here
##--------------------------------------------------------------------------##

  ## Set the input file for this R script
  setenv AMETRINPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/plot_spatial_mtom.input  
  setenv AMET_NET_INPUT $AMETBASE/scripts_analysis/$AMET_PROJECT/Network.input
  
  # Check for plot and text output directory, create if not present
  if (! -d $AMET_OUT) then
     mkdir -p $AMET_OUT
  endif

  # R-script execution command
  R CMD BATCH --no-save --slave $AMETBASE/R/AQ_Plot_Spatial_MtoM.R $AMET_LOG
  setenv AMET_R_STATUS $status
  
  if($AMET_R_STATUS == 0) then
		echo
		echo "Statistics information"
		echo "-----------------------------------------------------------------------------------------"
		echo "Plots -- ---------------------> $AMET_OUT/${AMET_PROJECT}_${AMET_AQSPECIES}_spatialplot_<TYPE>.$AMET_PTYPE"
		echo "-----------------------------------------------------------------------------------------"
		exit 0
  else
     echo "The AMET R script did not produce any output, please check the LOGFILE $AMET_LOG for more details on the error."
     echo "Often, this indicates no data matched the specified criteria (e.g., wrong dates for project). Please check and re-run!"
  		exit 1  
  endif

