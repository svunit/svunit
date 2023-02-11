Running Unit Tests
==================

SVUnit unit tests are run using runSVUnit. Usage of runSVUnit is as follows::

  Usage:  runSVUnit [-s|--sim <simulator> -l|--log <log> -d|--define <macro> -f|--filelist <file> -U|-uvm -m|-mixedsim <vhdlfile>
                    -r|--r_arg <option> -c|--c_arg <option> -o|--out <dir> -t|--test <test> --filter <filter>]
    -s|--sim <simulator>     : simulator is either of questa, modelsim, riviera, ius, xcelium, vcs, dsim or xsim
    -l|--log <log>           : simulation log file (default: run.log)
    -d|--define <macro>      : appended to the command line as +define+<macro>
    -f|--filelist <file>     : some verilog file list
    -r|--r_arg <option>      : specify additional runtime options
    -c|--c_arg <option>      : specify additional compile options
    -U|--uvm                 : run SVUnit with UVM
    -o|--out                 : output directory for tmp and simulation files
    -t|--test                : specifies a unit test to run (multiple can be given)
    -m|--mixedsim <vhdlfile> : consolidated file list with VHDL files and command line switches
    -w|--wavedrom            : process json files as wavedrom output
       --filter <filter>     : specify which tests to run, as <test_module>.<test_name>
    -h|--help                : prints this help screen

Choosing a Simulator
--------------------
SVUnit can be run using most commonly used EDA simulators using the '-s' switch. Supported simulators currently include Mentor Graphics Questa, Cadence Incisive, Synopsys VCS and Aldec Riviera PRO.


Logging
-------

By default, simulation output is written to run.log. The default location can be overridden using the '-l' switch.


Specifying Command-line Macros
------------------------------

SVUnit will pass command line macro defines specified by the '-d' switch directly to the simulator.


Adding Files For Simulation
---------------------------

Through the use of \`include directives, both the unit test template and corresponding UUT file are included in compilation making it possible to build and verify on simple designs without any need to specify or maintain file lists. As designs grow, however, more files can be added using standard simulator file lists and the '-f' switch.

.. note::

    The file svunit.f is automatically included for compilation provided it exists. Thus, files can be added to svunit.f without having to specify '-f svunit.f' on the command line.


Adding Run Time and/or Compile Time Options
-------------------------------------------

It is possible to specified compile and run time options using the '-c_arg' and '-r_arg' switches respectively. All compile and run time arguments are passed directly to the simulator command line.


Enable UVM Component Unit Testing
---------------------------------

For verification engineers unit testing UVM-based components, the '-U' switch must be specified to include relevant run-flow handling.


Specifying a Simulation Directory
---------------------------------

By default, SVUnit is run in the current working directory. However, to avoid mixing source files with simulation output, it is possible to change the location where SVUnit is built and simulated using the '-o' switch. It is an error to use the '-o' switch to runSVUnit that doesn't exist.


Specifying Unit Tests to be Run
-------------------------------

By default, runSVUnit finds and simulates all unit test templates within a given parent directory. For short runs, this is recommended practice. However, if simulation times grow to the point where they are long and cumbersome, it is possible to specify specific unit test templates to be run using the '-t' switch. For example, if a parent directory has 12 unit test templates but you only want to run mine_unit_test.sv, you can use the '-t' switch as::

    runSVunit -t mine_unit_test.sv -s <your simulator>

The '-t' switch can be used to specify multiple unit test templates as:

    runSVunit -t mine_unit_test.sv -t yours_unit_test.sv -s <your simulator>

It's also possible to restrict which individual tests should run. This is done using the '--filter' option.

The following call runs only some_test defined in some_testcase::

    runSVUnit --filter some_testcase.some_test

The following call runs all tests called some_test regardless of which testcase they are defined in::

    runSVUnit --filter *.some_test

The following call runs all tests defined in some_testcase::

    runSVUnit --filter some_testcase.*

The previous command is conceptually similar to using the '-t' option.
While the runtime behavior is the same, it is slightly different in terms of what gets compiled.
Using '-t' selects what gets compiled and by extension limits what can be run.
Using '--filter' only affects which of the tests that were compiled should run, but doesn't control what gets compiled.
Both options are useful, as they serve different purposes.
The '-t' option is helpful when API changes would require modifications to many unit test files, but you would like to update them one after the other.
It is also a very blunt tool, as compilation can only be handled at the file level.
The '--filter' option can be used to focus on finer subsets of tests.
