program broadcast 
    implicit none
    integer :: a[*] 
    integer :: i

    if (this_image() == 1) then 
        print *, "Please enter a number." 
        read *, a
        do i=1,num_images() 
            a[i] = a
        end do 
    end if

    sync all 

    print *, this_image(), ' has a = ', a
end program broadcast
