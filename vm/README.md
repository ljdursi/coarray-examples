# Vagrant VM instructions

Hopefully this will be unnecessary in a month or so; but right now, packages for GCC 5.1 and OpenCoarrays
aren't common. 

This is a vagrantfile for building or using a VM that has OpenCoarrays, GCC 5.1, and MPICH3 installed.
OpenCoarrays, for simplicity, has been built with the less-performant MPI backend.

To use this Virtual Machine,

* Install [Vagrant](https://www.vagrantup.com)
* Install [VirtualBox](https://www.virtualbox.org)
* To build the VM yourself,
    * Type `vagrant up` and the base VM will install, as will the software
    * The gcc build can take about an hour.
* Otherwise, in a seperate directory,
    * Type `vagrant init ljdursi/opencoarrayVM`
    * Type `vagrant up`; this will download and start the binary VM.
* Once the VM is up and runnnig, type `vagrant ssh` to log into the VM.
* From there, you should be able to `cd coarray-examples` and type `make` to build the examples.
* Then, eg, `mpirun -np 4 helloworld/hw-coarray` will run them.
