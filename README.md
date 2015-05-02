# Coarray Fortran Examples

Simple Coarray Fortran examples for teaching.

Using gfortran 5.1, mpich3, and the [OpenCoarrays](https://github.com/sourceryinstitute/opencoarrays) MPI 
backend, one compiles and runs these programs as follows:

```
mpifort diffusion/diffusion-coarray.f90 -fcoarray=lib -o diffusion/diffusion-coarray -L ${PATH_TO_OPENCOARRAY_LIB} -lcaf_mpi
mpirun -np 8 diffusion/diffusion-coarray 
```

A Makefile is provided which you can edit to include the relevant paths.

If you don't have gcc 5.1 and opencoarrays installed, you can use the available vagrant VM; 
documentation for downloading the vagrant VM or building it can be found [in the vm directory](vm/README.md)
