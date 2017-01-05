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
    // this should have the "running" and "pass" logged
    `SVTEST(first_test)
    `SVTEST_END


    // this should have the "running" and "fail" logged w/1 error
    `SVTEST(second_test)
      `FAIL_IF(1);
    `SVTEST_END


    // this should have the "running" and "fail" logged w/1 error
    `SVTEST(third_test)
      static int beam = 4;
      `FAIL_UNLESS(beam == 1);
      `FAIL_IF(beam != 2);
    `SVTEST_END

    // this should fail on the second test only
    `SVTEST(fourth_test)
      `FAIL_IF_EQUAL('ha,15)
      `FAIL_IF_EQUAL('hf,15)
    `SVTEST_END

    // this should fail on the second test only
    `SVTEST(fifth_test)
      `FAIL_UNLESS_EQUAL(10,'ha)
      `FAIL_UNLESS_EQUAL(15,'ha)
    `SVTEST_END

    // verify the extra log string output
    `SVTEST(sixth_test)
      static int bozo = 4;
      static string gum = "gum is wrong";
      `FAIL_UNLESS_LOG(bozo == 1, "bozo is wrong");
    `SVTEST_END

    `SVTEST(seventh_test)
      static int bozo = 4;
      static string gum = "gum is wrong";
      `FAIL_IF_LOG(bozo != 2, $psprintf("%s %0d", gum, bozo));
    `SVTEST_END

    // verify FAIL_IF_EQUAL works with ternary operator (should pass)
    `SVTEST(eighth_test)
      static logic [3:0] data_a = 4'h7;
      static logic [3:0] data_b = 4'hf;
      static logic       select = 0;
      `FAIL_IF_EQUAL(data_a, select ? data_a : data_b);
    `SVTEST_END

    // verify FAIL_IF_EQUAL works with ternary operator (should pass)
    `SVTEST(ninth_test)
      static logic [3:0] data_a = 4'h7;
      static logic [3:0] data_b = 4'hf;
      static logic       select = 1;
      `FAIL_IF_EQUAL(select ? data_a : data_b, data_b);
    `SVTEST_END

    // verify FAIL_UNLESS_EQUAL works with ternary operator (should pass)
    `SVTEST(tenth_test)
      static logic [3:0] data_a = 4'h7;
      static logic [3:0] data_b = 4'hf;
      static logic       select = 0;
      `FAIL_UNLESS_EQUAL(data_b, select ? data_a : data_b);
    `SVTEST_END

    // verify FAIL_UNLESS_EQUAL works with ternary operator (should pass)
    `SVTEST(eleventh_test)
      static logic [3:0] data_a = 4'h7;
      static logic [3:0] data_b = 4'hf;
      static logic       select = 1;
      `FAIL_UNLESS_EQUAL(select ? data_a : data_b, data_a);
    `SVTEST_END
  `SVUNIT_TESTS_END


endmodule
