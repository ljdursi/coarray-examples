#!/bin/bash
sudo apt-get update
sudo apt-get install -y g++
sudo apt-get install -y libmpfr-dev libgmp-dev libmpc-dev
sudo apt-get install -y git
sudo apt-get install -y make

mkdir tmp
cd tmp
##
##GCC
##
wget http://mirrors.concertpass.com/gcc/releases/gcc-5.1.0/gcc-5.1.0.tar.bz2
tar -xjf gcc-5.1.0.tar.bz2
rm -rf gcc-5.1.0.tar.bz2
cd gcc-5.1.0
./configure --prefix=/opt/gcc/5.1 --enable-threads --enable-languages=c,c++,fortran --disable-multilib
make -j 3
sudo make install
cd ..
rm -rf gcc-5.1.0
sudo apt-get remove -y g++

export PATH=/opt/gcc/5.1/bin:${PATH}
export LD_LIBRARY_PATH=/opt/gcc/5.1/lib64:${LD_LIBRARY_PATH}
##
##MPICH3
##
wget http://www.mpich.org/static/downloads/3.1.4/mpich-3.1.4.tar.gz
tar -xzf mpich-3.1.4.tar.gz
cd mpich-3.1.4
FC=/opt/gcc/5.1/bin/gfortran F77=/opt/gcc/5.1/bin/gfortran CC=/opt/gcc/5.1/bin/gcc CXX=/opt/gcc/5.1/bin/g++ ./configure --prefix=/opt/mpich/3.1.4 --enable-fortran=f77,fc --enable-romio --enable-threads=runtime
make -j 3
sudo make install
cd ..
rm -rf mpich-3.1.4 mpich-3.1.4.tar.gz
##
## Open Coarrays
##
cd ..
git clone https://github.com/sourceryinstitute/opencoarrays.git
cd opencoarrays
FC=/opt/gcc/5.1/bin/gfortran GCC=/opt/gcc/5.1/bin/gcc MPFC=/opt/mpich/3.1.4/bin/mpifort make mpi
sudo mkdir -p /opt/opencoarrays/lib64
sudo cp mpi/libcaf_mpi.a /opt/opencoarrays/lib64

cd 

rm -rf tmp

echo 'export PATH=/opt/gcc/5.1/bin:/opt/mpich/3.1.4/bin:${PATH}' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/opt/gcc/5.1/lib64:/opt/mpich/3.1.4/lib:/opt/opencoarrays/lib64/:${LD_LIBRARY_PATH}' >> ~/.bashrc

git clone https://github.com/ljdursi/coarray-examples.git
