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

C RCS file, release, date & time of last delta, author, state, [and locker]
C $Header: /project/work/rep/TOOLS/src/combine/utils.F,v 1.1.1.1 2005/07/27 12:55:20 sjr Exp $


C***********************************************************************
C  Returns the nth field of record
C***********************************************************************
      Subroutine getFld( record, delimiter, nth, del, field )

      IMPLICIT NONE

      CHARACTER*(*) record
      CHARACTER*(*) delimiter
      CHARACTER del
      Integer nth
      CHARACTER*(*) field

      Integer nfields
      Integer i, pos1
  
      pos1 = 1
      nfields = 0
      del = delimiter(1:1)
      field = ''
      Do i=1, LEN(record)
       if( index( delimiter,record(i:i) ) .gt. 0 ) then
         nfields = nfields+1 
         if( nfields .eq. nth ) then
           if(pos1.le.i) field = record(pos1:i-1)
           call LeftTrim(field)
           call RightTrim(field)
           return
           Endif
         del = record(i:i)
         pos1 = i+1
         Endif
       Enddo

      nfields = nfields+1 

      ! check if last field
      if( nfields .eq. nth ) then
        field = record(pos1:)
        Endif

      Call LeftTrim(field)
      Call RightTrim(field)
      Return
      End
        

 
C***********************************************************************
C  Returns the number of parsed fields in record
C***********************************************************************
      INTEGER FUNCTION getFldCount(record, delimiter)
     &    result(nfields)

      IMPLICIT NONE
  
      CHARACTER*(*) record
      CHARACTER*(*) delimiter

      Integer i
      Logical isDel

      nfields = 0
      if( LEN_TRIM(record).gt.0 ) nfields = 1

      Do i=1,LEN(record)
        isDel = ( index(delimiter, record(i:i)) .gt. 0 ) 
        if( isDel ) then
          nfields = nfields+1
          cycle
          endif
        enddo

      Return
      end

C***********************************************************************
C  routine to remove leading blank spaces from Character String
C***********************************************************************
      Subroutine LeftTrim( STRING )

      IMPLICIT NONE

      CHARACTER*(*) STRING
      Integer I

      Do I=1,LEN(STRING)
        if(STRING(I:I) .ne. CHAR(32)) Then
          STRING = STRING(I:)
          RETURN
          EndIf 
         EndDo

      Return
      End Subroutine LeftTrim


C***********************************************************************
C  routine to remove trailing white spaces from Character String
C***********************************************************************
      Subroutine RightTrim( STRING )
 
      IMPLICIT NONE
 
      CHARACTER*(*) STRING
      Integer I
 
      Do I=LEN(STRING),1,-1
        if(STRING(I:I) .lt. CHAR(32)) STRING(I:I) = CHAR(32)
        if(STRING(I:I) .gt. CHAR(32)) Exit
        EndDo

      Return
      End Subroutine RightTrim
     

C***********************************************************************
C  Routine to change character string to upper characters
C***********************************************************************
      SUBROUTINE UCASE ( STR )

      IMPLICIT NONE

      CHARACTER STR*( * )
      INTEGER I
      INTEGER K

      DO I = 1, LEN(STR)
        K = ICHAR(STR(I:I))
        IF ( ( K .GE. 97 ) .AND. ( K .LE. 122 ) )
     &    STR( I:I ) = CHAR( K - 32 )
      END DO

      RETURN
      END SUBROUTINE UCASE
