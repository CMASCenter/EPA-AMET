
C***********************************************************************
C   Portions of Models-3/CMAQ software were developed or based on      *
C   information from various groups: Federal Government employees,     *
C   contractors working on a United States Government contract, and    *
C   non-Federal sources (including research institutions).  These      *
C   research institutions have given the Government permission to      *
C   use, prepare derivative works, and distribute copies of their      *
C   work in Models-3/CMAQ to the public and to permit others to do     *
C   so.  EPA therefore grants similar permissions for use of the       *
C   Models-3/CMAQ software, but users are requested to provide copies  *
C   of derivative works to the Government without restrictions as to   *
C   use by others.  Users are responsible for acquiring their own      *
C   copies of commercial software associated with Models-3/CMAQ and    *
C   for complying with vendor requirements.  Software copyrights by    *
C   the MCNC Environmental Modeling Center are used with their         *
C   permissions subject to the above restrictions.                     *
C***********************************************************************

      PROGRAM sitecmp

C**********************************************************************
C
C  PROGRAM: To compare model concentrations at an observed site
C
C
C**********************************************************************
      USE M3FILES
      USE ENV_VARS
      USE GRID_DATA
      USE TIME_STEP
      USE SITE_DATA
      USE SPECIES_DEF

      USE M3UTILIO

      IMPLICIT NONE 

C..ARGUMENTS:

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS: None
 
C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16    PNAME        ! Program Name
      CHARACTER*80    MSG          ! Error message
      CHARACTER*5     Version      ! Version number
      INTEGER   N                  ! Loop index

C**********************************************************************
      DATA  PNAME       / 'sitecmp'  /
      DATA  Version     / '1.0'  /

C... write program name and version number
      WRITE( LOGUNIT, 92020 )
     &    '>>---->  Program ' // TRIM(PNAME) // ' (Version ' // TRIM(Version) // ')  <----<<' 

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the Models-3 file(s) to process and the other environment   
c  variables
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL OPEN_M3FILES

      Call GET_SPECS
      CALL GET_ENVS

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Check the file(s) for consistency and make sure the requested   
c  species is on the file(s)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL CK_M3FLS()

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the grid definition and the tsteps from the M3 files
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL GET_M3GRID

      CALL GET_TSTEPS

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the site data 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL FL_TYP1

      CALL SET_SITE_LOC

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Call the routine to extract the data and generate the output file 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL PROCESS

      WRITE( LOGUNIT, 92020 )
     &    '>>---->  Program ' // TRIM(PNAME) // ' completed successfully  <----<<' 


      CALL EXIT( 0 )

C******************  FORMAT  STATEMENTS   ******************************


92020  FORMAT( //5X, A, // )

       END
       
       
