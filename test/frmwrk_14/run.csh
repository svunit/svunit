#!/usr/bin/csh

# source the setup file
cd ../..
source Setup.csh
cd test/frmwrk_14

# remove and create the unit_test
rm -rf dut_unit_test.sv;
create_unit_test.pl -overwrite -out dut_unit_test.sv dut.sv

# build the framework
runSVUnit

expect_file run.log
expect_testrunner_pass run.log

exit 0



source ../test_functions.bsh

setup

# remove and create the unit_test
create_unit_test test.sv

# build the framework
buildSVUnit

# generate golden reference files
golden_class_unit_test              test test
golden_testsuite_with_1_unittest    test
golden_testrunner_with_1_testsuite

# verify the output
verify_file                         test_unit_test.gold test_unit_test.sv &&
verify_testsuite                    testsuite.gold &&
verify_testrunner                   testrunner.gold .
