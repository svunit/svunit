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

expect_file run.log
expect_testrunner_pass run.log

exit 0
