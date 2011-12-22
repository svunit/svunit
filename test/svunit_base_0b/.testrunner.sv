import svunit_pkg::*;

module testrunner();
  string name = "testrunner";
  svunit_testrunner svunit_tr;

  //===================================
  // These are the tests suites that we
  // want included in this testrunner
  //===================================
  _home_njohnson_work_svunit_code_test_svunit_base_0b_testsuite _home_njohnson_work_svunit_code_test_svunit_base_0b_ts();


  //===================================
  // Setup
  //===================================
  function void setup();
    svunit_tr = new(name);
    _home_njohnson_work_svunit_code_test_svunit_base_0b_ts.setup();
    svunit_tr.add_testsuite(_home_njohnson_work_svunit_code_test_svunit_base_0b_ts.svunit_ts);
  endfunction

  task run();
    svunit_tr.run();
  endtask
endmodule
