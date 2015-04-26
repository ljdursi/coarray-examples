program mpicoarray1
  use mpi
  implicit none
  integer :: me, nprocs, left, right, i, ierr
  integer, dimension(3) :: alocal, aneighbour

  call MPI_Init(ierr)
  call MPI_Comm_rank(MPI_COMM_WORLD, me, ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)
 
  right = me + 1
  left  = me - 1
  if (right >= nprocs) right = 0
  if (left < 0) left = nprocs-1

  alocal = [ (me**i, i=1, 3) ]

  call MPI_Sendrecv( alocal,     3, MPI_INTEGER, left, 0, &
                     aneighbour, 3, MPI_INTEGER, right , 0, &
                     MPI_COMM_WORLD, MPI_STATUS_IGNORE, ierr)

  print *, "Image ", me, " has a(2) = ", alocal(2), "; neighbour has ", aneighbour(2)
end program mpicoarray1
