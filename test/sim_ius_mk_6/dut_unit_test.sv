`include "svunit_defines.svh"
`include "dut.sv"

import svunit_pkg::*;


module dut_unit_test;

  string name = "dut_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  dut my_dut();


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(get_args)
    bit jokes, bozo;

`ifdef JOKES
    jokes=1;
`endif
`ifdef BOZO
    bozo=1;
`endif

    `FAIL_UNLESS(jokes);
    `FAIL_UNLESS(bozo);
    `FAIL_UNLESS(`DUD == 4);
  `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
