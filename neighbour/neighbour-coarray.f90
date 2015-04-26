program coarray1
  implicit none
  integer :: me, right, i
  integer, dimension(3), codimension[*] :: a

  me = this_image()
 
  right = me + 1
  if (right > num_images()) right = 1

  a(:) = [ (me**i, i=1, 3) ]

  sync all

  print *, "Image ", me, " has a(2) = ", a(2)[me], "; neighbour has ", a(2)[right]
end program coarray1
