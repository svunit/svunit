#!/usr/bin/csh

# source the setup file
cd ../..
source Setup.csh
cd test/frmwrk_14

# remove and create the unit_test
rm -rf dut_unit_test.sv;
create_unit_test.pl -overwrite -out dut_unit_test.sv dut.sv

# create the Makefile
create_svunit.pl

# build and run svunit with vcsi
make

# check the log output for a PASS from the testrunner
if ( ! -e run.log ) then
  echo run.log does not exist
  exit 1;
endif

grep "INFO:  \[0\]\[testrunner\]: Testrunner::PASSED" run.log >/dev/null
if ( $status != 0 ) then
  echo PASS not detected from Testrunner in run.log
  exit 1;
endif

exit 0
