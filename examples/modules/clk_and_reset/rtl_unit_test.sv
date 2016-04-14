`include "svunit_defines.svh"
`include "rtl.v"
`include "clk_and_reset.svh"

module rtl_unit_test;
  import svunit_pkg::svunit_testcase;

  string name = "rtl_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================

  `CLK_RESET_FIXTURE(5, 11)

  reg a, b;
  wire ab, Qab;
  rtl my_rtl(.*);


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

    reset();
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

  //---------------------------------
  // verify the combinational output
  //---------------------------------
  `SVTEST(ab_output_is_1)
    a = 1;
    b = 1;

    pause();
    
    `FAIL_IF(ab !== 1);
  `SVTEST_END

  `SVTEST(ab_output_is_0)
    a = 0;
    b = 1;

    pause();

    `FAIL_IF(ab !== 0);
  `SVTEST_END

  //---------------------------
  // verify the flopped output
  //---------------------------
  `SVTEST(Qab_output_is_1)
    a = 1;
    b = 1;

    step();
    nextSamplePoint();

    `FAIL_IF(Qab !== 1);
  `SVTEST_END

  `SVTEST(Qab_output_is_0)
    a = 1;
    b = 0;

    step();
    nextSamplePoint();

    `FAIL_IF(Qab !== 0);
  `SVTEST_END


  //------------------------------------
  // verify the reset state of the flop
  //------------------------------------
  `SVTEST(reset_state)
    rst_n = 0;

    nextSamplePoint();

    `FAIL_IF(Qab !== 0);
  `SVTEST_END

  `SVUNIT_TESTS_END

endmodule
