#!/usr/bin/csh

# source the setup file
cd $SVUNIT_ROOT
source Setup.csh
cd -

# remove and create the unit_test
rm -rf dut_unit_test.sv
create_unit_test.pl -overwrite -out dut_unit_test.sv dut.sv

# build the framework
runSVUnit -s $1

if ( ! -e run.log ) exit 1

exit 0
