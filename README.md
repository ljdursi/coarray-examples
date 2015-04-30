# Coarray Fortran Examples

Simple Coarray Fortran examples for teaching.

Using gfortran 5.1, mpich3, and the [OpenCoarrays](https://github.com/sourceryinstitute/opencoarrays) MPI 
backend, one compiles and runs these programs as follows:

```
mpifort diffusion/diffusion-coarray.f90 -fcoarray=lib -o diffusion/diffusion-coarray -L ${PATH_TO_OPENCOARRAY_LIB} -lcaf_mpi
mpirun -np 8 testReduction
```

A Makefile is provided which you can edit to include the relevant paths.
