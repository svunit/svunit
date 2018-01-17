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
  // `SVTEST_END
  //
  // i.e.
  //   `SVTEST(mytest)
  //     <test code>
  //   `SVTEST_END
  //===================================
  `SVUNIT_TESTS_BEGIN

  `SVTEST(init_expected_cnts)
    `FAIL_IF(uvm_report_mock::expected_cnt() != 0);
  `SVTEST_END


  `SVTEST(init_actual_cnts)
    `FAIL_IF(uvm_report_mock::actual_cnt() != 0);
  `SVTEST_END


  `SVTEST(verify_complete)
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  `TEST_SET(warning)
  `TEST_SET(error)
  `TEST_SET(fatal)


  `SVTEST(actual_error_actual_fatal_expect_in_opposite_order)
    my_basic.actual_error;
    my_basic.actual_fatal;
    uvm_report_mock::expect_fatal();
    uvm_report_mock::expect_error();
    `FAIL_IF(uvm_report_mock::verify_complete());
  `SVTEST_END


  `SVTEST(actual_error_actual_fatal_expect_error_expect_fatal)
    my_basic.actual_error;
    my_basic.actual_fatal;
    uvm_report_mock::expect_error("my_basic", "error message");
    uvm_report_mock::expect_fatal("my_basic", "fatal message");
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


// `SVTEST(dump_has_header)
//   dump_exp = dump_header();
//   dump_act = uvm_report_mock::dump();
//   `FAIL_IF(dump_act != dump_exp);
// `SVTEST_END


  `SVTEST(dump_returns_star_for_expect_anything)
    uvm_report_mock::expect_error();
    uvm_report_error("", "");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>      UVM_ERROR                    \"*\" \"*\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>      UVM_ERROR                     \"\" \"\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_returns_actual_id_msg)
    uvm_report_mock::expect_warning();
    uvm_report_warning("ID actual", "MSG actual");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>    UVM_WARNING                    \"*\" \"*\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>    UVM_WARNING            \"ID actual\" \"MSG actual\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_returns_expected_id_msg)
    uvm_report_mock::expect_warning("ID expected", "MSG expected");
    uvm_report_warning("ID actual", "MSG actual");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>    UVM_WARNING          \"ID expected\" \"MSG expected\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>    UVM_WARNING            \"ID actual\" \"MSG actual\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_returns_multiple_entries)
    uvm_report_mock::expect_warning("ID exp0", "MSG exp0");
    uvm_report_warning("ID act0", "MSG act0");
    uvm_report_mock::expect_error("ID exp1", "MSG exp1");
    uvm_report_error("ID act1", "MSG act1");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>    UVM_WARNING              \"ID exp0\" \"MSG exp0\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>    UVM_WARNING              \"ID act0\" \"MSG act0\"\n" };
    dump_exp = { dump_exp , "1:   EXPECTED =>      UVM_ERROR              \"ID exp1\" \"MSG exp1\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>      UVM_ERROR              \"ID act1\" \"MSG act1\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_returns_no_actual_reported)
    uvm_report_mock::expect_warning("ID exp0", "MSG exp0");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>    UVM_WARNING              \"ID exp0\" \"MSG exp0\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>  None reported                        \n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_returns_no_expected_reported)
    uvm_report_fatal("ID exp0", "MSG exp0");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>  None reported                        \n" };
    dump_exp = { dump_exp , "     ACTUAL   =>      UVM_FATAL              \"ID exp0\" \"MSG exp0\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_actual_ids_longer_than_20_are_truncated)
    uvm_report_fatal("ID exp0jfl sj ls jslke ej elekj ", "MSG exp0");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>  None reported                        \n" };
    dump_exp = { dump_exp , "     ACTUAL   =>      UVM_FATAL \"ID exp0jfl sj ls jsl\" \"MSG exp0\"\n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END


  `SVTEST(dump_expected_ids_longer_than_20_are_truncated)
    uvm_report_mock::expect_fatal("ID exp0jfl sj ls jslke ej elekj ", "");
    dump_exp = dump_header();
    dump_exp = { dump_exp , "0:   EXPECTED =>      UVM_FATAL \"ID exp0jfl sj ls jsl\" \"*\"\n" };
    dump_exp = { dump_exp , "     ACTUAL   =>  None reported                        \n" };

    dump_act = uvm_report_mock::dump();

    `FAIL_IF(dump_act != dump_exp);
  `SVTEST_END

  `SVTEST(info_are_ignored)
    uvm_report_info("", "");
    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  `SVUNIT_TESTS_END

  function string dump_header();
    return "uvm_report_mock::dump\n";
  endfunction

endmodule
