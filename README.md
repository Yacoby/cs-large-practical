Computer Science Large Practical
================================

Introduction
------------

Building
------------
This requires:
- gnustep-base
- gnustep-make

This was also built on (Arch) Linux using GNUstep. It is not possible to build
on DICE using the makefiles as DICE doesn't have gnustep-make

Ensure you have run GNUstep.sh to setup your environmental variables.
[See the GNUstep documentation for more details](http://www.gnustep.org/resources/documentation/User/GNUstep/gnustep-howto_4.html)

cd into the root of the Cslp directory and run `make`. This will build the binary and write it to  `Cslp.app/Cslp`.
This will also compile the application into a library that is used when running tests

Running Tests
-------------
If you want to run the tests, ensure that you have first built the application and then run `gnustep-tests`

Running the Application
-----------------------
Run `./Cslp.app/Cslp'

Command Line Arguments
-----------------------
Run `./Cslp.app/Cslp --help` to see command line options
