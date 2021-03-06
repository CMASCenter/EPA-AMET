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
C $Header: /project/work/rep/TOOLS/src/combine/module_file.F,v 1.1.1.1 2005/07/27 12:55:20 sjr Exp $

C***********************************************************************
C
C  MODULE:  sets up file data
C             
C***********************************************************************
      MODULE M3FILES

      INTEGER N_M3FILES                   ! No. of input Models-3 files

      INTEGER, PARAMETER :: MXM3FLS = 20  ! Max no. of input

      CHARACTER*16 M3FILENAME( MXM3FLS )  ! filenames

      Logical convert(MXM3FLS)            ! convert flags

      INTEGER TSTEP
      INTEGER NROWS
      INTEGER NCOLS
      INTEGER NLAYS
      REAL*8  XCELL
      REAL*8  YCELL
      REAL*8  XORIG
      REAL*8  YORIG 

      CONTAINS

C***********************************************************************
C   open input ioapi files
C***********************************************************************
         SUBROUTINE OPEN_M3FILES

         USE spec_def
         USE M3UTILIO
        
         IMPLICIT NONE 

         ! LOCAL VARIABLES:
         INTEGER   n, m               ! Loop index
         INTEGER   status             ! Status code
         INTEGER   EDATE, ETIME, runlen
         Character*(256) fname

         LOGICAL valid
         LOGICAL function canConvert


         !cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         ! Determine the number of input CTM conc files that need to be read
         !cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

         N_M3FILES = 0
         M3FILENAME(1) = 'INFILE1'
         if( .NOT. OPEN3( M3FILENAME(1), 1, 'combine') ) then
           Write(*,'(''**Error** Could not open input file'',
     &               '' for "INFILE1"'')')
           return
           endif

         if( .NOT. DESC3( M3FILENAME(1) ) ) then
           Write( *, '(''**Error** While running DESC3 on '',
     &                 A)' ) M3FILENAME(1)
           return
           endif

         N_M3FILES = 1

         ! save file parameters
         TSTEP = TSTEP3D
         NROWS = NROWS3D
         NCOLS = NCOLS3D
         NLAYS = NLAYS3D
         XCELL = XCELL3D
         YCELL = YCELL3D
         XORIG = XORIG3D
         YORIG = YORIG3D
    
         ! reset startDate and startTime if file starts after
         if( startDate.lt.1970001 .or.
     &       SECSDIFF (startDate, startTime, SDATE3D, STIME3D) .gt. 0 ) then
           startDate = SDATE3D
           startTime = STIME3D
           endif

         ! compute ending time of file 
         EDATE = SDATE3D
         ETIME = STIME3D
         DO m = 1, MXREC3D-1
           Call Nextime(EDATE, ETIME, TSTEP3D)
           enddo

         ! reset endDate and endTime if file ends before
         if( endDate.lt.1970001 .or.
     &       SECSDIFF (endDate, endTime, EDATE, ETIME) .lt. 0 ) then
           endDate = EDATE
           endTime = ETIME
           endif

         ! try to open files (2-MXM3FLS) 
         DO n = 2, MXM3FLS
           if( n.le.9 ) write(M3FILENAME(n), '( ''INFILE'', I1 )' ) n
           if( n.ge.10) write(M3FILENAME(n), '( ''INFILE'', I2 )' ) n

           Call NAMEVAL( M3FILENAME(n), fname )
           INQUIRE(file=fname, exist=valid)
           if( .not.valid ) EXIT

           if( .NOT. OPEN3( M3FILENAME(n), 1, 'COMBINE') ) EXIT

           if( .NOT. DESC3( M3FILENAME(n) ) ) then
             Write( *, '(''**Error** While running DESC3 on '',A)' )
     &             M3FILENAME(n)
             exit
             endif
               
           valid = .true.

           !! if file is time dependent, adjust start and end dates
           if( TSTEP3D.gt. 0 ) then

             if( TSTEP.lt.TSTEP3D ) valid = .false.  ! time step

             ! reset startDate and startTime if file starts after
             if( SECSDIFF (startDate, startTime, SDATE3D, STIME3D) .gt. 0 ) then
               startDate = SDATE3D
               startTime = STIME3D
               endif
 
             ! compute ending time of file
             EDATE = SDATE3D
             ETIME = STIME3D
             DO m = 1, MXREC3D-1
               Call Nextime(EDATE, ETIME, TSTEP3D)
               enddo

             ! reset endDate and endTime if file ends before
             if( SECSDIFF (endDate, endTime, EDATE, ETIME) .lt. 0 ) then
               endDate = EDATE
               endTime = ETIME
               endif
             endif   ! time independent file

           ! verify domain parameters
           if( XCELL.ne.XCELL3D ) valid = .false.  ! width of cell
           if( YCELL.ne.YCELL3D ) valid = .false.  ! height of cell
           if( .NOT.valid ) then
             Write( *, '(''**Error** Inconsistence file domain for ''
     &             ,A)' ) M3FILENAME(n)
             N_M3FILES = 0
             return
             endif 

           ! check if file needs to be converted
           convert(N) = .false.
           if( NROWS.ne.NROWS3D ) convert(N) = .true.
           if( NCOLS.ne.NCOLS3D ) convert(N) = .true.
           if( ABS(XORIG-XORIG3D) .gt. 0.000001 ) convert(N) = .true.
           if( ABS(YORIG-YORIG3D) .gt. 0.000001 ) convert(N) = .true.

           if( convert(n) ) then
             write(*,'(''NROWS='',2i8)') NROWS, NROWS3D
             write(*,'(''NCOLS='',2i8)') NCOLS, NCOLS3D
             write(*,'(''XORIG='',2f12.2)') XORIG, XORIG3D
             write(*,'(''YORIG='',2f12.2)') YORIG, YORIG3D
             write(*,'(/,''**Inconsistence file domain** trying to convert'',//)')
             endif

           ! check if file can be converted
           if( convert(N) .and. (.NOT.canConvert()) ) then
             Write( *, '(''**Error** Inconsistence file domain for ''
     &             ,A)' ) M3FILENAME(n)
             N_M3FILES = 0
             return
             endif
         
           Write(*,'('' file '',a,'' needs conversion:'',L)') trim(M3FILENAME(n)), convert(N)

           N_M3FILES = N_M3FILES +1
           enddo
 
         ! get file description for M3FILENAME(1)
         if( .NOT. DESC3( M3FILENAME(1) ) ) then
           Write( *, '(''**Error** While running DESC3 on '',A)' )
     &            M3FILENAME(1)
           N_M3FILES = 0
           return
           endif
             
         return

         END SUBROUTINE OPEN_M3FILES

