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
  // `SVTEST_END()
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END()
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(fail_unless_str_equal_with_two_different_strings)
    `FAIL_UNLESS_STR_EQUAL("abd", "abcd")
  `SVTEST_END()


  `SVTEST(fail_unless_str_equal_with_two_identical_strings)
    `FAIL_UNLESS_STR_EQUAL("nice string-with lots of stuff!?!","nice string-with lots of stuff!?!")
  `SVTEST_END()


  `SVTEST(fail_unless_str_equal_with_one_string_and_one_string_object)
    string str = "nice string-with lots of stuff!?!";
    `FAIL_UNLESS_STR_EQUAL("nice string-with lots of stuff!?!",str)
  `SVTEST_END()


  `SVTEST(fail_unless_str_equal_with_two_strings_objects)
    string str = "nice string-with lots of stuff!?!";
    `FAIL_UNLESS_STR_EQUAL(str,str)
  `SVTEST_END()


  `SVTEST(fail_if_str_equal_with_two_identical_strings)
    `FAIL_IF_STR_EQUAL("abcd", "abcd")
  `SVTEST_END()


  `SVTEST(fail_if_str_equal_with_two_different_strings)
    `FAIL_IF_STR_EQUAL("nice string-with lots of stuff","nice string-with.lots of stuff")
  `SVTEST_END()


  `SVTEST(fail_if_str_equal_with_one_string_and_one_string_object)
    string str = "nice string-with lots of stuff";
    `FAIL_IF_STR_EQUAL("nice string-with.lots of stuff",str)
  `SVTEST_END()


  `SVTEST(fail_if_str_equal_with_two_different_strings_objects)
    string stra = "nice string-with lots of stuff";
    string strb = "nice string-with.lots of stuff";
    `FAIL_IF_STR_EQUAL(stra,strb)
  `SVTEST_END()

  `SVUNIT_TESTS_END

endmodule
