Computer Science Large Practical                         {#mainpage}
================================

Note about current state
------------------------
While the solution mostly works, it is far from complete. The main bit of code
that is in any way close to production ready is the CommandLineOptionParser.

Introduction
------------
This is the program for 2012 Computer Science Large Practical as setout in the [Handout](http://www.inf.ed.ac.uk/teaching/courses/cslp/coursework/CSLP-2012.pdf)


This file is written using [Markdown](http://daringfireball.net/projects/markdown/).
While you can convert it to html using [Markdown.pl](http://daringfireball.net/projects/markdown/) or any other converter
it is intergrated with doxygen and apears as the main page of the doxygen documentation

Building
------------
The program requires:

* gnustep-base
* gnustep-make

This was also built on (Arch) Linux using GNUstep.

Ensure you have run GNUstep.sh to setup your environmental variables.
[See the GNUstep documentation for more details](http://www.gnustep.org/resources/documentation/User/GNUstep/gnustep-howto_4.html)

`cd` into the root of the Cslp directory and run `make`. This will build the binary and write it to  `Cslp.app/Cslp`.
This will also compile the code into a library that is used to run tests against.

Running the Application
-----------------------
The Unix way of running the program is to pass the program the input script
through stdin and let the program write the output to stdout.For example:  
`cat ./examples/decay.txt | ./Cslp.app/Cslp`

Due to the requirements of the application it is also possible to pass as the first argument
the path to the file to read. For example:  
`./Cslp.app/Cslp exampes/decay.txt`

If you want to output elsewhere than stdout then the following are equivalent:  
`./Cslp.app/Cslp exampes/decay.txt > output.txt`  
`./Cslp.app/Cslp exampes/decay.txt --output output.txt`

Command Line Arguments
-----------------------
Run `./Cslp.app/Cslp --help` to see an up to date list of command line options

Documentation
-------------
The documentation should be generated using doxygen. This file will be included as part of
the main page

Running Tests
-------------
From the project root directory run `gnustep-tests`


Other code
-----------
tests/Testing.h is not my code and comes from gnustep. It is a set of macros that
provide helpers to test functionalith (such as exceptions being raised).
It is included as it doesn't seem to live in a include directory.
