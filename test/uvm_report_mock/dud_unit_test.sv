import svunit_pkg::*;
import svunit_uvm_mock_pkg::*;

`include "svunit_defines.svh"
`include "dud.sv"
typedef class c_dud_unit_test;

module dud_unit_test;
  c_dud_unit_test unittest;
  string name = "dud_ut";

  function void setup();
    unittest = new(name);
  endfunction
endmodule

class c_dud_unit_test extends svunit_testcase;

  //===================================
  // This is the class that we're 
  // running the Unit Tests on
  //===================================
  dud my_dud;


  //===================================
  // Constructor
  //===================================
  function new(string name);
    super.new(name);

    my_dud = new("my_dud");
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


  `SVTEST(expect_error)
    uvm_report_mock::expect_error();
    `FAIL_IF(uvm_report_mock::expected_error_cnt() != 1);
  `SVTEST_END(expect_error)


  `SVTEST(actual_error)
    uvm_report_mock::actual_error();
    `FAIL_IF(uvm_report_mock::actual_error_cnt() != 1);
  `SVTEST_END(actual_error)


  `SVTEST(incomplete_w_expected_error)
    uvm_report_mock::expect_error();
    `FAIL_IF(uvm_report_mock::verify_complete());
  `SVTEST_END(incomplete_w_expected_error)


  `SVTEST(incomplete_w_actual_error)
    uvm_report_mock::actual_error();
    `FAIL_IF(uvm_report_mock::verify_complete());
  `SVTEST_END(incomplete_w_actual_error)


  `SVTEST(complete_w_actual_and_expected)
    uvm_report_mock::actual_error();
    uvm_report_mock::expect_error();
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END(complete_w_actual_and_expected)


  `SVTEST(actual_string_expect_null)
    uvm_report_mock::actual_error("MESSAGE", "ID");
    uvm_report_mock::expect_error();
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END(actual_string_expect_null)


// `SVTEST(actual_string_expect_wrong_message)
//   uvm_report_mock::actual_error("MESSAGE", "ID");
//   uvm_report_mock::expect_error("wrong_MESSAGE", "ID");
//   `FAIL_IF(uvm_report_mock::verify_complete());
// `SVTEST_END(actual_string_expect_wrong_message)
  

  `SVUNIT_TESTS_END

endclass


