`include "svunit_defines.svh"

package svunit_pkg;

`ifdef SVUNIT_VERSION
  const string svunit_version = `SVUNIT_VERSION;
`else
  const string svunit_version = "For SVUnit Version info, see: $SVUNIT_INSTALL/VERSION.txt";
`endif

  `include "svunit_types.svh"
  `include "svunit_base.sv"
  `include "svunit_testcase.sv"
  `include "svunit_testsuite.sv"
  `include "svunit_testrunner.sv"
  `include "svunit_globals.svh"
endpackage
