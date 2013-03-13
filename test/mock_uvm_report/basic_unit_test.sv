import svunit_pkg::*;
import svunit_uvm_mock_pkg::*;

`include "svunit_defines.svh"
`include "test_defines.svh"
`include "basic.sv"
`include "svunit_uvm_mock_defines.sv"
typedef class c_basic_unit_test;

module basic_unit_test;
  c_basic_unit_test unittest;
  string name = "basic_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule


class c_basic_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  basic my_basic;


  //===================================
  // Constructor
  //===================================
  function new(string name);
    super.new(name);

    my_basic = new("my_basic");
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    super.setup();

    uvm_report_mock::setup();
  endtask


  //===================================
  // Here we deconstruct anything we 
  // need after running the Unit Tests
  //===================================
  task teardown();
    super.teardown();
  endtask


  //===================================
  // All tests are defined between the
  // SVUNIT_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SVTEST(_NAME_)
  // `SVTEST_END(_NAME_)
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END(mytest)
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(init_expected_cnts)
    `FAIL_IF(uvm_report_mock::expected_error_cnt() != 0);
    `FAIL_IF(uvm_report_mock::expected_fatal_cnt() != 0);
  `SVTEST_END(init_expected_cnts)


  `SVTEST(init_actual_cnts)
    `FAIL_IF(uvm_report_mock::actual_error_cnt() != 0);
    `FAIL_IF(uvm_report_mock::actual_fatal_cnt() != 0);
  `SVTEST_END(init_actual_cnts)


  `SVTEST(verify_complete)
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END(verify_complete)

  // you'll find these defined in test_defines.svh
  `TEST_SET(error)
  `TEST_SET(fatal)

  `SVUNIT_TESTS_END

endclass


