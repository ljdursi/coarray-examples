program blockmatrix
    implicit none
    integer, dimension(:,:), codimension[:,:], allocatable :: a, b, c
    integer, dimension(:,:), allocatable :: bigmat
    integer :: numimgs
    integer :: nrows, ncols
    integer :: blockrows=5, blockcols=5
    integer :: myrow, mycol
    integer :: startrow, startcol
    integer :: i,j,k

    ! calculate block decomposition
    numimgs = num_images()
    call nearsquare(numimgs, nrows, ncols)
    if (nrows /= ncols) then
        print *,'Sorry, only works for square numbers of images right now.'
        stop
    endif
    allocate(a(blockrows,blockcols)[nrows,*])
    allocate(b(blockcols,blockrows)[nrows,*])
    allocate(c(blockrows,blockrows)[nrows,*])

    ! where is this image in the decomposition?
    mycol = ceiling(this_image()*1./nrows)
    myrow = modulo(this_image(),nrows)
    if (myrow == 0) myrow=nrows

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
    sync all
    c = 0.
    do k=1,ncols
        c = c + matmul(a(:,:)[myrow,k],b(:,:)[k,mycol])
    enddo
    sync all

    if (this_image() == 1) then
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

    do k=1,num_images()
        if (this_image() == k) then
            print *, 'Image ', k, ' = ', myrow, ', ', mycol 
            do i=1,blockrows
                 print '(50(I5,1X))',(c(i,j),j=1,blockcols)
            enddo
        endif
        sync all
    enddo
    deallocate(a)
    deallocate(b)
    deallocate(c)

contains 
    subroutine nearsquare(n, a, b)
        implicit none
        integer, intent(in) :: n
        integer, intent(out) :: a, b

        do a=ceiling(sqrt(n*1.0)),1,-1
            b = n/a
            if (a*b == n) exit
        enddo
    end subroutine nearsquare

end program blockmatrix
