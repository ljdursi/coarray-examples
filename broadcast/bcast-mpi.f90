program broadcast 
    use mpi
    implicit none
    integer :: a
    integer :: ierr, rank

    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)

    if (rank == 0) then 
        print *, "Please enter a number." 
        read *, a
    end if

    call MPI_Bcast(a, 1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)

    print *, rank, ' has a = ', a
    call MPI_Finalize(ierr)
end program broadcast
