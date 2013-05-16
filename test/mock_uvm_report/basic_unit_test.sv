import svunit_pkg::*;
import svunit_uvm_mock_pkg::*;

`include "svunit_defines.svh"
`include "test_defines.svh"

`include "uvm_macros.svh"

`include "basic.sv"


module basic_unit_test;

  string name = "basic_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're 
  // running the Unit Tests on
  //===================================
  basic my_basic;
  string dump_act, dump_exp;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_basic = new("my_basic");
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    uvm_report_mock::setup();
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
  // `SVTEST_END(_NAME_)
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END(mytest)
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(init_expected_cnts)
    `FAIL_IF(uvm_report_mock::expected_cnt() != 0);
  `SVTEST_END(init_expected_cnts)


  `SVTEST(init_actual_cnts)
    `FAIL_IF(uvm_report_mock::actual_cnt() != 0);
  `SVTEST_END(init_actual_cnts)


  `SVTEST(verify_complete)
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END(verify_complete)


  `TEST_SET(warning)
  `TEST_SET(error)
  `TEST_SET(fatal)


  `SVTEST(actual_error_actual_fatal_expect_in_opposite_order)
    my_basic.actual_error;
    my_basic.actual_fatal;
    uvm_report_mock::expect_fatal();
    uvm_report_mock::expect_error();
    `FAIL_IF(uvm_report_mock::verify_complete()); 
  `SVTEST_END(actual_error_actual_fatal_expect_in_opposite_order)


  `SVTEST(actual_error_actual_fatal_expect_error_expect_fatal)
    my_basic.actual_error;
    my_basic.actual_fatal;
    uvm_report_mock::expect_error("my_basic", "error message");
    uvm_report_mock::expect_fatal("my_basic", "fatal message");
    `FAIL_IF(!uvm_report_mock::verify_complete()); 
  `SVTEST_END(actual_error_actual_fatal_expect_error_expect_fatal)


// `SVTEST(dump_has_header)
//   dump_exp = dump_header();
//   dump_act = uvm_report_mock::dump();
//   `FAIL_IF(dump_act != dump_exp);
// `SVTEST_END(dump_has_header)


  `SVTEST(dump_returns_star_for_expect_anything)
    uvm_report_mock::expect_error();
    uvm_report_error("", "");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>      UVM_ERROR                    \"*\" \"*\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>      UVM_ERROR                     \"\" \"\"\n" };
$display("%s", dump_exp);
    dump_act = uvm_report_mock::dump();
$display("%s", dump_act);
 
    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END(dump_returns_star_for_expect_anything)


// `SVTEST(dump_truncates_ids_longer_than_20)
// `SVTEST_END(dump_truncates_ids_longer_than_20)

// uvm_report_mock::dump
// 0:   EXPECTED => UVM_ERROR                         "*" "*"
//      ACTUAL   => UVM_ERROR                          "" ""
// 1:   EXPECTED => UVM_WARNING                       "*" "*"
//      ACTUAL   => UVM_WARNING    "ID lkj lkjlkjl lkj l" "MSG"
// 2:   EXPECTED => UVM_FATAL                        "ID" "MSG"
//      ACTUAL   =>                <None reported>
// 3:   EXPECTED =>                <None reported>
//      ACTUAL   => UVM_WARNING                      "ID" "MSG"
// 4:   EXPECTED => UVM_ERROR                        "ID" "MSG"
//      ACTUAL   => UVM_ERROR                        "ID" "MSG"
// 5:   EXPECTED => UVM_WARNING                      "ID" "MSG"
//      ACTUAL   => UVM_ERROR                        "ID" "MSG"


  `SVUNIT_TESTS_END

  function string dump_header();
    return "uvm_report_mock::dump\n";
  endfunction

endmodule
