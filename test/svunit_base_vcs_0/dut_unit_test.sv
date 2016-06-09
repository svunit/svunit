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
  dut my_dut;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_dut = new(/* New arguments if needed */);

    `INFO("Use the INFO macro");
    `ERROR("Use the ERROR macro");
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  bit fail;
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */
    fail = 0;
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */
    `FAIL_IF(fail);
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

  `SVTEST(strictly_so_the_teardown_is_called)
    fail = 1;
  `SVTEST_END

  `SVTEST(fail_if)
    `FAIL_IF(1);
  `SVTEST_END

  `SVTEST(fail_unless)
    `FAIL_UNLESS(0);
  `SVTEST_END

  `SVTEST(fail_if_equal)
    `FAIL_IF_EQUAL(1, 1'hx);
  `SVTEST_END

  `SVTEST(fail_unless_equal)
    `FAIL_UNLESS_EQUAL(1, 1'hx);
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
