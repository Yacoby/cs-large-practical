Computer Science Large Practical
================================

Introduction
------------

This is the program for 2012 Computer Science Large Practical as setout in the [Handout](http://www.inf.ed.ac.uk/teaching/courses/cslp/coursework/CSLP-2012.pdf)

Building
------------
This requires:

* gnustep-base
* gnustep-make

This was also built on (Arch) Linux using GNUstep.

Ensure you have run GNUstep.sh to setup your environmental variables.
[See the GNUstep documentation for more details](http://www.gnustep.org/resources/documentation/User/GNUstep/gnustep-howto_4.html)

`cd` into the root of the Cslp directory and run `make`. This will build the binary and write it to  `Cslp.app/Cslp`.
This will also compile the code into a library that is used to run tests against.

Running Tests
-------------
If you want to run the tests, ensure that you have first built the application and then run `gnustep-tests`

Running the Application
-----------------------
Run `./Cslp.app/Cslp` with the first argument as the input script file. For example:
`./Cslp.app/Cslp exampes/decay.txt`

Command Line Arguments
-----------------------
Run `./Cslp.app/Cslp --help` to see an up to date list of command line options
