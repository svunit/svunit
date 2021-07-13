`include "svunit_defines.svh"
`include "dut.sv"

import svunit_pkg::*;

module parameter_unit_test;
  `SVUNIT_UT_PARAM_WRP("parameter_ut")

  base_ut #(.name("dut_1_BE"), .A(1), .V('hBE)) ut_1_BE();
  `SVUNIT_UT_PARAM(ut_1_BE)

  base_ut #(.name("dut_2_CAFE"), .A(2), .V('hCAFE)) ut_2_CAFE();
  `SVUNIT_UT_PARAM(ut_2_CAFE)

  for(genvar i = 1; i <= 8; ++i) begin : inst
    base_ut #(.name($sformatf("gen_%0d", i)), .A(i), .V(1<<i)) ut_gen();
    `SVUNIT_UT_PARAM(ut_gen)
  end

endmodule


module base_ut;
  parameter string name = "dut_ut";
  svunit_testcase svunit_ut;

  parameter int A = 1;
  parameter type T = bit[(8*A)-1:0];
  parameter T V = '1;


  //===================================
  // This is the UUT that we're
  // running the Unit Tests on
  //===================================
  dut #(A, T, V) my_dut();


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
    `SVTEST(print)
      my_dut.print();
    `SVTEST_END
    `SVTEST(fail_for_param_value)
      `FAIL_IF(A==1)
    `SVTEST_END

  `SVUNIT_TESTS_END


endmodule
