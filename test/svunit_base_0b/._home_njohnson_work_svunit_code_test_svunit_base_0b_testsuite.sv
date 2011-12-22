import svunit_pkg::*;

module _home_njohnson_work_svunit_code_test_svunit_base_0b_testsuite;
  string name = "_home_njohnson_work_svunit_code_test_svunit_base_0b_ts";

  //===================
  // Test suite master
  //===================
  svunit_testsuite svunit_ts;

  //===================================
  // These are the unit tests that we
  // want included in this testsuite
  //===================================
  dut_unit_test dut_ut();


  //===================================
  // Setup
  //===================================
  function void setup();
    dut_ut.setup();
    svunit_ts = new(name);
    svunit_ts.add_testcase(dut_ut.unittest);
  endfunction

endmodule


