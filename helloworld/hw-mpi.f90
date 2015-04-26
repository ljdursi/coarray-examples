program MPIHelloworld
   use mpi
   implicit none
   integer :: ierr, rank, comsize

   call MPI_Init(ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, comsize, ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)


   print *, 'Hello, world, from image ', rank, &
            'of ', size, '!'!

   call MPI_Finalize(ierr)
end program MPIHelloWorld
