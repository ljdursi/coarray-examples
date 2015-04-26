program diffuse
       use mpi
       implicit none
   
!
! simulation parameters
!
       integer, parameter :: totpoints=1000
       real, parameter    :: xleft=-12., xright=+12.
       real, parameter    :: kappa=1.
       integer, parameter :: nsteps=100000

!
! the calculated temperature, and the known correct
! solution from theory
!
       real, allocatable :: x(:)
       real, allocatable :: temperature(:,:)
       real, allocatable :: theory(:)

       integer :: old=1, new=2
       integer :: step
       integer :: i
       real :: time
       real :: dt, dx
       real :: error

       integer :: unitno
       character(len=3) :: imgstr
!
!  parameters of the original temperature distribution
!
       real, parameter :: ao=1., sigmao = 1.
       real :: a, sigma
       real :: fixedlefttemp, fixedrighttemp

!
!  mpi variables
! 
       integer :: ierr, rank, comsize
       integer :: locnpoints, startn, endn
       real    :: locxleft
       integer :: left, right
       integer :: lefttag=1, righttag=2
       integer, dimension(MPI_STATUS_SIZE) :: rstatus

       call MPI_Init(ierr)
       call MPI_Comm_size(MPI_COMM_WORLD,comsize,ierr)
       call MPI_Comm_rank(MPI_COMM_WORLD,rank,ierr)

       locnpoints = totpoints/comsize
       startn = rank*locnpoints+1
       endn   = startn + locnpoints
       if (rank == comsize-1) endn=totpoints+1
       locnpoints = endn-startn
   
       left = rank-1
       if (left < 0) left = MPI_PROC_NULL
       right = rank+1
       if (right >= comsize) right = MPI_PROC_NULL
!
! set parameters
!
       dx = (xright-xleft)/(totpoints-1)
       dt = dx**2 * kappa/10.

       locxleft = xleft + dx*(startn-1)

       write(imgstr,'(I03)') rank
! 
! allocate data, including ghost cells: old and new timestep
! theory doesn't need ghost cells, but we include it for simplicity
!
       allocate(temperature(locnpoints+2,2))
       allocate(theory(locnpoints+2))
       allocate(x(locnpoints+2))
!
!  setup initial conditions
!
       time = 0.
       x = locxleft + [((i-1)*dx,i=1,locnpoints+2)]
       temperature(:,old) = ao*exp(-(x)**2 / (2.*sigmao**2))
       theory= ao*exp(-(x)**2 / (2.*sigmao**2))

       fixedlefttemp = ao*exp(-(xleft-dx)**2 / (2.*sigmao**2))
       fixedrighttemp= ao*exp(-(xright+dx)**2 / (2.*sigmao**2))

       open(newunit=unitno,file=imgstr//'-ics.txt')
       do i=2,locnpoints+1
          write(unitno,'(3(F8.3,3X))'),x(i),temperature(i,old), theory(i)
       enddo
       close(unitno)

!
!  evolve
!
       do step=1, nsteps
!
! boundary conditions: keep endpoint temperatures fixed.
!
           temperature(1,old) = fixedlefttemp
           temperature(locnpoints+2,old) = fixedrighttemp

!
! exchange boundary information
!

           call MPI_Sendrecv(temperature(locnpoints+1,old), 1, MPI_REAL, right, righttag,  &
                     temperature(1,old), 1, MPI_REAL, left,  righttag, MPI_COMM_WORLD, rstatus, ierr)

           call MPI_Sendrecv(temperature(2,old), 1, MPI_REAL, left, lefttag,  &
                     temperature(locnpoints+2,old), 1, MPI_REAL, right,  lefttag, MPI_COMM_WORLD, rstatus, ierr)
!
! update solution
!
           forall (i=2:locnpoints+1)
               temperature(i,new) = temperature(i,old) + &
                     dt*kappa/(dx**2) * (                &
                          temperature(i+1,old) -         &
                        2*temperature(i,  old) +         & 
                          temperature(i-1,old)           &
                     )
           end forall
           time = time + dt

! 
! update correct solution
!
           sigma = sqrt(2.*kappa*time + sigmao**2)
           a = ao*sigmao/sigma
           theory = a*exp(-(x)**2 / (2.*sigma**2))

           error = sqrt(sum((theory(2:locnpoints+1) - temperature(2:locnpoints+1,new))**2))

           print *, 'Step = ', step, 'Time = ', time, ' Err = ', error

           old = new
           new = new + 1
           if (new == 3) new = 1
       enddo

       open(newunit=unitno,file=imgstr//'-output.txt')
       do i=2,locnpoints+1
          write(unitno,'(3(F8.3,3X))'),x(i),temperature(i,new), theory(i)
       enddo
       close(unitno)

       deallocate(temperature)
       deallocate(theory)
       deallocate(x)
       call MPI_Finalize(ierr)
       end program diffuse
