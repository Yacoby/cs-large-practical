Computer Science Large Practical
================================

Introduction
------------
This is the program for 2012 Computer Science Large Practical as setout in the [Handout](http://www.inf.ed.ac.uk/teaching/courses/cslp/coursework/CSLP-2012.pdf)

This file is written using [Markdown](http://daringfireball.net/projects/markdown/).
While you can convert it to html using [Markdown.pl](http://daringfireball.net/projects/markdown/) or any other converter
it is intergrated with doxygen and apears as the main page of the doxygen documentation and also bundled as a pdf

Building
--------
The program requires GNUstep and was built on Ubunut 12.10 and Arch Linux GNUstep.

Ensure you have run GNUstep.sh to setup your environmental variables.
[See the GNUstep documentation for more details](http://www.gnustep.org/resources/documentation/User/GNUstep/gnustep-howto_4.html)

`cd` into the root of the Cslp directory and run `make`. This will build the binary and write it to  `Cslp.app/Cslp`.

Building Documentation
----------------------
Documentation for the project can be built using `make docs`. This requires:

* [gimli](https://github.com/walle/gimli)
* `sed` and `rm` (Obviously should be installed)
* [Doxygen](http://www.doxygen.org) 1.8 or greater
* [md2man](https://github.com/sunaku/md2man)

Due to these requirements, the documentation has been prebuilt

(Note: There are a lot of warnings when building the doxygen documentation. This is because I didn't and don't intend to document everything. For example in most cases it should be clear what `-(void)dealloc;` does and documentation adds nothing).

Running the Application
-----------------------
The Unix way of running the program is to pass the program the input script
through stdin and let the program write the output to stdout. For example:  
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


Configuration Script
--------------------
The configuration script is the same as described in the Handout, but with the
following differences.

* Identifiers must be consistent but you can use words as opposed to letters (so you are not limited to 25 molecules)
* t has an alias time, so both `t` and `time` are reserved identifiers
* Comments can be written on the same line as settings
* Support for numbers in scientific notation
* Validation is preformed on the scripts. It should be impossible to use an invalid script and warnings are given for scripts that are have problems (it is possible to treat warnings as errors using the `--wall` command line option)


Output Formats
--------------

There are two things that can effect the output, both configurable via
the command line. The first is the aggregator (`--aggregator`)
which can group up simulator state changes. Valid options for this are:

* `PassthroughAggregator` - All state changes are logged
* `HundredMsAggregator` - At least a hundred ms needs to have passed for a state change to be logged
* `ExactHundredMsAggregator` - Writes the state exactly every hundred milliseconds. Possibly slightly slower than the other aggregator as it has to do more allocations

The second option that can effec the output is the writer itself (`--writer`). Valid options are

* `AssignmentCsvWriter` - Writes in the (invalid) Csv format specified by the assignment
* `RfcCsvWriter` - Csv writer that conforms to [RFC 4180](http://tools.ietf.org/html/rfc4180)

Logging
--------
It was suggested that I add logging. While I am not too fussed (I am fairly sure
about the correctness of the program given the number of unit tests) I suppose it 
is a good idea to have.

As I didn't want to add huge amounts of requirements for something that would be marked
(i.e. I didn't want the marker to have to spend 4+ hours setting up an environment to
build the application) I wrote a very basic logging library that does what I need.

Logging can be enabled using command line paramters see Command Line Arguments for more details.

Note: Early startup errors such as incorrect command line paramters can only be logged to stderr
      as at this point no logs have been created.

Code Documentation
------------------
Documentation for the code (generated using doxygen) can be accessed from the [codedocs.html](codedocs.html) file found in the `doc` directory.

Running Tests
-------------
From the project root directory run `gnustep-tests`

Other code
-----------
tests/Testing.h is not my code and comes from gnustep. It is a set of macros that
provide helpers to test functionality (such as exceptions being raised).
It is included as it doesn't seem to live in a GNUStep include directory.


Commenting
-----------
My general view on code commenting is that if you have to comment the code *implementation*
to explain what you did or why you did it then the code isn't good enough. There are a few exceptions such as:

* Optimized Code
* Code working around bugs/problems

Hence my code has very few comments in the implementation (.m files) but has a quite heavily commented
header files. This comes from experience that despite best intentions comments drift out of sync with
the code which means that you become unsure which is correct (Is comment right and the code wrong or the other way around?).

This partly stems out of having worked on a large project (averaging 8 developers)
 with [Skyscanner](http://www.skyscanner.net) that had almost no comments,
and which tended to mean that developers couldn't write messy code and "fix" it 
by adding a comment and the functions tended to be cleaner. E.g. You couldn't get away with writing:

    int dooFoo(int time);

As it isn't clear what it returns and you know that it takes a time, but is it hours? decades?
So you would would write:

    TimeSpan* dooFoo(TimeSpan* time)

Which adds type safety and removes ambiguity from the arguments without having to resort to comments

While I haven't gone to that extreme in this project, where I have thought that comments may
be needed in the implementation I have instead re-factored the code to attempt to make it more
readable.




