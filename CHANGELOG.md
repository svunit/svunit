# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

### Fixed
- Fix compile performance in Xcelium (and probably other tools) when running with UVM
- Fixed experimental code to work after internal refactoring of test execution classes


## [3.37.1] - 2024-11-08

### Fixed

- Fix experimental code to avoid clash with included files


## [3.38.0] - 2024-05-02

### Added
- Add support for Xilinx Vivado (TM) Simulator
- Add possibility to specify elaboration options
- Add possibility to list available tests without actually running them

### Fixed
- Fix warning in VCS when using `SVUNIT_CLK_GEN
- Stop printing "RUNNING" messages for test cases where all tests are filtered out ([#207](https://github.com/svunit/svunit/issues/207))


## [3.37.0] - 2023-09-18

### Added
- Add support for Verilator
- Add `--enable-experimental` option for `runSVUnit` which activates incubating features.
  Currently, this includes a more streamlined way of defining tests.

### Fixed
- Fix csh setup script to work with directory paths containing spaces
- Fix compile error in Vivado (and maybe others) caused by `typedef` in class
- Signal internal execution error when command started by `runSVUnit` fails


## [3.36.1] - 2022-09-10

### Fixed
- Fix `FAIL_IF_EQUALS` and `FAIL_UNLESS_EQUALS` to work with expressions with side-effects


## [3.36.0] - 2022-08-27 [YANKED]

### Added
- Support for `qrun` (QuestaSim one-step flow)
- Add possibility to specify multiple filter (simple) wildcard patterns for `--filter` option
- Add possibility to specify negative filter (simple) wildcard patterns for `--filter` option
- Add `--directory` option to specify where to look for `_unit_test.sv` files
- Print values of expressions compared by `FAIL_IF_EQUALS` and `FAIL_UNLESS_EQUALS` macros

### Fixed
- Fix broken compilation for QuestaSim
- Fix argument checking for partial wildcards in filter expression
- Fix help for `runSVUnit` to mention DSim and `--filter` option


## [3.35.0] - 2021-11-04

### Added
- Generation of (Apache Ant) JUnit XML
- Imported user guide from http://agilesoc.com/open-source-projects/svunit/svunit-user-guide/ into
  repo
- Support for DSim
- `--filter` option for `runSVUnit` to control which tests should run

### Fixed
- Fixed FAIL_IF and FAIL_UNLESS macros to properly implement SystemVerilog
  semantics w.r.t. handling of unknown values (#51)


## [3.34.2] - 2020-11-29

### Fixed

- Fix fail macros to contain `begin`/`end` blocks, so that they can be used inside `if` statements.


## [3.34.1] - 2020-08-23

### Fixed

- Fix shebangs in scripts to use '/usr/bin/env'.
- Remove unused SV file from 'bin' directory.
- Fix issues when UUT names contain 'static' or 'automatic'.


## [3.34.0] - 2020-08-15

### Added
- Detect simulator automatically, based on what tools are on 'PATH'.
- Support for Cadence Xcelium (TM).

### Changed
- Start following [SemVer](https://semver.org) properly.


# Legacy versions

## [3.33] - 2018-08-21

* wavedrom update to handle task outputs

## [3.32] - 2018-08-21

* updated the license headers b/c they were from a bad initial copy paste

## [3.31] - 2018-08-20

* merge wavedrom

## [3.30] - 2018-01-17

* pull https://github.com/tudortimi/svunit-code.git fix_uvm_build

## [3.29] - 2018-01-17

* pull https://github.com/jesseprusi/svunit-code.git patch-4

## [3.28] - 2018-01-17

* pull https://github.com/B00Ze/svunit-code.git tests_fix

## [3.27] - 2018-01-17

* pull https://github.com/tudortimi/svunit-code.git tudortimi-add_gitignore

## [3.26] - 2017-01-04

* pull https://github.com/jesseprusi/svunit-code.git patch-3

## 3.25 - ?

* pull https://github.com/chris-n-johnson/svunit-code.git fail_macro_argument_grouping

## 3.24 - ?

* update for issue #20

## 3.23 - ?

* pull https://github.com/jesseprusi/svunit-code.git patch-1

## 3.22 - ?

* pull https://github.com/jesseprusi/svunit-code.git patch-2

## 3.21 - ?

* pull https://github.com/chris-n-johnson/svunit-code.git fix-regex-used-for-cleanup

## 3.20 - ?

* add vcs top to runSVUnit command line

## 3.19 - ?

* add a timeout when SVUNIT_TIMEOUT is defined

## 3.18 - ?

* update for issue #17,#18
* pull https://github.com/jesseprusi/svunit-code.git master

## 3.17 - ?

* vhdl support via -m switch

## 3.16 - ?

* pull https://github.com/tudortimi/svunit-code.git select_sim_for_tests

## 3.15 - ?

* update for issue #7

## 3.14 - ?

* test generalizing to make the regression suite easier/more robust
* udpate for issue #12

## 3.13 - ?

* testsuite specific updates

## 3.12 - ?

* calling FAIL macros outside the testcase
* update for issue #4

## 3.11 - ?

* uvm 1.2 support

## 3.10 - ?

* add the clk_and_reset.svh
* beta support for vhdl file lists

## 3.9 - ?

* remove File::Which dependancy
* improved create_unit_test.pl help for -uvm

## 3.8 - ?

* add support for 'create_unit_test.pl -uvm' to generate uvm test case templates

## [3.7] - 2015-06-18

* update for ticket 57
* update for ticket 63
* re-added svunit user feedback that continues counting

## [3.6] - 2014-10-15

* swapped the get_child for has_child to get rid of the NOCHILD warning

## [3.5] - 2014-09-27

* .testrunner.sv build properly in outdir now (ticket 61 safe to close now)

## [3.4] - 2014-09-25

* can have absolute or relative path for -f <file>

## [3.3] - 2014-09-25

* update for ticket 61
* update for ticket 62

## [3.2] - 2014-08-13

* fix perl IO::File in runSVUnit

## [3.1] - 2014-08-12

* major scripting update

## [2.12] - 2014-07-02

* rm the docs

## [2.11] - 2014-05-28

* update for ticket 53
* update for ticket 50

## [2.10] - 2014-05-22

* fixes for tickets 56 and 58

## [2.9] - 2014-05-08

* vcs was broken without the sverilog/R switches. now it's fixed.

## [2.8] - 2014-04-09

* closed ticket 56
* add support for Riviera. I sure hope that works.

## [2.7] - 2014-01-16

* updates to avoid SIM_ARG and RUN_LOG being cleared

## [2.6] - 2014-01-14

* updates to questa.mk and addition of modelsim.mk (same files)

## [2.5] - 2013-09-23

* closed ticket 51

## [2.4] - 2013-09-03

* updated the ability to run sims from a parent dir that include any/all child unit tests

## [2.3] - 2013-07-19

* README.txt update to fix a SVTEST_END example

## [2.2] - 2013-07-19

* failed release

## [2.1] - 2013-06-17

* SVTEST_END macro update, parentheses are no longer necessary
* automated the version update that ends up being displayed in the testrunner pass/fail msg

## [1.9] - 2013-06-11

* minor update to the uvm_report_mock to add dumping in the condition where the # of expected/actual don't match

## [1.8] - 2013-06-04

* add svunit user feedback

## [1.7] - 2013-06-04

* closed tickets 46 and 48
* testsuites and makefiles no longer use abs paths
* new macros for string comparison

## [1.6] - 2013-05-24

* class infrastructure refactoring to consolidate functionality/rm superfluous code
* logging update to remove redundant info
* SVTEST_END() macro update. argument no longer required

## [1.5] - 2013-05-17

* update the uvm_express example to be ius compatible (the coverage_unit_test.sv was holding us back to this point and I've rectified that with updates to the svunit-ius.mks and apb_coverage_unit_test.sv)
* NOTE: IUS is still a little quirky when it comes to polling coverage statistics. seems the initial state of coverage points may start at 100 instead of 0 for some cases.

## [1.4] - 2013-05-17

* in v1.3, UVM_INFO were trapped by the report mock. v1.4 ignores UVM_INFO. they're displayed normally.

## [1.3] - 2013-05-17

* upgrade the uvm_report_mock to allow usage of the global uvm_report_(error/warning/fatal). overridden macros are no longer required
* update the uvm_report_mock to display the actual/expected logging messages for debug

## [1.2] - 2013-04-26

* maintenance release for consolidating functionality that's used and removing functionality that isn't
* refactored/consolidated svunit regression suite
* refactor svunit framework to remove unused features
* refactor perl scripts to remove unused features

## [1.1] - 2013-04-25

* major upgrade to switch to module based svunit hierarchy

## [0.13] - 2013-04-11

* fixed tickets 42 and 44

## [0.12] - 2013-03-13

* add example for the uvm_report_mock
* integrate the example with the unit tests

## [0.11] - 2013-03-12

* confirm ius support (close ticket #31)
* add ius support to the uvm examples

## [0.10] - 2013-03-12

* initial release of the mock_uvm_report object

## [0.9] - 2013-02-07

* more test refactoring
* updates to the uvm examples that were broken since the upgrade to rm the uvm dpi compilation

## [0.8] - 2013-01-31

* success :)
* primarily a maintenence update (no real funcational additions)
* refactored frmwork* unit tests (not included in the release package)
* remove reliance on UVM_HOME for examples and use the build-in uvm libraries that come with simulators
* add thsi RELEASE.txt and update the release script

## [0.7] - 2013-01-31

* it's harder than it looks. broken again.

## [0.6] - 2013-01-31

* This release was completely broken so I removed it entirely

## [0.5] - 2012-09-05

* ?

## [0.4] - 2012-06-29

* ?

## [0.3] - 2012-06-27

* ?

## [0.2] - 2012-06-21

* ?

## [0.1] - 2012-06-11

* ?


[Unreleased]: https://github.com/svunit/svunit/compare/v3.38.0...HEAD
[3.37.1]: https://github.com/svunit/svunit/compare/v3.37.0...v3.37.1
[3.38.0]: https://github.com/svunit/svunit/compare/v3.37.0...v3.38.0
[3.37.0]: https://github.com/svunit/svunit/compare/v3.36.1...v3.37.0
[3.36.1]: https://github.com/svunit/svunit/compare/v3.36.0...v3.36.1
[3.36.0]: https://github.com/svunit/svunit/compare/v3.35.0...v3.36.0
[3.35.0]: https://github.com/svunit/svunit/compare/v3.34.2...v3.35.0
[3.34.2]: https://github.com/svunit/svunit/compare/v3.34.1...v3.34.2
[3.34.1]: https://github.com/svunit/svunit/compare/v3.34.0...v3.34.1
[3.34.0]: https://github.com/svunit/svunit/compare/v3.33...v3.34.0
[3.33]: https://github.com/svunit/svunit/compare/v3.32...v3.33
[3.32]: https://github.com/svunit/svunit/compare/v3.31...v3.32
[3.31]: https://github.com/svunit/svunit/compare/v3.30...v3.31
[3.30]: https://github.com/svunit/svunit/compare/v3.29...v3.30
[3.29]: https://github.com/svunit/svunit/compare/v3.28...v3.29
[3.28]: https://github.com/svunit/svunit/compare/v3.27...v3.28
[3.27]: https://github.com/svunit/svunit/compare/v3.26...v3.27
[3.26]: https://github.com/svunit/svunit/compare/v3.7...v3.26
[3.7]: https://github.com/svunit/svunit/compare/v3.6...v3.7
[3.6]: https://github.com/svunit/svunit/compare/v3.5...v3.6
[3.5]: https://github.com/svunit/svunit/compare/v3.4...v3.5
[3.4]: https://github.com/svunit/svunit/compare/v3.3...v3.4
[3.3]: https://github.com/svunit/svunit/compare/v3.2...v3.3
[3.2]: https://github.com/svunit/svunit/compare/v3.1...v3.2
[3.1]: https://github.com/svunit/svunit/compare/v2.12...v3.1
[2.12]: https://github.com/svunit/svunit/compare/v2.11...v2.12
[2.11]: https://github.com/svunit/svunit/compare/v2.10...v2.11
[2.10]: https://github.com/svunit/svunit/compare/v2.9...v2.10
[2.9]: https://github.com/svunit/svunit/compare/v2.8...v2.9
[2.8]: https://github.com/svunit/svunit/compare/v2.7...v2.8
[2.7]: https://github.com/svunit/svunit/compare/v2.6...v2.7
[2.6]: https://github.com/svunit/svunit/compare/v2.5...v2.6
[2.5]: https://github.com/svunit/svunit/compare/v2.4...v2.5
[2.4]: https://github.com/svunit/svunit/compare/v2.3...v2.4
[2.3]: https://github.com/svunit/svunit/compare/v2.2...v2.3
[2.2]: https://github.com/svunit/svunit/compare/v2.1...v2.2
[2.1]: https://github.com/svunit/svunit/compare/v1.9...v2.1
[1.9]: https://github.com/svunit/svunit/compare/v1.8...v1.9
[1.8]: https://github.com/svunit/svunit/compare/v1.7...v1.8
[1.7]: https://github.com/svunit/svunit/compare/v1.6...v1.7
[1.6]: https://github.com/svunit/svunit/compare/v1.5...v1.6
[1.5]: https://github.com/svunit/svunit/compare/v1.4...v1.5
[1.4]: https://github.com/svunit/svunit/compare/v1.3...v1.4
[1.3]: https://github.com/svunit/svunit/compare/v1.2...v1.3
[1.2]: https://github.com/svunit/svunit/compare/v1.1...v1.2
[1.1]: https://github.com/svunit/svunit/compare/v0.13...v1.1
[0.13]: https://github.com/svunit/svunit/compare/v0.12...v0.13
[0.12]: https://github.com/svunit/svunit/compare/v0.11...v0.12
[0.11]: https://github.com/svunit/svunit/compare/v0.10...v0.11
[0.10]: https://github.com/svunit/svunit/compare/v0.9...v0.10
[0.9]: https://github.com/svunit/svunit/compare/v0.8...v0.9
[0.8]: https://github.com/svunit/svunit/compare/v0.7...v0.8
[0.7]: https://github.com/svunit/svunit/compare/v0.6...v0.7
[0.6]: https://github.com/svunit/svunit/compare/v0.5...v0.6
[0.5]: https://github.com/svunit/svunit/compare/v0.4...v0.5
[0.4]: https://github.com/svunit/svunit/compare/v0.3...v0.4
[0.3]: https://github.com/svunit/svunit/compare/v0.2...v0.3
[0.2]: https://github.com/svunit/svunit/compare/v0.1...v0.2
[0.1]: https://github.com/svunit/svunit/tree/v0.1
