`include "uvm_macros.svh"

`include "svunit_defines.svh"

import uvm_pkg::*;

`include "uut.sv"

module uut_unit_test;
  import svunit_pkg::svunit_testcase;
  import svunit_uvm_mock_pkg::*;

  string name = "uut_ut";
  svunit_testcase svunit_ut;


  //===================================
  // This is the UUT that we're
  // running the Unit Tests on
  //===================================
  uut my_uut;


  //===================================
  // Build
  //===================================
  function void build();
    svunit_ut = new(name);

    my_uut = new("uut");
  endfunction


  //===================================
  // Setup for running the Unit Tests
  //===================================
  task setup();
    svunit_ut.setup();

    uvm_report_mock::setup();

    svunit_activate_uvm_component(my_uut);
    svunit_uvm_test_start();
  endtask


  //===================================
  // Here we deconstruct anything we
  // need after running the Unit Tests
  //===================================
  task teardown();
    svunit_ut.teardown();
    /* Place Teardown Code Here */

    svunit_uvm_test_finish();
    svunit_deactivate_uvm_component(my_uut);
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

  //--------------------------------------------
  // test: _99_is_an_error
  // desc: when 99 is passed in, there should be
  //       an errors flagged. We expect that
  //       error by first calling the
  //       uvm_report_mock::expect_error()
  //--------------------------------------------
  `SVTEST(_99_is_an_error)
    uvm_report_mock::expect_error();
    my_uut.verify_arg_is_not_99(99);

    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  //--------------------------------------------
  // test: other_numbers_are_not_an_error
  // desc: no other 8-bit numbers should cause
  //       an error
  //--------------------------------------------
  `SVTEST(other_numbers_are_not_an_error)
    for (int i=0; i<=255; i+=1) begin
      if (i != 99) my_uut.verify_arg_is_not_99(i);
    end

    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  //---------------------------------------------
  // test: _99_has_a_specific_message
  // desc: the error message for 99 has specific
  //       text that we want to verify. We can
  //       do that by passing args into the
  //       expect_error(MSG, ID) function
  //---------------------------------------------
  `SVTEST(_99_has_a_specific_message)
    uvm_report_mock::expect_error("uut", "arg is 99!");
    my_uut.verify_arg_is_not_99(99);

    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  //--------------------------------------------
  // test: gt_100_is_a_warning
  // desc: when 100 is passed in to
  //       warn_arg_is_gt_100, we expect that
  //       warning by first calling the
  //       uvm_report_mock::expect_error().
  //--------------------------------------------
  `SVTEST(gt_100_is_a_warning)
    uvm_report_mock::expect_warning();
    my_uut.warn_arg_is_gt_100(101);

    `FAIL_IF(!uvm_report_mock::verify_complete());
  `SVTEST_END


  `SVUNIT_TESTS_END

endmodule