C***********************************************************************
C   check if domain grid is a subgrid of current file description
C***********************************************************************
         Logical Function canConvert() result( pass )

         USE M3UTILIO

         IMPLICIT NONE 

         Real xdiff, ydiff
         Integer xoffset, yoffset 


         pass = .false.
         
         ! find origin different
         xdiff = XORIG - XORIG3D
         ydiff = YORIG - YORIG3D

         ! check lower limits
         if( xdiff.lt.0.0 ) return 
         if( ydiff.lt.0.0 ) return

         ! check upper limits
         if( (XORIG + NCOLS*XCELL) .gt. (XORIG3D + NCOLS3D*XCELL3D) ) return
         if( (YORIG + NROWS*YCELL) .gt. (YORIG3D + NROWS3D*YCELL3D) ) return

         ! compute row and column offsets that grid lies on grid line
         xoffset = xdiff / XCELL3D
         yoffset = ydiff / YCELL3D

         ! check that offsets lies on grid line
         if( int(xoffset*XCELL3D) .ne. int(xdiff) ) return
         if( int(yoffset*YCELL3D) .ne. int(ydiff) ) return

         pass = .true.
         return       

         END FUNCTION canConvert 

C***********************************************************************
C   routine to read species values from file
C***********************************************************************
         SUBROUTINE ReadValues( fileName, specName, ilayer, idate, itime,
     &                          isize, specValue, status)

         USE M3UTILIO

         IMPLICIT NONE 

         ! argument variables
         Character*(*) fileName
         Character*(*) specName
         Integer ilayer, idate, itime, isize, status
         Real specValue(isize)

         ! local variables
         Integer fileNo
         Integer jdate, jtime
         Integer colOffset, rowOffset
         Real, Allocatable :: values(:,:,:)
         Integer lay1, lay2
         Integer k, c, r, l


         ! read file number from fileName
         read(fileName,'(6x,i1)', iostat=status) fileNo

         ! get file description
         if( .NOT.DESC3( fileName ) ) then
           status = -1
           return
           endif

         ! set time and date to read, if TSTEP3D==0, then set date/time to SDATE3D/STIME3D
         jdate = idate
         jtime = itime
         if( TSTEP3D.eq.0 ) then
           jdate = SDATE3D
           jtime = STIME3D
           endif

         ! if no conversion needed, read the values directly
         if( .NOT.convert(fileNo) ) then

           if(.NOT.READ3( fileName, specName, ilayer, jdate,
     &                  jtime, specValue)) status = -1 
           return
           endif


         !!!! read values from file and convert to specValue 
        
         ! determine number of layers to read 
         lay1 = NLAYS3D
         if(ilayer.gt.0) lay1 = 1

         ! allocate values array 
         Allocate ( values(NCOLS3D, NROWS3D, lay1) )
               
         ! read values from super file
         if(.NOT.READ3( fileName, specName, ilayer, jdate,
     &                 jtime, values)) then 
           status = -1
           return
           endif 

         ! compute column and row offsets
         colOffset = (XORIG - XORIG3D) / XCELL3D
         rowOffset = (YORIG - YORIG3D) / YCELL3D

         ! compute starting and ending layers to copy
         lay1 = 1
         lay2 = NLAYS
         if( ilayer.gt.0 ) then
           lay1 = 1
           lay2 = 1
           endif  

         ! copy values array to specValue array
         k = 0
         do l=lay1,lay2
           do r=1,NROWS
             do c=1,NCOLS
               k = k+1
               specValue(k) = values( c+colOffset, r+rowOffset, l)
               enddo
             enddo
           enddo

         Deallocate( values )
         Return 

         END SUBROUTINE ReadValues
      
      END MODULE M3FILES
