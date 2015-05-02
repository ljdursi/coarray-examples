MPI_DIR=/opt/mpich/3.1.4
OPENCOARRAYS_DIR=/opt/opencoarrays/lib64

ALLCOARRAYF90=$(wildcard */*-coarray.f90 ) 
ALLMPIF90=$(wildcard */*-mpi.f90 ) 

ALLCOARRAY=$(basename $(ALLCOARRAYF90))
ALLMPI=$(basename $(ALLMPIF90))

.PHONY: clean

all: allcoarray allmpi

allcoarray: $(ALLCOARRAY)

allmpi:     $(ALLMPI)

%-coarray:%-coarray.f90
	${MPI_DIR}/bin/mpifort $^ -fcoarray=lib -o $@ -L ${OPENCOARRAYS_DIR} -lcaf_mpi

%-mpi:%-mpi.f90
	${MPI_DIR}/bin/mpifort $^ -o $@ 

clean:
	-rm -f $(ALLCOARRAY) $(ALLMPI)
	-rm -f */*.o
