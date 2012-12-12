CSLP 1 "DECEMBER 2012" Linux "User Manuals"
=======================================

NAME
----

cslp - An Exact Stochastic Simulator

SYNOPSIS
--------

`cslp` [options] [*input-script*]

DESCRIPTION
-----------

`cslp` provides exact stochastic simulation of molecule reactions as defined in
a script file and outputs the series of events

OPTIONS
-------
`--trackalloc`
This allows tracking of object allocations. This isnt terribly useful as
some objects are not released by the underlying gnustep library

`--wall`
Treat all configuration file warnings as errors

`--aggregator`
The aggregator can aggregate the state changes in the simulation before it is sent to the
writer. Valid options are:

* `PassthroughAggregator` All state changes are logged
* `HundredMsAggregator` At least a hundred ms needs to have passed for a state change to be logged
* `ExactHundredMsAggregator` Writes the state exactly every hundred milliseconds. Possibly slightly slower than the other aggregator as it has to do more allocations
* `ResultOnlyAggregator` Writes the last output only

`--writer`
The writer defines how the state changes will be written. Valid options are

* `AssignmentCsvWriter` Writes in the (invalid) Csv format specified by the assignment
* `RfcCsvWriter` Csv writer that conforms to [RFC 4180](http://tools.ietf.org/html/rfc4180)

`--logfname`
The file name to write the log to. If not specified then the log is not written to a fail.

`--logflevel`
The log level for the file log. If `--logfname` is not set then this is ignored. This should by one of: debug, info, warn, error

`--logstderrlevel`
The log level for the stderr log. This should by one of: debug, info, warn, error

`--seed`
The seed of the random number generator used to run the simulation. If this is not specified then time(NULL) is used.


AUTHOR
------

Jacob Essex <cslp@jacobessex.com>
