program blockmatrix
    use mpi
    implicit none
    integer, dimension(:,:), allocatable :: a, b, c, aremote, bremote
    integer, dimension(:,:), allocatable :: bigmat
    integer :: rank, comsize, ierr
    integer :: nrows, ncols, dims(2)=0, coords(2)
    integer :: blockrows=5, blockcols=5
    integer :: myrow, mycol
    integer :: startrow, startcol
    integer :: i,j,k
    integer :: cartcomm, rowcomm, colcomm

    call MPI_Init(ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, comsize, ierr)

    ! calculate block decomposition
    call MPI_Dims_create(comsize, 2, dims, ierr)
    nrows = dims(1)
    ncols = dims(2)
    if (nrows /= ncols) then
        print *,'Sorry, only works for square numbers of processes right now.'
        stop
    endif

    allocate(a(blockrows,blockcols))
    allocate(b(blockcols,blockrows))
    allocate(c(blockrows,blockrows))
    allocate(aremote(blockrows,blockcols))
    allocate(bremote(blockcols,blockrows))

    call MPI_Cart_create(MPI_COMM_WORLD, 2, dims, [1,1], 1, cartcomm, ierr)
    call MPI_Comm_rank(cartcomm, rank, ierr)
    call MPI_Cart_coords(cartcomm, rank, 2, coords, ierr)
    mycol = coords(1)+1
    myrow = coords(2)+1

    ! create row, column communicators
    call MPI_Comm_split( cartcomm, myrow, mycol, rowcomm, ierr )
    call MPI_Comm_split( cartcomm, mycol, myrow, colcomm, ierr )

    ! initialize data
    startrow = (myrow-1)*blockrows+1
    startcol = (mycol-1)*blockcols+1
    do i=1,blockrows
        a(i,:) = startrow+i-1
    enddo
    do j=1,blockcols
        b(:,j) = startcol+j-1
    enddo

    ! do the multiplication
    c = 0.
    do k=0,ncols-1
        aremote = a
        bremote = b
        call MPI_Bcast(aremote, blockrows*blockcols, MPI_INTEGER, k, rowcomm, ierr)
        call MPI_Bcast(bremote, blockrows*blockcols, MPI_INTEGER, k, colcomm, ierr)
        c = c + matmul(aremote, bremote)
    enddo

    if (rank == 0) then
        allocate(bigmat(nrows*blockrows,ncols*blockcols))
        bigmat = reshape( [((i,i=1,nrows*blockrows),j=1,ncols*blockcols)], &
                          [nrows*blockrows, ncols*blockcols])
        print *, 'Expected answer: '
        bigmat = matmul(bigmat,transpose(bigmat))
        do i=1,blockrows*nrows
             print '(50(I5,1X))',(bigmat(i,j),j=1,blockcols*ncols)
        enddo
        deallocate(bigmat)
    endif

    do k=0,comsize-1
        if (rank == k) then
            print *, 'Image ', k+1, ' = ', myrow, ', ', mycol 
            do i=1,blockrows
                 print '(50(I5,1X))',(c(i,j),j=1,blockcols)
            enddo
        endif
        call MPI_Barrier(MPI_COMM_WORLD,ierr)
    enddo
    deallocate(a)
    deallocate(b)
    deallocate(c)

    call MPI_Finalize(ierr)

end program blockmatrix
