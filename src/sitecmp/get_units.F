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

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  Routine to return the units of a variable for file M3_FLNAME(1)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC

      SUBROUTINE GET_UNITS( VARNAME, UNITS )

      USE M3FILES
      USE ENV_VARS
      USE M3UTILIO

      IMPLICIT NONE     

C..ARGUMENTS:
      CHARACTER*(*) VARNAME
      CHARACTER*(*) UNITS

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16  PNAME             ! Program Name
      CHARACTER*256  MSG
      INTEGER I


      DATA PNAME / 'CK_M3FLS' /
      UNITS = 'na'

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get header data for CTM file 1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IF( .NOT. DESC3 ( M3_FLNAME( 1 ) ) ) THEN
         MSG = 'Could not read DESC of  ' // M3_FLNAME( 1 ) 
     &         // ' file'
         CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. )
         RETURN
      ENDIF


      !  find matching variable, and return it's units
      DO I=1,MXVARS3
        if( VNAME3D(i) .eq. VARNAME ) UNITS = UNITS3D(I)
      EndDo

      RETURN
 
      END
