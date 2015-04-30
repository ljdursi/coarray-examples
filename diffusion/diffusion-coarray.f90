program diffuse
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
       real, allocatable :: temperature(:,:)[:]
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

       integer :: locnpoints, start
       integer :: left, right, nneighbours=0
       integer :: neighbours(2)
       real    :: locxleft

!
! find local number of points and where we start in the
! global domain
!  
       locnpoints = totpoints/num_images()
       start = locnpoints*(this_image()-1)+1
       if (this_image() == num_images()) then
           locnpoints = totpoints - locnpoints*(num_images()-1)
       endif
       left = this_image()-1
       right= this_image()+1
       if ( left >= 1 ) then
           nneighbours = nneighbours+1
           neighbours(nneighbours) = left
       endif
       if ( right <= num_images() ) then
           nneighbours = nneighbours+1
           neighbours(nneighbours) = right
       endif
!
!
! set parameters
!
       dx = (xright-xleft)/(totpoints-1)
       dt = dx**2 * kappa/10.

       locxleft = xleft + dx*(start-1)
! prefix for our files
!
       write(imgstr,'(I03)') this_image()

! 
! allocate data, including ghost cells: old and new timestep
! theory doesn't need ghost cells, but we include it for simplicity
!
       allocate(temperature(locnpoints+2,2)[*])
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

       open(newunit=unitno,file=trim(adjustl(imgstr))//'-ics.txt')
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
           sync images(neighbours(1:nneighbours))
           if (this_image() /= 1) then
              temperature(1,old) = temperature(locnpoints+1,old)[left]
           endif
           if (this_image() /= num_images()) then
              temperature(locnpoints+2,old) = temperature(2,old)[right]
           endif

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

           old = new
           new = new + 1
           if (new > 2) new = 1
       enddo

       open(newunit=unitno,file=trim(adjustl(imgstr))//'-output.txt')
       do i=2,locnpoints+1
          write(unitno,'(3(F8.3,3X))'),x(i),temperature(i,new), theory(i)
       enddo
       close(unitno)
 
       deallocate(temperature)
       deallocate(theory)
       deallocate(x)
end program diffuse
