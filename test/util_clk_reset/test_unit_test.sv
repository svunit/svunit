`include "svunit_defines.svh"
`include "test.sv"
`include "clk_and_reset.svh"

module test_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "test_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  test my_test();

  `define HPERIOD 31
  `define RSTLENGTH 3
  `CLK_RESET_FIXTURE(`HPERIOD,`RSTLENGTH)

  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  int start;
  task setup();
    svunit_ut.setup();
    /* Place Setup Code Here */

    start = $time;
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */
    step();
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

  `SVTEST(clk_single_step)
    step();
    `FAIL_IF($time - start !== 2*`HPERIOD)
  `SVTEST_END

  `SVTEST(clk_multiple_step)
    step(11);
    `FAIL_IF($time - start !== 11*2*`HPERIOD)
  `SVTEST_END

  `SVTEST(reset_length)
    reset();
    `FAIL_IF($time - start !== (`RSTLENGTH+1)*2*`HPERIOD)
  `SVTEST_END

  `SVTEST(nextSamplePoint_once)
    step();
    nextSamplePoint();
    `FAIL_IF($time - start !== 2*`HPERIOD + 1)
  `SVTEST_END

  `SVTEST(nextSamplePoint_repeated)
    step();
    repeat (23) nextSamplePoint();
    `FAIL_IF($time - start !== 2*`HPERIOD + 1)
  `SVTEST_END

  `SVTEST(clk_after_nextSamplePoint)
    step();
    repeat (23) nextSamplePoint();
    step();
    `FAIL_IF($time - start !== 4*`HPERIOD)
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
